package mocks

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
)

type MockOTPService struct{ mock.Mock }

func (m *MockOTPService) SendOTP(rawPhone string) error {
	args := m.Called(rawPhone)
	return args.Error(0)
}

func (m *MockOTPService) VerifyOTP(rawPhone string, otp string) (
	responses.VerifyOTPResponse, error) {
	args := m.Called(rawPhone, otp)
	return args.Get(0).(responses.VerifyOTPResponse), args.Error(1)
}

type MockAuthService struct{ mock.Mock }

func (m *MockAuthService) CheckUser(rawPhone string) (responses.IsUserResponse, error) {
	args := m.Called(rawPhone)
	return args.Get(0).(responses.IsUserResponse), args.Error(1)
}

func (m *MockAuthService) RegisterUser(req requests.RegisterRequest) error {
	args := m.Called(req)
	return args.Error(0)
}

func (m *MockAuthService) GetNewTokens(refreshTokenStr string) (responses.RefreshResponse, error) {
	args := m.Called(refreshTokenStr)
	return args.Get(0).(responses.RefreshResponse), args.Error(1)
}

type MockTokenService struct{ mock.Mock }

func (m *MockTokenService) CreateTokens(user *entities.User) (string, string, error) {
	args := m.Called(user)
	return args.String(0), args.String(1), args.Error(2)
}

func (m *MockTokenService) DecodeAccessToken(rawToken string) (uuid.UUID, error) {
	args := m.Called(rawToken)
	return args.Get(0).(uuid.UUID), args.Error(1)
}
