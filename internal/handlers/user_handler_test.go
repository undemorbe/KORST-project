// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	"korst-backend/internal/mocks"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestRegisterUser проверяет работу хэндлера RegisterUser
func TestUpdateUser(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockUserService := &mocks.MockUserService{}
	mockTokenService := &mocks.MockTokenService{}

	userHandler := NewUserHandler(mockUserService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/update", userHandler.UpdateUserInfo)

	accessToken := "access-token"
	userID := uuid.New()

	body := `{
		"name": "Олег",
		"surname": "Олегович",
		"description": "Описание",
		"contacts": {
			"email": null,
			"telegram": "@oleg"
		}
	}`

	mockTokenService.On("DecodeAccessToken", accessToken).Return(userID, nil)

	mockUserService.
		On("UpdateUserInfo", userID, mock.AnythingOfType("*requests.UpdateUserRequest")).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/update",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
}
