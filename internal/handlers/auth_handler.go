// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"net/http"

	"github.com/gin-gonic/gin"
)

// AuthHandler - объект, содержащий методы для обработки Api запросов
type AuthHandler struct {
	authService ports.AuthService
	otpService  ports.OTPService
}

// NewAuthHandler создает и возвращает новый объект AuthHandler
func NewAuthHandler(
	otpService ports.OTPService,
	authService ports.AuthService,
) *AuthHandler {
	return &AuthHandler{
		otpService:  otpService,
		authService: authService,
	}
}

// SendOTP обрабатывает запрос отправки OTP кода
func (h *AuthHandler) SendOTP(c *gin.Context) {
	var req requests.PhoneNumberRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	err = h.otpService.SendOTP(req.Phone)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("OTP-код успешно отправлен на номер: ", req.Phone)
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// VerifyOTP обрабатывает запрос подтверждения OTP кода
func (h *AuthHandler) VerifyOTP(c *gin.Context) {
	var req requests.VerifyOTPRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.otpService.VerifyOTP(req.Phone, req.OTP)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("OTP-код успешно подтвержден")
	c.JSON(http.StatusOK, response)
}

// CheckUser обрабатывает запрос проверки статуса пользователя.
// Статусы: notFound, notRegistered, registered
func (h *AuthHandler) CheckUser(c *gin.Context) {
	var req requests.PhoneNumberRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.authService.CheckUser(req.Phone)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Проверка статуса пользователя успешно выполнена")
	c.JSON(http.StatusOK, response)
}

// RegisterUser обрабатывает запрос регистрации пользователя
func (h *AuthHandler) RegisterUser(c *gin.Context) {
	var req requests.RegisterRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	err = h.authService.RegisterUser(req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Пользователь успешно зарегистрирован")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// RefreshTokens обрабатывает запрос обновления токенов
func (h *AuthHandler) RefreshTokens(c *gin.Context) {
	var req requests.RefreshRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.authService.GetNewTokens(req.RefreshToken)
	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Обновление токенов успешно выполнено")
	c.JSON(http.StatusOK, response)
}
