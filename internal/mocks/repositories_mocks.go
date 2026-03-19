// mocks - пакет, содержащий интерфейсы для
// изолированного проведения тестов
package mocks

import (
	"korst-backend/internal/entities"
	"time"

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

// MockCardRepository - структура для передачи в тестах
// фиктивной структуры репозитория CardRepository
type MockCardRepo struct{ mock.Mock }

// FindByID задает фиктивную реализацию поиска карточки по ID
func (m *MockCardRepo) FindByID(cardID uuid.UUID) (*entities.Card, error) {
	args := m.Called(cardID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Card), args.Error(1)
}

// FindСardsByTime задает фиктивную реализацию пагинации по времени
func (m *MockCardRepo) FindСardsByTime(key *time.Time, limit int) ([]entities.Card, error) {
	args := m.Called(key, limit)
	return args.Get(0).([]entities.Card), args.Error(1)
}

// CreateCard задает фиктивную реализацию создания сущности карточки
func (m *MockCardRepo) CreateCard(card *entities.Card) error {
	args := m.Called(card)
	return args.Error(0)
}

// UpdateCard задает фиктивную реализацию обновления карточки в БД
func (m *MockCardRepo) UpdateCard(card *entities.Card) error {
	args := m.Called(card)
	return args.Error(0)
}

// MockCardRepository - структура для передачи в тестах
// фиктивной структуры репозитория ProfileRepository
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
