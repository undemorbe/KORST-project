// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
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

// TestCheckUser проверяет работу хэндлера CheckUser
func TestCheckUser(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockAuthService := &mockServices.MockAuthService{}
	mockTokenService := &mockServices.MockTokenService{}

	authHandler := NewAuthHandler(mockAuthService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/check-user", authHandler.CheckUser)

	mockAuthService.
		On("CheckUser", "+79123456789").
		Return(responses.IsUserResponse{
			Status: "registered",
		}, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		"/check-user?phone=%2B79123456789",
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.IsUserResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "registered", response.Status)
	mockAuthService.AssertExpectations(t)
}

// TestRefreshTokens проверяет работу хэндлера RefreshTokens
func TestRefreshTokens(t *testing.T) {

	mockAuthService := &mockServices.MockAuthService{}
	mockTokenService := &mockServices.MockTokenService{}

	authHandler := NewAuthHandler(mockAuthService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/refresh", authHandler.RefreshTokens)

	accessToken := "new-access-token"
	refreshToken := "new-access-token"

	mockAuthService.
		On("GetNewTokens", "old-refresh-token").
		Return(responses.RefreshResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		}, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		"/refresh?refresh-token=old-refresh-token",
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.RefreshResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, accessToken, response.AccessToken)
	require.Equal(t, refreshToken, response.RefreshToken)
	mockAuthService.AssertExpectations(t)
}
