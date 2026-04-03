// mocks - пакет, содержащий интерфейсы для изолированного
// проведения тестов методов мессенджера
package mocks

import (
	"korst-backend/internal/messenger/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockChatService - структура для передачи
// фикстивной реализации сервиса ChatService
type MockChatService struct{ mock.Mock }

// GetChats задает фиктивню реализацию получения чатов
func (m *MockChatService) GetChats(userID uuid.UUID) (responses.GetChatsResponse, error) {
	args := m.Called()
	return args.Get(0).(responses.GetChatsResponse), args.Error(1)
}

// GetMessages задает фиктивную реализацию получения всех сообщения из чата
func (m *MockChatService) GetMessages(chatID uuid.UUID) (responses.GetMessagesReponse, error) {
	args := m.Called(chatID)
	return args.Get(0).(responses.GetMessagesReponse), args.Error(1)
}

// MockMessageService - структура для передачи
// фиктивной реализации сервиса MessageService
type MockMessageService struct{ mock.Mock }

// SendMessage задает фиктивную реализацию отправки сообщения пользователю
func (m *MockMessageService) SendMessage(authorID uuid.UUID, chatID uuid.UUID, text string) error {
	args := m.Called(authorID, chatID, text)
	return args.Error(0)
}
