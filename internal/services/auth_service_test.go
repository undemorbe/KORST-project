// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/entities"
	mockRepositories "korst-backend/internal/mocks/repositories"
	mockServices "korst-backend/internal/mocks/services"
	"testing"

	"github.com/stretchr/testify/require"
)

// TestCheckRegisteredUser проверяет проверку статуса
// зарегистрированного пользователя
func TestCheckRegisteredUser(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockRefreshTokenRepo := &mockRepositories.MockRefreshTokenRepo{}
	mockTokenService := &mockServices.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79123456789"

	user := &entities.User{
		Phone:   rawPhone,
		Name:    "Олег",
		Surname: "Олегович",
		Status:  "user",
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(user, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "user")
	mockUserRepo.AssertExpectations(t)
}

// TestCheckRegisteredUser проверяет проверку статуса
// незарегистрированного пользователя
func TestCheckNotRegisteredUser(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockRefreshTokenRepo := &mockRepositories.MockRefreshTokenRepo{}
	mockTokenService := &mockServices.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79121111111"
	user := &entities.User{
		Phone:  rawPhone,
		Status: "notRegistered",
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(user, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "notRegistered")
	mockUserRepo.AssertExpectations(t)
}

// TestCheckRegisteredUser проверяет проверку статуса
// несуществующего пользователя
func TestCheckNotFoundUser(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockRefreshTokenRepo := &mockRepositories.MockRefreshTokenRepo{}
	mockTokenService := &mockServices.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79122222222"

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "notFound")
	mockUserRepo.AssertExpectations(t)
}
