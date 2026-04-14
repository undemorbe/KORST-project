// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockReviewService - структура для передачи в тестах
// фиктивной структуры сервиса ReviewService
type MockReviewService struct{ mock.Mock }

// GetReviews задает фиктивную реализацию получения отзывов
func (m *MockReviewService) GetReviews(userID uuid.UUID) (responses.GetReviewsResponse, error) {
	args := m.Called(userID)
	return args.Get(0).(responses.GetReviewsResponse), args.Error(1)
}

// PostReview задает фиктивную реализацию размещения отзыва
func (m *MockReviewService) PostReview(authorID uuid.UUID, req *requests.PostReviewRequest) error {
	args := m.Called(authorID, req)
	return args.Error(0)
}
