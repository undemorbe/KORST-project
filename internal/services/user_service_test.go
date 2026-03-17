// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/mocks"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestUpdateUserInfo проверяет обновление данных
// определенного пользователя
func TestUpdateUserInfo(t *testing.T) {
	mockUserRepo := &mocks.MockUserRepo{}
	mockProfileRepo := &mocks.MockProfileRepo{}

	userService := NewUserService(mockUserRepo, mockProfileRepo)

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
		On("CreateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockUserRepo.
		On("UpdateUser", mock.AnythingOfType("*entities.User")).
		Return(nil)

	mockProfileRepo.
		On("CreateProfile", mock.AnythingOfType("*entities.Profile")).
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
}
