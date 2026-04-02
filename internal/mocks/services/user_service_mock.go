// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockCardService - структура для передачи в тестах
// фиктивной структуры сервиса UserService
type MockUserService struct{ mock.Mock }

// UpdateUserInfo задает фиктивную реализацию обновления данных пользователя
func (m *MockUserService) UpdateUserInfo(userID uuid.UUID, req *requests.UpdateUserRequest) error {
	args := m.Called(userID, req)
	return args.Error(0)
}

// GetUserInfo задает фиктивную реализацию получения информации о пользователе
func (m *MockUserService) GetUserInfo(userID uuid.UUID) (responses.GetUserInfoResponse, error) {
	args := m.Called(userID)
	return args.Get(0).(responses.GetUserInfoResponse), args.Error(1)
}
