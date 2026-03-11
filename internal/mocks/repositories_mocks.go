package mocks

import (
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

type MockUserRepo struct{ mock.Mock }

func (m *MockUserRepo) FindByID(userID uuid.UUID) (*entities.User, error) {
	args := m.Called(userID)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}
func (m *MockUserRepo) FindByPhone(phone string) (*entities.User, error) {
	args := m.Called(phone)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.User), args.Error(1)
}

func (m *MockUserRepo) CreateUser(user *entities.User) error {
	args := m.Called(user)
	return args.Error(0)
}
func (m *MockUserRepo) UpdateUser(user *entities.User) error {
	args := m.Called(user)
	return args.Error(0)
}

type MockOtpRepo struct{ mock.Mock }

func (m *MockOtpRepo) FindByPhone(phone string) (*entities.Otp, error) {
	args := m.Called(phone)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.Otp), args.Error(1)
}
func (m *MockOtpRepo) CreateOTP(otp *entities.Otp) error {
	args := m.Called(otp)
	return args.Error(0)
}

type MockRefreshTokenRepo struct{ mock.Mock }

func (m *MockRefreshTokenRepo) FindByToken(token string) (*entities.RefreshToken, error) {
	args := m.Called(token)

	if args.Get(0) == nil {
		return nil, args.Error(1)
	}

	return args.Get(0).(*entities.RefreshToken), args.Error(1)
}
func (m *MockRefreshTokenRepo) CreateRefreshToken(refreshToken *entities.RefreshToken) error {
	args := m.Called(refreshToken)
	return args.Error(0)
}
func (m *MockRefreshTokenRepo) UpdateRefreshToken(refreshToken *entities.RefreshToken) error {
	args := m.Called(refreshToken)
	return args.Error(0)
}
func (m *MockRefreshTokenRepo) DeleteByUserID(userID uuid.UUID) error {
	args := m.Called(userID)
	return args.Error(0)
}
