// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/requests"
	messengerEntities "korst-backend/internal/messenger/entities"
	messengerMocks "korst-backend/internal/messenger/mocks"
	mockRepositories "korst-backend/internal/mocks/repositories"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestGetChats тестирует получение чатов по ID пользователя
func TestGetChats(t *testing.T) {
	logger.InitLoggerTest()

	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}

	ChatService := NewChatService(mockUserRepo,
		mockCardRepo, mockChatRepo, mockMessageRepo)

	chatID := uuid.New()
	cardID := uuid.New()
	cardName := "Название карточки"

	userID := uuid.New()
	user := &entities.User{ID: userID}

	anotherUserID := uuid.New()
	anotherUser := &entities.User{ID: anotherUserID}

	card := &entities.Card{
		ID:     cardID,
		UserID: userID,
		Name:   cardName,
	}

	chat := &messengerEntities.Chat{
		ID:         chatID,
		CardID:     cardID,
		MerchantID: userID,
		CustomerID: anotherUserID,
		UpdatedAt:  time.Now().UTC().Add(2 * time.Minute),
	}

	messageText := "Текст последнего сообщения"

	message1 := messengerEntities.Message{
		CreatedAt: time.Now().UTC(),
	}

	message2 := messengerEntities.Message{
		Text:      messageText,
		CreatedAt: time.Now().UTC().Add(2 * time.Minute),
	}

	messages := []messengerEntities.Message{message1, message2}

	chat.Messages = messages
	user.MerchantChats = []messengerEntities.Chat{*chat}

	mockUserRepo.On("FindWithChats", userID).Return(user, nil)

	mockUserRepo.On("FindByID", anotherUserID).Return(anotherUser, nil)

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	response, err := ChatService.GetChats(userID)

	neededChat := response.MerchantChats[0]

	require.NoError(t, err)
	require.Equal(t, chatID, neededChat.ID)

	require.Equal(t, anotherUserID, neededChat.User.ID)
	require.Equal(t, messageText, neededChat.LastMessage.Text)
	require.Equal(t, cardID, neededChat.Card.ID)

	mockUserRepo.AssertExpectations(t)
	mockCardRepo.AssertExpectations(t)
}

// TestGetMessages тестирует получение сообщений из определенного чата
func TestGetMessages(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}

	ChatService := NewChatService(mockUserRepo,
		mockCardRepo, mockChatRepo, mockMessageRepo)

	chatID := uuid.New()
	userID := uuid.New()
	anotherUserID := uuid.New()

	message1ID := uuid.New()
	message2ID := uuid.New()
	messageText1 := "Привет"
	messageText2 := "Здарова"

	message1 := messengerEntities.Message{
		ID:        message1ID,
		AuthorID:  userID,
		Text:      messageText1,
		CreatedAt: time.Now().UTC(),
	}

	message2 := messengerEntities.Message{
		ID:        message2ID,
		AuthorID:  anotherUserID,
		Text:      messageText2,
		CreatedAt: time.Now().UTC().Add(2 * time.Minute),
	}

	chat := &messengerEntities.Chat{
		ID: chatID,
		Messages: []messengerEntities.Message{
			message1,
			message2,
		},
	}

	mockChatRepo.On("FindByID", chatID).Return(chat, nil)

	mockMessageRepo.
		On("UpdateMessage", mock.AnythingOfType("*entities.Message")).
		Return(nil)

	response, err := ChatService.GetMessages(chatID, userID)

	require.NoError(t, err)
	mockChatRepo.AssertExpectations(t)

	require.Equal(t, message2ID, response.Messages[0].ID)
	require.Equal(t, anotherUserID, response.Messages[0].AuthorID)
	require.Equal(t, messageText2, response.Messages[0].Text)
	require.Equal(t, true, response.Messages[0].IsSeen)

	require.Equal(t, message1ID, response.Messages[1].ID)
	require.Equal(t, messageText1, response.Messages[1].Text)
	require.Equal(t, userID, response.Messages[1].AuthorID)
	require.Equal(t, false, response.Messages[1].IsSeen)
}

// CreateChat тестирует создание нового чата
func TestCreateChat(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockChatRepo := &messengerMocks.MockChatRepo{}
	mockMessageRepo := &messengerMocks.MockMessageRepo{}

	ChatService := NewChatService(mockUserRepo,
		mockCardRepo, mockChatRepo, mockMessageRepo)

	authorID := uuid.New()
	userID := uuid.New()
	cardID := uuid.New()

	card := &entities.Card{
		ID:     cardID,
		UserID: userID,
	}

	chat := &messengerEntities.Chat{
		CardID:     cardID,
		CustomerID: authorID,
		MerchantID: userID,
	}

	req := requests.CreateChatRequest{
		UserID: userID,
		CardID: cardID,
	}

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	mockChatRepo.
		On("FindByCardAndUsers", cardID, authorID, userID).
		Return(nil, nil)

	mockChatRepo.On("CreateChat", chat).Return(nil)

	err := ChatService.CreateChat(authorID, req)

	require.NoError(t, err)
	mockCardRepo.AssertExpectations(t)
	mockChatRepo.AssertExpectations(t)
}
