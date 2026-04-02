// mocks - пакет, содержащий интерфейсы для изолированного
// проведения тестов методов мессенджера
package mocks

import (
	"korst-backend/internal/messenger/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockChatRepo - структура для передачи в тестах
// фиктивной реализации репозитория chatRepo
type MockChatRepo struct{ mock.Mock }

// FindByID задает фиктивную реализацию поиска чата по ID
func (m *MockChatRepo) FindByID(chatID uuid.UUID) (*entities.Chat, error) {
	args := m.Called(chatID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Chat), args.Error(1)
}

// CreateChat задает фиктивную реализацию создания чата
func (m *MockChatRepo) CreateChat(chat *entities.Chat) error {
	args := m.Called(chat)
	return args.Error(0)
}

// MockMessageRepo - структура для передачи в тестах
// фиктивной реализации репозитория messageRepo
type MockMessageRepo struct{ mock.Mock }

// FinByID задает фиктивную реализацию поиска сообщения по ID
func (m *MockMessageRepo) FindByID(messageID uuid.UUID) (*entities.Message, error) {
	args := m.Called(messageID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Message), args.Error(1)
}

// CreateMessage задает фиктивную реализацию создания сообщения
func (m *MockMessageRepo) CreateMessage(message *entities.Message) error {
	args := m.Called(message)
	return args.Error(0)
}

// UpdateMessage задает фиктивную реализацию обновления сообщения
func (m *MockMessageRepo) UpdateMessage(message *entities.Message) error {
	args := m.Called(message)
	return args.Error(0)
}

// DeleteMessage задает фиктивную реализацию удаления сообщения
func (m *MockMessageRepo) DeleteMessage(message *entities.Message) error {
	args := m.Called(message)
	return args.Error(0)
}
