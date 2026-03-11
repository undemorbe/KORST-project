package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/mocks"
	"testing"

	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

func TestCheckRegisteredUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79123456789"

	user := &entities.User{
		Phone:        rawPhone,
		IsRegistered: true,
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(user, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "registered")
}

func TestCheckNotRegisteredUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79121111111"
	user := &entities.User{
		Phone:        rawPhone,
		IsRegistered: false,
	}

	mockUserRepo.On("FindByPhone", rawPhone).Return(user, nil)

	response, err := authService.CheckUser(rawPhone)

	require.NoError(t, err)
	require.Equal(t, response.Status, "notRegistered")
}

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

func TestRegisterExistingUser(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockRefreshTokenRepo := &mocks.MockRefreshTokenRepo{}
	mockTokenService := &mocks.MockTokenService{}

	authService := NewAuthService(mockUserRepo, mockRefreshTokenRepo, mockTokenService)

	rawPhone := "+79123456789"
	name := "Олег"
	surname := "Олегович"

	user := &entities.User{
		Phone:        rawPhone,
		IsRegistered: false,
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
