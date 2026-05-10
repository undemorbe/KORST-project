// main - пакет с точкой входа программы
package main

import (
	"korst-backend/internal/handlers"
	"korst-backend/internal/infrastructure/database"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/infrastructure/storage"
	messengerHandlers "korst-backend/internal/messenger/handlers"
	messengerRepositories "korst-backend/internal/messenger/repositories"
	messengerServices "korst-backend/internal/messenger/services"
	"korst-backend/internal/middleware"
	repositories "korst-backend/internal/repository"
	"korst-backend/internal/services"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

// main запускает сервер для обработки Api запросов.
// В main подключаются middleware, логгер, БД, репозитории, сервисы, хэндлеры
func main() {
	// Создание движка Gin
	r := gin.Default()

	// Подключение Middleware
	r.Use(middleware.RecoveryMiddleware())
	r.Use(middleware.ErrorHandler())

	// Подключение логгера
	logger.InitLogger()

	// Чтение .env файла
	err := godotenv.Load()
	if err != nil {
		logger.Log.Fatal("Ошибка при загрузке .env файла")
	}

	// Подключение к БД
	db, err := database.NewPostgresConnection()
	if err != nil {
		logger.Log.Fatal("Ошибка подключения к БД: ", err)
	}
	logger.Log.Info("Успешно осуществлено подключение к БД")

	// Запуск миграций БД
	err = database.RunMigrations(db)
	if err != nil {
		logger.Log.Fatal("Ошибка применения миграций: ", err)
	}
	logger.Log.Info("Миграции успешно применены")

	// Подключение Hub для работы WebSocket
	hub := messengerServices.NewHub()

	// Запуск Hub для WebSocket
	go hub.Run()

	// Подключение хранилища
	storage := storage.NewLocalStorage(os.Getenv("BASE_PATH"))

	// Подключение общих репозиториев
	userRepo := repositories.NewUserRepository(db)
	otpRepo := repositories.NewOTPRepository(db)
	refreshTokenRepo := repositories.NewRefreshTokenRepository(db)
	cardRepo := repositories.NewCardRepository(db)
	profileRepo := repositories.NewProfileRepository(db)
	reviewRepo := repositories.NewReviewRepository(db)
	replyRepo := repositories.NewReplyRepository(db)
	bannerRepo := repositories.NewBannerRepository(db)

	// Подключение общих сервисов
	tokenService := services.NewTokenService(userRepo, refreshTokenRepo)
	fileService := services.NewFileService(storage)
	authService := services.NewAuthService(userRepo, refreshTokenRepo, tokenService)
	otpService := services.NewOTPService(otpRepo, userRepo, tokenService)
	cardService := services.NewCardService(cardRepo, userRepo, fileService)
	userService := services.NewUserService(userRepo, profileRepo, fileService)
	reviewService := services.NewReviewService(userRepo, profileRepo, reviewRepo)
	replyService := services.NewReplyService(userRepo, cardRepo, replyRepo)
	bannerService := services.NewBannerService(bannerRepo, fileService)

	// Подключение общих хэндлеров
	authHandler := handlers.NewAuthHandler(authService, tokenService)
	otpHandler := handlers.NewOTPHandler(otpService)
	cardHandler := handlers.NewCardHandler(cardService, tokenService)
	userHandler := handlers.NewUserHandler(userService, tokenService)
	reviewHandler := handlers.NewReviewHandler(reviewService, tokenService)
	replyHandler := handlers.NewReplyHandler(replyService, tokenService)
	bannerHandler := handlers.NewBannerHandler(bannerService)

	// Подключение модулей мессенджера
	chatRepo := messengerRepositories.NewChatRepository(db)
	messageRepo := messengerRepositories.NewMessageRepository(db)

	chatService := messengerServices.NewChatService(userRepo, cardRepo, chatRepo, messageRepo)
	messageService := messengerServices.NewMessageService(userRepo, chatRepo, messageRepo, fileService, hub)

	chatHandler := messengerHandlers.NewChatHandler(chatService, tokenService)
	messageHandler := messengerHandlers.NewMessageHandler(messageService, tokenService)
	wsHandler := messengerHandlers.NewWSHandler(hub, tokenService)

	// Регистрация маршрутов
	api := r.Group("/api")

	authorize := api.Group("/authorize")
	{
		authorize.GET("/check-user", authHandler.CheckUser)
		authorize.GET("/refresh", authHandler.RefreshTokens)

		authorize.POST("/send-otp", otpHandler.SendOTP)
		authorize.POST("/verify-otp", otpHandler.VerifyOTP)
	}

	cards := api.Group("/cards")
	{
		cards.POST("/save-card", cardHandler.SaveCard)
		cards.POST("/update-card", cardHandler.UpdateCard)
		cards.POST("/save-image", cardHandler.SaveImage)

		cards.GET("/get-cards", cardHandler.GetCards)
		cards.GET("/get-with-query", cardHandler.GetWithQuery)
		cards.GET("/card-info", cardHandler.GetCardInfo)
	}

	user := api.Group("/user")
	{
		user.POST("/update", userHandler.UpdateUserInfo)
		user.POST("/save-image", userHandler.SaveImage)
		user.GET("/get-info", userHandler.GetUserInfo)
		user.GET("/me", userHandler.GetMyInfo)

		user.GET("/reviews", reviewHandler.GetReviews)
		user.POST("/post-review", reviewHandler.PostReview)
	}

	messenger := api.Group("/messenger")
	{
		messenger.GET("/chats", chatHandler.GetChats)
		messenger.GET("/messages", chatHandler.GetMessages)
		messenger.POST("/create-chat", chatHandler.CreateChat)

		messenger.POST("/send-message", messageHandler.SendMessage)
		messenger.POST("/send-image", messageHandler.SendImage)
		messenger.PUT("/change-message", messageHandler.ChangeMessage)
		messenger.DELETE("/delete-message", messageHandler.DeleteMessage)

		messenger.GET("/websocket", wsHandler.Handle)
	}

	replies := api.Group("/replies")
	{
		replies.POST("/create-reply", replyHandler.CreateReply)
		replies.GET("executors", replyHandler.GetExecutors)

		replies.POST("/approve-executor", replyHandler.ApproveExecutor)
		replies.POST("/reject-executor", replyHandler.RejectExecutor)
		replies.POST("/close", replyHandler.CloseCard)
	}

	banners := api.Group("/banners")
	{
		banners.POST("/save-banner", bannerHandler.SaveBanner)
		banners.GET("/get-banners", bannerHandler.GetBanners)
	}

	// Маршруты для получения изображений
	uploads := r.Group("/uploads")
	{
		uploads.Static("/profiles", "./uploads/profiles")
		uploads.Static("/cards", "./uploads/cards")
		uploads.Static("/messages", "./uploads/messages")
		uploads.Static("/banners", "./uploads/banners")
	}

	// Запуск сервера
	logger.Log.Info("Сервер запущен на :5040")
	if err := r.Run(":5040"); err != nil {
		logger.Log.Error(err)
	}
}
