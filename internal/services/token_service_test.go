// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/mocks"
	"os"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestGenerateAndDecodeAccessToken проверяет
// генерацию и декодирование access-токена
func TestGenerateAndDecodeAccessToken(t *testing.T) {
	logger.InitLoggerTest()

	os.Setenv("JWT_TOKEN_KEY", "test-secret-key")

	tokenService := &TokenService{}
	userID := uuid.New()

	token, err := tokenService.generateAccessToken(userID)

	require.NoError(t, err)
	require.NotEmpty(t, token)

	decodedUserID, err := tokenService.DecodeAccessToken(token)

	require.NoError(t, err)
	require.Equal(t, userID, decodedUserID)
}

// TestGenerateRefreshToken проверяет генерацию refresh-токена
func TestGenerateRefreshToken(t *testing.T) {
	logger.InitLoggerTest()

	tokenService := &TokenService{}

	token, err := tokenService.generateRefreshToken()

	require.NoError(t, err)
	require.Equal(t, len(token), 64)
}

// TestDecodingInvalidAccessToken проверяет декодирование
// некорректного access-токена
func TestDecodingInvalidAccessToken(t *testing.T) {
	logger.InitLoggerTest()

	tokenService := &TokenService{}

	// Если access-token - Случайная строка
	token := "r59h8bw4hj869w59it6jw9hjt69w85h"

	_, err := tokenService.DecodeAccessToken(token)

	require.Equal(t, err, errors.ErrorInvalidInput)

	// Если ключ для JWT не совпадает
	os.Setenv("JWT_TOKEN_KEY", "incorrect-key")

	userID := uuid.New()
	token, err = tokenService.generateAccessToken(userID)

	os.Setenv("JWT_TOKEN_KEY", "correct-key")

	userID, err = tokenService.DecodeAccessToken(token)

	require.Equal(t, err, errors.ErrorInvalidInput)
}

// TestCreateToken проверяет общую работу TokenService
func TestCreateTokens(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}

	tokenService := NewTokenService(mockUserRepo, mockRefreshTokenRepo)

	userID := uuid.New()

	user := &entities.User{
		ID:    userID,
		Phone: "+79123456789",
	}

	mockRefreshTokenRepo.On("DeleteByUserID", userID).Return(nil)

	mockRefreshTokenRepo.
		On("CreateRefreshToken", mock.AnythingOfType("*entities.RefreshToken")).
		Return(nil)

	mockUserRepo.
		On("UpdateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	accessToken, refreshToken, err := tokenService.CreateTokens(user)

	require.NoError(t, err)
	require.NotEmpty(t, accessToken)
	require.NotEmpty(t, refreshToken)

	decodedUserID, err := tokenService.DecodeAccessToken(accessToken)

	require.NoError(t, err)
	require.Equal(t, userID, decodedUserID)
}
