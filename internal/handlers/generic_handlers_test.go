// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	stdErrors "errors"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/require"
)

// TestInvalidRequest проверяет работу хэндлеров
// (на примере одного) при некорректном запросе
func TestInvalidRequest(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockOTPService := &mockServices.MockOTPService{}

	otpHandler := NewOTPHandler(mockOTPService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/send-otp", otpHandler.SendOTP)

	body := `{
		"invalid_value": "+79123456789"
	}`

	req := httptest.NewRequest(
		http.MethodPost,
		"/send-otp",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusBadRequest, writer.Code)

	var response responses.GenericResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "INVALID_INPUT", response.Code)
	require.Equal(t, "Некоректный формат входных данных", response.Message)
	mockOTPService.AssertNotCalled(t, "SendOTP", "+79123456789")
}

// TestExpectedError проверяет обработку хэндлерами
// ожидаемой (установленной заранее в errors) ошибки
func TestExpectedError(t *testing.T) {
	mockOTPService := new(mockServices.MockOTPService)

	otpHandler := NewOTPHandler(mockOTPService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/send-otp", otpHandler.SendOTP)

	body := `{
		"phone": "+79123456789"
	}`

	mockOTPService.
		On("SendOTP", "+79123456789").
		Return(errors.ErrorUserNotFound)

	req := httptest.NewRequest(
		http.MethodPost,
		"/send-otp",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusNotFound, writer.Code)

	var response responses.GenericResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "NOT_FOUND", response.Code)
	require.Equal(t, "Пользователь не найден", response.Message)
	mockOTPService.AssertExpectations(t)
}

// TestUnexpectedError проверяет обработку хэндлерами
// случайной (непредвиденной) ошибки
func TestUnexpectedError(t *testing.T) {
	mockOTPService := new(mockServices.MockOTPService)

	otpHandler := NewOTPHandler(mockOTPService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/send-otp", otpHandler.SendOTP)

	body := `{
		"phone": "+79123456789"
	}`

	mockOTPService.
		On("SendOTP", "+79123456789").
		Return(stdErrors.New("some randon error"))

	req := httptest.NewRequest(
		http.MethodPost,
		"/send-otp",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusInternalServerError, writer.Code)

	var response responses.GenericResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "INTERNAL_ERROR", response.Code)
	require.Equal(t, "Непредвиденная ошибка сервера. Попробуйте позже", response.Message)
	mockOTPService.AssertExpectations(t)
}
