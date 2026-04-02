// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/dto/responses"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockAuthService - структура для передачи в тестах
// фиктивной структуры сервиса AuthService
type MockAuthService struct{ mock.Mock }

// CheckUser задает фиктивную реализацию проверки статуса пользователя
func (m *MockAuthService) CheckUser(rawPhone string) (responses.IsUserResponse, error) {
	args := m.Called(rawPhone)
	return args.Get(0).(responses.IsUserResponse), args.Error(1)
}

// GetNewTokens задает фиктивную реализацию генерации токенов
func (m *MockAuthService) GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error) {
	args := m.Called(refreshTokenStr)
	return args.Get(0).(responses.RefreshResponse), args.Error(1)
}

// RemoveRefreshToken задает фиктивную реализацию удаления access-токена
func (m *MockAuthService) RemoveRefreshToken(userID uuid.UUID) error {
	args := m.Called(userID)
	return args.Error(0)
}
