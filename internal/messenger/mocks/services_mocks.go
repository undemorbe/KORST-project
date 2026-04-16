// mocks - пакет, содержащий интерфейсы для изолированного
// проведения тестов методов мессенджера
package mocks

import (
	"io"
	"korst-backend/internal/messenger/dto/requests"
	"korst-backend/internal/messenger/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockChatService - структура для передачи
// фикстивной реализации сервиса ChatService
type MockChatService struct{ mock.Mock }

// GetChats задает фиктивню реализацию получения чатов
func (m *MockChatService) GetChats(userID uuid.UUID) (responses.GetChatsResponse, error) {
	args := m.Called(userID)
	return args.Get(0).(responses.GetChatsResponse), args.Error(1)
}

// CreateChat задает фиктивную реализацию создания чата
func (m *MockChatService) CreateChat(authorID uuid.UUID, req requests.CreateChatRequest) error {
	args := m.Called(authorID, req)
	return args.Error(0)
}

// GetMessages задает фиктивную реализацию получения всех сообщения из чата
func (m *MockChatService) GetMessages(chatID uuid.UUID, userID uuid.UUID) (responses.GetMessagesReponse, error) {
	args := m.Called(chatID, userID)
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

// SendImage задает фиктивную реализацию отправки изображения пользователю
func (m *MockMessageService) SendImage(authorID uuid.UUID, chatID uuid.UUID,
	text string, file io.Reader, fileName string) error {
	args := m.Called(authorID, chatID, text, file, fileName)
	return args.Error(0)
}

// ChangeMessage задает фиктивную реализацию изменения сообщения
func (m *MockMessageService) ChangeMessage(authorID uuid.UUID, messageID uuid.UUID, text string) error {
	args := m.Called(authorID, messageID, text)
	return args.Error(0)
}

// DeleteMessage задает фиктивную реализацию удаления сообщения
func (m *MockMessageService) DeleteMessage(authorID uuid.UUID, messageID uuid.UUID) error {
	args := m.Called(authorID, messageID)
	return args.Error(0)
}
