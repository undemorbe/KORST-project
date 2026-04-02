// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	mockRepositories "korst-backend/internal/mocks/repositories"
	mockServices "korst-backend/internal/mocks/services"
	"testing"
	"time"

	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestVerifyOtp проверяет подтверждение корректного Otp
func TestVerifyOtp(t *testing.T) {
	logger.InitLoggerTest()

	mockOTPRepo := &mockRepositories.MockOtpRepo{}
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockTokenService := &mockServices.MockTokenService{}

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

	mockOTPRepo.
		On("UpdateOTP", mock.AnythingOfType("*entities.Otp")).
		Return(nil)

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

	mockOTPRepo.AssertExpectations(t)
	mockUserRepo.AssertExpectations(t)
	mockTokenService.AssertExpectations(t)
}

// TestVerifyExpiredOTP проверяет обработку истекшего Otp
func TestVerifyExpiredOTP(t *testing.T) {
	mockOTPRepo := &mockRepositories.MockOtpRepo{}
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockTokenService := &mockServices.MockTokenService{}

	otpService := NewOTPService(mockOTPRepo, mockUserRepo, mockTokenService)

	rawPhone := "+79123456789"
	otpCode := "123456"

	otpEntity := &entities.Otp{
		Phone:     rawPhone,
		Code:      otpCode,
		ExpiresAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	mockOTPRepo.On("FindByPhone", rawPhone).Return(otpEntity, nil)

	mockTokenService.
		On("CreateTokens", mock.AnythingOfType("*entities.User")).
		Return("access", "refresh", nil)

	_, err := otpService.VerifyOTP(rawPhone, otpCode)

	require.Equal(t, err, errors.ErrorOTPExpired)
	mockOTPRepo.AssertExpectations(t)
}

// TestVerifyIncorrectOTP проверяет обработку неверного Otp
func TestVerifyIncorrectOTP(t *testing.T) {
	mockOTPRepo := &mockRepositories.MockOtpRepo{}
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockTokenService := &mockServices.MockTokenService{}

	otpService := NewOTPService(mockOTPRepo, mockUserRepo, mockTokenService)

	rawPhone := "+79123456789"
	otpCode := "123456"

	otpEntity := &entities.Otp{
		Phone:     rawPhone,
		Code:      "111111",
		ExpiresAt: time.Now().UTC().Add(-2 * time.Minute),
	}

	mockOTPRepo.On("FindByPhone", rawPhone).Return(otpEntity, nil)

	_, err := otpService.VerifyOTP(rawPhone, otpCode)

	require.Equal(t, err, errors.ErrorOTPIncorrect)
	mockOTPRepo.AssertExpectations(t)
}
