// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/stretchr/testify/mock"
)

// MockProfileRepo - структура для передачи в тестах
// фиктивной структуры репозитория profileRepo
type MockProfileRepo struct{ mock.Mock }

// CreateProfile задает фиктивную реализацию обновления профиля пользователя в БД
func (m *MockProfileRepo) CreateProfile(profile *entities.Profile) error {
	args := m.Called(profile)
	return args.Error(0)
}

// UpdateProfile задает фиктивную реализацию обновления профиля пользователя в БД
func (m *MockProfileRepo) UpdateProfile(profile *entities.Profile) error {
	args := m.Called(profile)
	return args.Error(0)
}
