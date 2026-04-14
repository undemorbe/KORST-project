// handlers - пакет, содержащий хэндлеры для обработки
// запросов, связанных с мессенджером
package handlers

import (
	"bytes"
	"fmt"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/mocks"
	"korst-backend/internal/middleware"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// TestSendMessage тестирует обработку запроса на
// отправку сообщения пользователю
func TestSendMessage(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockMessageService := &mocks.MockMessageService{}
	mockTokenService := &mockServices.MockTokenService{}

	messageHandler := NewMessageHandler(mockMessageService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/send-message", messageHandler.SendMessage)

	accessToken := "access-token"
	userID := uuid.New()
	chatID := uuid.New()
	text := "Текст сообщения"

	body := fmt.Sprintf(`{
		"chat-id": "%s",
		"text": "%s"
	}`, chatID.String(), text)

	mockTokenService.On("DecodeAccessToken", accessToken).Return(userID, nil)

	mockMessageService.
		On("SendMessage", userID, chatID, text).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/send-message",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockTokenService.AssertExpectations(t)
	mockMessageService.AssertExpectations(t)
}

// TestSendMessage тестирует обработку запроса на
// изменение существующего сообщения
func TestChangeMessage(t *testing.T) {
	mockMessageService := &mocks.MockMessageService{}
	mockTokenService := &mockServices.MockTokenService{}

	messageHandler := NewMessageHandler(mockMessageService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.PUT("/change-message", messageHandler.ChangeMessage)

	accessToken := "access-token"
	userID := uuid.New()
	messageID := uuid.New()
	text := "Текст сообщения"

	body := fmt.Sprintf(`{
		"message-id": "%s",
		"text": "%s"
	}`, messageID.String(), text)

	mockTokenService.On("DecodeAccessToken", accessToken).Return(userID, nil)

	mockMessageService.
		On("ChangeMessage", userID, messageID, text).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPut,
		"/change-message",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockTokenService.AssertExpectations(t)
	mockMessageService.AssertExpectations(t)
}
