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

// OTPHandler - объект, содержащий методы для обработки
// Api запросов, связанных с OTP-кодами
type OTPHandler struct {
	otpService ports.OTPService
}

// NewOTPHandler создает и возвращает новый объект OTPHandler
func NewOTPHandler(otpService ports.OTPService) *OTPHandler {
	return &OTPHandler{
		otpService: otpService,
	}
}

// SendOTP обрабатывает запрос отправки OTP кода
func (h *OTPHandler) SendOTP(c *gin.Context) {
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
func (h *OTPHandler) VerifyOTP(c *gin.Context) {
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
