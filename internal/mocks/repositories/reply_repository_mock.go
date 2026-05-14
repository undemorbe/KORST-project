// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockReplyRepo - структура для передачи в тестах
// фиктивной структуры репозитория replyRepo
type MockReplyRepo struct{ mock.Mock }

// FindByAuthorAndCard задает фиктивную реализацию поиска отклика
func (m *MockReplyRepo) FindByAuthorAndCard(authorID uuid.UUID, cardID uuid.UUID) (*entities.Reply, error) {
	args := m.Called(authorID, cardID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Reply), args.Error(1)
}

// CreateReply задает фиктивную реализацию создания отклика в БД
func (m *MockReplyRepo) CreateReply(reply *entities.Reply) error {
	args := m.Called(reply)
	return args.Error(0)
}

// UpdateReply задает фиктивную реализацию обновления отклика в БД
func (m *MockReplyRepo) UpdateReply(reply *entities.Reply) error {
	args := m.Called(reply)
	return args.Error(0)
}
