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

	// Подключение сервисов
	authService := services.NewAuthService(userRepo)
	otpService := services.NewOTPService(otpRepo)

	// Подключение хэндлеров
	authHandler := handlers.NewAuthHandler(otpService, authService)

	// Регистрация маршрутов
	api := r.Group("/authorize")
	{
		api.GET("/is-user", authHandler.CheckUser)
		api.POST("/register", authHandler.RegisterUser)

		api.POST("/send-otp", authHandler.SendOTP)
		api.POST("/verify-otp", authHandler.VerifyOTP)
	}

	// Запуск сервера
	logger.Log.Info("Сервер запущен на :5040")
	if err := r.Run(":5040"); err != nil {
		logger.Log.Error(err)
	}
}
