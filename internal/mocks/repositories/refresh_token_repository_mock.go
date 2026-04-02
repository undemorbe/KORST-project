// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockRefreshTokenRepo - структура для передачи в тестах
// фиктивной структуры репозитория refreshTokenRepo
type MockRefreshTokenRepo struct{ mock.Mock }

// FindByToken задает фиктивную реализацию поиска по токену
func (m *MockRefreshTokenRepo) FindByToken(token string) (*entities.RefreshToken, error) {
	args := m.Called(token)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.RefreshToken), args.Error(1)
}

// CreateRefreshToken задает фиктивную реализацию создания токена
func (m *MockRefreshTokenRepo) CreateRefreshToken(refreshToken *entities.RefreshToken) error {
	args := m.Called(refreshToken)
	return args.Error(0)
}

// UpdateRefreshToken задает фиктивную реализацию обновления refresh-токена
func (m *MockRefreshTokenRepo) UpdateRefreshToken(refreshToken *entities.RefreshToken) error {
	args := m.Called(refreshToken)
	return args.Error(0)
}

// DeleteByUserID задает фиктивную реализацию удаления refresh-токенов
func (m *MockRefreshTokenRepo) DeleteByUserID(userID uuid.UUID) error {
	args := m.Called(userID)
	return args.Error(0)
}
