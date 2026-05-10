// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockReplyService - структура для передачи в тестах
// фиктивной структуры сервиса ReplyService
type MockReplyService struct{ mock.Mock }

// CreateReply задает фиктивную реализацию создания отклика
func (m *MockReplyService) CreateReply(authorID uuid.UUID, cardID uuid.UUID) error {
	args := m.Called(authorID, cardID)
	return args.Error(0)
}

// GetExecutors получает всех исполниелей для определенной карточки
func (m *MockReplyService) GetExecutors(cardID uuid.UUID) (responses.GetExecutorsResponse, error) {
	args := m.Called(cardID)
	return args.Get(0).(responses.GetExecutorsResponse), args.Error(1)
}

// ApproveExecutor задает фиктивную реализацию утверждения исполнителя
func (m *MockReplyService) ApproveExecutor(authorID uuid.UUID, cardID uuid.UUID, executorID uuid.UUID) error {
	args := m.Called(authorID, cardID, executorID)
	return args.Error(0)
}

// RejectExecutor задает фиктивную реализацию отклонения отклика
func (m *MockReplyService) RejectExecutor(authorID uuid.UUID, cardID uuid.UUID, executorID uuid.UUID) error {
	args := m.Called(authorID, cardID, executorID)
	return args.Error(0)
}

// CloseCard задает фиктивную реализацию закрытия карточки
func (m *MockReplyService) CloseCard(authorID uuid.UUID, cardID uuid.UUID, status string) error {
	args := m.Called(authorID, cardID, status)
	return args.Error(0)
}
