// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/ports"

	"github.com/nyaruka/phonenumbers"
)

// AuthService - объект, содержащий методы для авторизации пользователей
type AuthService struct {
	userRepo ports.UserRepository
}

// NewAuthService создает и возвращает новый объект AuthService
func NewAuthService(userRepo ports.UserRepository) ports.AuthService {
	return &AuthService{userRepo: userRepo}
}

// CheckUser находит пользователя по телефону и проверяет его статус (notFound / notRegistered / registered)
func (s *AuthService) CheckUser(rawPhone string) (
	responses.IsUserResponse, error) {
	num, err := phonenumbers.Parse(rawPhone, "RU")
	if err != nil || !phonenumbers.IsValidNumber(num) {
		return responses.IsUserResponse{},
			errors.ErrorInvalidPhone
	}

	phone := phonenumbers.Format(num, phonenumbers.E164)

	user, err := s.userRepo.FindByPhone(phone)

	if err != nil {
		return responses.IsUserResponse{Status: "notFound"},
			errors.ErrorInternal
	}

	if user == nil {
		return responses.IsUserResponse{Status: "notFound"},
			nil
	}

	if user.IsRegistered == false {
		return responses.IsUserResponse{Status: "notRegistered"},
			nil
	}

	return responses.IsUserResponse{Status: "registered"},
		nil
}

// RegisterUser добавляет пользователя в БД или дополняет информацию о нем
func (s *AuthService) RegisterUser(req requests.RegisterRequest) error {
	num, err := phonenumbers.Parse(req.Phone, "RU")
	if err != nil || !phonenumbers.IsValidNumber(num) {
		return errors.ErrorInvalidPhone
	}

	phone := phonenumbers.Format(num, phonenumbers.E164)

	user, err := s.userRepo.FindByPhone(phone)

	if err != nil {
		return errors.ErrorInternal
	}

	if user == nil {
		newUser := &entities.User{
			Phone:        req.Phone,
			Name:         req.Name,
			Surname:      req.Surname,
			IsRegistered: true,
		}

		err = s.userRepo.CreateUser(newUser)
		return nil
	}

	if user.IsRegistered == true {
		return nil
	}

	user.Name = req.Name
	user.Surname = req.Surname
	user.IsRegistered = true

	err = s.userRepo.UpdateUser(user)
	return err
}
