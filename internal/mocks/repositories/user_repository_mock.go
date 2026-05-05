// mockRepositories - пакет, содержащий интерфейсы
// репозиториев для изолированного проведения тестов
package mockRepositories

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockUserRepo - структура для передачи в тестах
// фиктивной структуры репозитория userRepo
type MockUserRepo struct{ mock.Mock }

// FindByID задает фиктивную реализацию поиска по ID
func (m *MockUserRepo) FindByID(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// FindWithCards задает фиктивную реализацию поиска по ID с активными карточками
func (m *MockUserRepo) FindWithCards(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// FindWithAllCards задает фиктивную реализацию поиска по ID со всеми карточками
func (m *MockUserRepo) FindWithAllCards(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// FindWithRelatedReviews задает фиктивную реализацию поиска по ID с отзывами на пользователя
func (m *MockUserRepo) FindWithRelatedReviews(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// FindWithChats задает фиктивную реализацию поиска по ID с отзывами на пользователя
func (m *MockUserRepo) FindWithChats(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// FindByPhone задает фиктивную реализацию поиска по телефону
func (m *MockUserRepo) FindByPhone(phone string) (*entities.User, error) {
	args := m.Called(phone)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

// CreateUser задает фиктивную реализацию создания пользователя
func (m *MockUserRepo) CreateUser(user *entities.User) error {
	args := m.Called(user)
	return args.Error(0)
}

// UpdateUser задает фиктивную реализацию обновления пользователя
func (m *MockUserRepo) UpdateUser(user *entities.User) error {
	args := m.Called(user)
	return args.Error(0)
}
