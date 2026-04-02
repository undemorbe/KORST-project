// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/require"
)

// TestSendOTP проверяет работу хэндлера SendOTP
func TestSendOTP(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockOTPService := &mockServices.MockOTPService{}

	otpHandler := NewOTPHandler(mockOTPService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/send-otp", otpHandler.SendOTP)

	body := `{
		"phone": "+79123456789"
	}`

	mockOTPService.
		On("SendOTP", "+79123456789").
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/send-otp",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockOTPService.AssertExpectations(t)
}

// TestVerifyOTP проверяет работу хэндлера VerifyOTP
func TestVerifyOTP(t *testing.T) {
	mockOTPService := new(mockServices.MockOTPService)

	otpHandler := NewOTPHandler(mockOTPService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/verify-otp", otpHandler.VerifyOTP)

	body := `{
		"phone": "+79123456789",
		"otp": "1234"
	}`

	mockOTPService.
		On("VerifyOTP", "+79123456789", "1234").
		Return(responses.VerifyOTPResponse{
			AccessToken:  "access-token",
			RefreshToken: "refresh-token",
			Status:       "registered",
		}, nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/verify-otp",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.VerifyOTPResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "access-token", response.AccessToken)
	require.Equal(t, "refresh-token", response.RefreshToken)
	require.Equal(t, "registered", response.Status)
	mockOTPService.AssertExpectations(t)
}
