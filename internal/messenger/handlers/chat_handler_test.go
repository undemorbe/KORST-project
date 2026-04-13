// handlers - пакет, содержащий хэндлеры для обработки
// запросов, связанных с мессенджером
package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/requests"
	"korst-backend/internal/messenger/dto/responses"
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

// TestGetChats тестирует обработку запроса на
// получение всех чатов пользователя
func TestGetChats(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockChatService := &mocks.MockChatService{}
	mockTokenService := &mockServices.MockTokenService{}

	chatHandler := NewChatHandler(mockChatService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/chats", chatHandler.GetChats)

	accessToken := "access-token"
	chatID := uuid.New()
	userID := uuid.New()
	anotherUserID := uuid.New()
	cardName := "Название карточки"
	lastMessageText := "Текст сообщения"

	card := responses.CardInfo{Name: cardName}
	user := responses.UserInfo{ID: anotherUserID}
	lastMessage := responses.Message{Text: lastMessageText}

	chatInfo := responses.ChatInfo{
		ID:          chatID,
		Card:        card,
		User:        user,
		LastMessage: &lastMessage,
	}

	responseFromFunc := responses.GetChatsResponse{
		MerchantChats: []responses.ChatInfo{
			chatInfo,
		},
		CustomerChats: []responses.ChatInfo{},
	}

	mockTokenService.On("DecodeAccessToken", accessToken).Return(userID, nil)

	mockChatService.On("GetChats", userID).Return(responseFromFunc, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		"/chats",
		nil,
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.GetChatsResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, chatID, response.MerchantChats[0].ID)
	require.Equal(t, cardName, response.MerchantChats[0].Card.Name)
	require.Equal(t, anotherUserID, response.MerchantChats[0].User.ID)
	require.Equal(t, lastMessageText, response.MerchantChats[0].LastMessage.Text)

	mockTokenService.AssertExpectations(t)
	mockChatService.AssertExpectations(t)
}

// TestCreateChat тестирует обработку запроса на
// создание нового чата
func TestCreateChat(t *testing.T) {
	mockChatService := &mocks.MockChatService{}
	mockTokenService := &mockServices.MockTokenService{}

	chatHandler := NewChatHandler(mockChatService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/create-chat", chatHandler.CreateChat)

	accessToken := "access-token"
	authorID := uuid.New()
	userID := uuid.New()
	cardID := uuid.New()

	request := requests.CreateChatRequest{
		UserID: userID,
		CardID: cardID,
	}

	body := fmt.Sprintf(`{
		"user-id": "%s",
		"card-id": "%s"
	}`, userID.String(), cardID.String())

	mockTokenService.On("DecodeAccessToken", accessToken).Return(authorID, nil)

	mockChatService.On("CreateChat", authorID, request).Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/create-chat",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockChatService.AssertExpectations(t)
}

// TestGetMessages тестирует обработку запроса на
// получение всех сообщений из определенного чата
func TestGetMessages(t *testing.T) {
	mockChatService := &mocks.MockChatService{}
	mockTokenService := &mockServices.MockTokenService{}

	chatHandler := NewChatHandler(mockChatService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/messages", chatHandler.GetMessages)

	authorID := uuid.New()
	chatID := uuid.New()
	messageText := "Текст сообщения"

	responseFromFunc := responses.GetMessagesReponse{
		Messages: []responses.Message{
			{
				AuthorID: authorID,
				Text:     messageText,
			},
		},
	}

	mockChatService.On("GetMessages", chatID).Return(responseFromFunc, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		fmt.Sprintf("/messages?chat-id=%s", chatID.String()),
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.GetMessagesReponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, authorID, response.Messages[0].AuthorID)
	require.Equal(t, messageText, response.Messages[0].Text)

	mockChatService.AssertExpectations(t)
}
