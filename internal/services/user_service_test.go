// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	mockRepositories "korst-backend/internal/mocks/repositories"
	mockService "korst-backend/internal/mocks/services"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestUpdateUserInfo проверяет обновление данных
// определенного пользователя
func TestUpdateUserInfo(t *testing.T) {
	logger.InitLoggerTest()

	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockProfileRepo := &mockRepositories.MockProfileRepo{}
	mockFileService := &mockService.MockFileService{}

	userService := NewUserService(mockUserRepo, mockProfileRepo, mockFileService)

	userID := uuid.New()
	phone := "+79123456789"
	name := "Олег"
	surname := "Олегов"

	description := "Новое описание"
	telegram := "telegram"

	profile := &entities.Profile{
		Description: "Старое описание",
	}

	user := &entities.User{
		Phone: phone,
		Name:  "Вася",

		Profile: profile,
	}

	req := requests.UpdateUserRequest{
		Name:        &name,
		Surname:     &surname,
		Description: &description,
		Contacts: &requests.Contacts{
			Email:    nil,
			Telegram: &telegram,
			Others:   nil,
		},
	}

	mockUserRepo.On("FindByID", userID).Return(user, nil)

	mockUserRepo.
		On("UpdateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockProfileRepo.
		On("UpdateProfile", mock.AnythingOfType("*entities.Profile")).
		Return(nil)

	err := userService.UpdateUserInfo(userID, &req)

	require.NoError(t, err)
	require.Equal(t, user.Name, name)
	require.Equal(t, user.Surname, surname)

	require.Equal(t, profile.Description, description)
	require.Equal(t, profile.Telegram, telegram)
	require.Equal(t, profile.Email, "")
	mockUserRepo.AssertExpectations(t)
	mockProfileRepo.AssertExpectations(t)
}

// TestGetUserInfo проверяет получение информации о пользователе
func TestGetUserInfo(t *testing.T) {
	mockUserRepo := &mockRepositories.MockUserRepo{}
	mockProfileRepo := &mockRepositories.MockProfileRepo{}
	mockFileService := &mockService.MockFileService{}

	userService := NewUserService(mockUserRepo, mockProfileRepo, mockFileService)

	userID := uuid.New()
	name := "Олег"
	cardName := "Название карточки"
	telegram := "@oleg"

	profile := &entities.Profile{
		UserID:   userID,
		Telegram: telegram,
	}

	card := entities.Card{
		Name: cardName,
	}

	user := &entities.User{
		ID:      userID,
		Name:    name,
		Profile: profile,
		Cards:   []entities.Card{card},
	}

	mockUserRepo.
		On("FindWithCards", userID).
		Return(user, nil)

	response, err := userService.GetUserInfo(userID)

	require.NoError(t, err)
	require.Equal(t, name, response.Name)
	require.Equal(t, telegram, response.Contacts.Telegram)
	require.Equal(t, cardName, response.Cards[0].Name)
	mockUserRepo.AssertExpectations(t)
}
