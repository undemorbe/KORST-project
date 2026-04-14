// mockServices - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mockServices

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockTokenService - структура для передачи в тестах
// фиктивной структуры сервиса TokenService
type MockTokenService struct{ mock.Mock }

// CreateTokens задает фиктивную реализацию создания refresh и access токенов
func (m *MockTokenService) CreateTokens(user *entities.User) (string, string, error) {
	args := m.Called(user)
	return args.String(0), args.String(1), args.Error(2)
}

// DecodeAccessToken задает фиктивную реализацию декодировки access-токена
func (m *MockTokenService) DecodeAccessToken(rawToken string) (uuid.UUID, error) {
	args := m.Called(rawToken)
	return args.Get(0).(uuid.UUID), args.Error(1)
}
