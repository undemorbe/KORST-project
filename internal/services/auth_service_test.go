// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/mocks"
	"testing"

	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestCheckRegisteredUser проверяет проверку статуса
// зарегистрированного пользователя
func TestCheckRegisteredUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

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
}

// TestCheckRegisteredUser проверяет проверку статуса
// незарегистрированного пользователя
func TestCheckNotRegisteredUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

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
}

// TestCheckRegisteredUser проверяет проверку статуса
// несуществующего пользователя
func TestCheckNotFoundUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79122222222"

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "notFound")
}

// TestRegisterExistingUser проверяет дополнения
// информации о существующем пользователе
func TestRegisterExistingUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79123456789"
	name := "Олег"
	surname := "Олегович"

	user := &entities.User{
		Phone: rawPhone,
	}

	req := requests.RegisterRequest{
		Name:    name,
		Surname: surname,
		Phone:   rawPhone,
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(user, nil)

	mockUserRepo.
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockUserRepo.
		On("UpdateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	err := authService.RegisterUser(req)

	require.NoError(t, err)
	require.Equal(t, user.Name, name)
	require.Equal(t, user.Surname, surname)
}

// TestRegisterNewUser проверяет регистрацию
// нового пользователя
func TestRegisterNewUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79123456789"
	name := "Олег"
	surname := "Олегович"

	req := requests.RegisterRequest{
		Name:    surname,
		Surname: name,
		Phone:   rawPhone,
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(nil, nil)

	mockUserRepo.
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockUserRepo.
		On("UpdateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	err := authService.RegisterUser(req)

	require.NoError(t, err)
}
