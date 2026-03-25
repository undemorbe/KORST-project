// main - пакет с точкой входа программы
package main

import (
	"korst-backend/internal/handlers"
	"korst-backend/internal/infrastructure/database"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	repositories "korst-backend/internal/repository"
	"korst-backend/internal/services"

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

	// Подключение репозиториев
	userRepo := repositories.NewUserRepository(db)
	otpRepo := repositories.NewOTPRepository(db)
	refreshTokenRepo := repositories.NewRefreshTokenRepository(db)
	cardRepo := repositories.NewCardRepository(db)
	profileRepo := repositories.NewProfileRepository(db)
	reviewRepo := repositories.NewReviewRepository(db)

	// Подключение сервисов
	tokenService := services.NewTokenService(userRepo, refreshTokenRepo)
	authService := services.NewAuthService(userRepo, refreshTokenRepo, tokenService)
	otpService := services.NewOTPService(otpRepo, userRepo, tokenService)
	cardService := services.NewCardService(cardRepo, userRepo)
	userService := services.NewUserService(userRepo, profileRepo)
	reviewService := services.NewReviewService(userRepo, profileRepo, reviewRepo)

	// Подключение хэндлеров
	authHandler := handlers.NewAuthHandler(authService)
	otpHandler := handlers.NewOTPHandler(otpService)
	cardHandler := handlers.NewCardHandler(cardService, tokenService)
	userHandler := handlers.NewUserHandler(userService, tokenService)
	reviewHandler := handlers.NewReviewHandler(reviewService, tokenService)

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
		cards.GET("/get-cards", cardHandler.GetCards)
		cards.GET("/card-info", cardHandler.GetCardInfo)
	}

	user := api.Group("/user")
	{
		user.POST("/update", userHandler.UpdateUserInfo)
		user.GET("/get-info", userHandler.GetUserInfo)

		user.GET("/reviews", reviewHandler.GetReviews)
		user.POST("/post-review", reviewHandler.PostReview)
	}

	// Запуск сервера
	logger.Log.Info("Сервер запущен на :5040")
	if err := r.Run(":5040"); err != nil {
		logger.Log.Error(err)
	}
}
