// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
)

// UserService - объект, содержащий методы для работы с пользователями
type UserService struct {
	userRepo    ports.UserRepository
	profileRepo ports.ProfileRepository
}

// NewUserService создает и возвращает новый объект UserService
func NewUserService(userRepo ports.UserRepository,
	profileRepo ports.ProfileRepository) ports.UserService {
	return &UserService{
		userRepo:    userRepo,
		profileRepo: profileRepo,
	}
}

// UpdateUserInfo обновляет (или дополняет) информацию
// о каком-то конкретном пользователе
func (s *UserService) UpdateUserInfo(
	userID uuid.UUID, req *requests.UpdateUserRequest) error {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return err
	}
	if user == nil {
		return errors.ErrorUserNotFound
	}

	profile := user.Profile

	if profile == nil {
		profile = &entities.Profile{
			UserID: userID,
		}

		err = s.profileRepo.CreateProfile(profile)
		if err != nil {
			return err
		}
	}

	if req.Name != nil {
		user.Name = *req.Name
	}
	if req.Surname != nil {
		user.Surname = *req.Surname
	}
	if req.Description != nil {
		profile.Description = *req.Description
	}

	user.Status = "user"

	if req.Contacts != nil {
		contacts := req.Contacts

		if contacts.Email != nil {
			profile.Email = *contacts.Email
		}
		if contacts.Telegram != nil {
			profile.Telegram = *contacts.Telegram
		}
		if contacts.Others != nil {
			profile.OtherContacts = *contacts.Others
		}
	}

	user.Profile = profile

	err = s.profileRepo.UpdateProfile(profile)
	if err != nil {
		return err
	}

	err = s.userRepo.UpdateUser(user)
	if err != nil {
		return err
	}

	return nil
}
