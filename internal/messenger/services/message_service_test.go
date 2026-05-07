// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	messengerEntities "korst-backend/internal/messenger/entities"
	messengerMocks "korst-backend/internal/messenger/mocks"
	mockRepositories "korst-backend/internal/mocks/repositories"
	mockServices "korst-backend/internal/mocks/services"
	"os"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestSendMessage тестирует отправку нового сообщения
func TestSendMessage(t *testing.T) {
	logger.InitLoggerTest()

	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}
	mockFileService := &mockServices.MockFileService{}
	mockHub := &messengerMocks.MockHub{}

	MessageService := NewMessageService(mockUserRepo, mockChatRepo,
		mockMessageRepo, mockFileService, mockHub)

	authorID := uuid.New()
	anotherUserID := uuid.New()
	chatID := uuid.New()
	text := "Привет"

	author := &entities.User{ID: authorID}
	chat := &messengerEntities.Chat{
		ID:         chatID,
		CustomerID: authorID,
		MerchantID: anotherUserID,
	}

	_ = os.Setenv("BASE_URL", "base-url")

	mockUserRepo.On("FindByID", authorID).Return(author, nil)

	mockMessageRepo.
		On("CreateMessage", mock.AnythingOfType("*entities.Message")).
		Return(nil)

	mockChatRepo.On("FindByID", chatID).Return(chat, nil)

	mockHub.On("SendToUser", anotherUserID, mock.AnythingOfType("[]uint8"))

	err := MessageService.SendMessage(authorID, chatID, text)

	require.NoError(t, err)
	mockUserRepo.AssertExpectations(t)
	mockChatRepo.AssertExpectations(t)
	mockMessageRepo.AssertExpectations(t)
	mockHub.AssertExpectations(t)
}

// TestChangeMessage тестирует изменение существующего сообщения
func TestChangeMessage(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}
	mockFileService := &mockServices.MockFileService{}
	mockHub := &messengerMocks.MockHub{}

	MessageService := NewMessageService(mockUserRepo, mockChatRepo,
		mockMessageRepo, mockFileService, mockHub)

	authorID := uuid.New()
	messageID := uuid.New()
	oldText := "Старый текст сообщения"
	newText := "Новый текст сообщения"

	oldMessage := &messengerEntities.Message{
		ID:       messageID,
		AuthorID: authorID,
		Text:     oldText,
	}

	newMessage := &messengerEntities.Message{
		ID:       messageID,
		AuthorID: authorID,
		Text:     newText,
	}

	mockMessageRepo.On("FindByID", messageID).Return(oldMessage, nil)

	mockMessageRepo.On("UpdateMessage", newMessage).Return(nil)

	err := MessageService.ChangeMessage(authorID, messageID, newText)

	require.NoError(t, err)
	mockMessageRepo.AssertExpectations(t)
}

// TestDeleteMessage тестирует удаление определенного сообщения
func TestDeleteMessage(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}
	mockFileService := &mockServices.MockFileService{}
	mockHub := &messengerMocks.MockHub{}

	MessageService := NewMessageService(mockUserRepo, mockChatRepo,
		mockMessageRepo, mockFileService, mockHub)

	authorID := uuid.New()
	messageID := uuid.New()
	text := "Старый текст сообщения"

	message := &messengerEntities.Message{
		ID:       messageID,
		AuthorID: authorID,
		Text:     text,
	}

	mockMessageRepo.On("FindByID", messageID).Return(message, nil)

	mockMessageRepo.On("DeleteMessage", message).Return(nil)

	err := MessageService.DeleteMessage(authorID, messageID)

	require.NoError(t, err)
	mockMessageRepo.AssertExpectations(t)
}
