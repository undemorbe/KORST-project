// mocks - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mocks

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

// MockUserRepo - структура для передачи в тестах
// фиктивной структуры репозитория UserRepo
type MockUserRepo struct{ mock.Mock }

// FindByID задает фиктивную реализацию поиска по ID
func (m *MockUserRepo) FindByID(userID uuid.UUID) (*entities.User, error) {
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

// MockOtpRepo - структура для передачи в тестах
// фиктивной структуры репозитория OtpRepo
type MockOtpRepo struct{ mock.Mock }

// FindByPhone задает фиктивную реализацию поиска по телефону
func (m *MockOtpRepo) FindByPhone(phone string) (*entities.Otp, error) {
	args := m.Called(phone)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Otp), args.Error(1)
}

// CreateOTP задает фиктивную реализацию созданию Otp
func (m *MockOtpRepo) CreateOTP(otp *entities.Otp) error {
	args := m.Called(otp)
	return args.Error(0)
}

// UpdateOTP задает фиктивную реализацию обновления Otp
func (m *MockOtpRepo) UpdateOTP(otp *entities.Otp) error {
	args := m.Called(otp)
	return args.Error(0)
}

// MockRefreshTokenRepo - структура для передачи в тестах
// фиктивной структуры репозитория RefreshTokenRepo
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
