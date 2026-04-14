// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockReviewRepo - структура для передачи в тестах
// фиктивной структуры репозитория reviewRepo
type MockReviewRepo struct{ mock.Mock }

// FindReviewToUser задает фиктивную реализацию поиска определенного отзыва
func (m *MockReviewRepo) FindReviewToUser(authorID uuid.UUID,
	relatedToID uuid.UUID) (*entities.Review, error) {
	args := m.Called(authorID, relatedToID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Review), args.Error(1)
}

// CreateReview задает фиктивную реализацию создания сущности отзыва
func (m *MockReviewRepo) CreateReview(review *entities.Review) error {
	args := m.Called(review)
	return args.Error(0)
}

// UpdateReview задает фиктивную реализацию обновления сущности отзыва
func (m *MockReviewRepo) UpdateReview(review *entities.Review) error {
	args := m.Called(review)
	return args.Error(0)
}
