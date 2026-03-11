// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	"korst-backend/internal/mocks"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

func TestCheckUser(t *testing.T) {
	logger.InitLoggerTest()

	mockAuthService := new(mocks.MockAuthService)

	authHandler := NewAuthHandler(mockAuthService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/is-user", authHandler.CheckUser)

	body := `{
		"phone": "+79123456789"
	}`

	mockAuthService.
		On("CheckUser", "+79123456789").
		Return(responses.IsUserResponse{
			Status: "registered",
		}, nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/is-user",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.IsUserResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, "registered", response.Status)
}

func TestRegisterUser(t *testing.T) {
	mockAuthService := new(mocks.MockAuthService)

	authHandler := NewAuthHandler(mockAuthService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/register", authHandler.RegisterUser)

	body := `{
		"phone": "+79123456789",
		"name": "Олег",
		"surname": "Олегович"
	}`

	mockAuthService.
		On("RegisterUser", mock.AnythingOfType("requests.RegisterRequest")).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/register",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
}

func TestRefreshTokens(t *testing.T) {
	mockAuthService := new(mocks.MockAuthService)

	authHandler := NewAuthHandler(mockAuthService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/refresh", authHandler.RefreshTokens)

	body := `{
		"refresh-token": "old-refresh-token"
	}`

	accessToken := "new-access-token"
	refreshToken := "new-access-token"

	mockAuthService.
		On("GetNewTokens", "old-refresh-token").
		Return(responses.RefreshResponse{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
		}, nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/refresh",
		bytes.NewBufferString(body),
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
}
