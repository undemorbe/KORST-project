package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/mocks"
	"testing"
	"time"

	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

func TestVerifyOtp(t *testing.T) {
	mockOTPRepo := &mocks.MockOtpRepo{}
	mockUserRepo := &mocks.MockUserRepo{}
	mockTokenService := &mocks.MockTokenService{}

	otpService := NewOTPService(mockOTPRepo, mockUserRepo, mockTokenService)

	rawPhone := "+79123456789"
	otpCode := "123456"

	otpEntity := &entities.Otp{
		Phone:     rawPhone,
		Code:      otpCode,
		ExpiresAt: time.Now().UTC().Add(2 * time.Minute),
	}

	mockOTPRepo.On("FindByPhone", rawPhone).Return(otpEntity, nil)

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	mockUserRepo.
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockTokenService.
		On("CreateTokens", mock.AnythingOfType("*entities.User")).
		Return("access", "refresh", nil)

	response, err := otpService.VerifyOTP(rawPhone, otpCode)

	require.NoError(t, err)
	require.Equal(t, response.AccessToken, "access")
	require.Equal(t, response.RefreshToken, "refresh")
	require.Equal(t, response.Status, "notRegistered")
}

func TestVerifyExpiredOTP(t *testing.T) {
	mockOTPRepo := &mocks.MockOtpRepo{}
	mockUserRepo := &mocks.MockUserRepo{}
	mockTokenService := &mocks.MockTokenService{}

	otpService := NewOTPService(mockOTPRepo, mockUserRepo, mockTokenService)

	rawPhone := "+79123456789"
	otpCode := "123456"

	otpEntity := &entities.Otp{
		Phone:     rawPhone,
		Code:      otpCode,
		ExpiresAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	mockOTPRepo.On("FindByPhone", rawPhone).Return(otpEntity, nil)

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	mockUserRepo.
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockTokenService.
		On("CreateTokens", mock.AnythingOfType("*entities.User")).
		Return("access", "refresh", nil)

	_, err := otpService.VerifyOTP(rawPhone, otpCode)

	require.Equal(t, err, errors.ErrorOTPExpired)
}

func TestVerifyIncorrectOTP(t *testing.T) {
	mockOTPRepo := &mocks.MockOtpRepo{}
	mockUserRepo := &mocks.MockUserRepo{}
	mockTokenService := &mocks.MockTokenService{}

	otpService := NewOTPService(mockOTPRepo, mockUserRepo, mockTokenService)

	rawPhone := "+79123456789"
	otpCode := "123456"

	otpEntity := &entities.Otp{
		Phone:     rawPhone,
		Code:      "111111",
		ExpiresAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	mockOTPRepo.On("FindByPhone", rawPhone).Return(otpEntity, nil)

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	mockUserRepo.
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockTokenService.
		On("CreateTokens", mock.AnythingOfType("*entities.User")).
		Return("access", "refresh", nil)

	_, err := otpService.VerifyOTP(rawPhone, otpCode)

	require.Equal(t, err, errors.ErrorOTPIncorrect)
}
