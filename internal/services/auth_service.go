// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"github.com/nyaruka/phonenumbers"
)

// AuthService - объект, содержащий методы для авторизации пользователей
type AuthService struct {
	userRepo         ports.UserRepository
	refreshTokenRepo ports.RefreshTokenRepository
	TokenService     ports.TokenService
}

// NewAuthService создает и возвращает новый объект AuthService
func NewAuthService(userRepo ports.UserRepository,
	refreshTokenRepo ports.RefreshTokenRepository,
	TokenService ports.TokenService) ports.AuthService {
	return &AuthService{
		userRepo:         userRepo,
		refreshTokenRepo: refreshTokenRepo,
		TokenService:     TokenService,
	}
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
			err
	}

	status := s.GetUserStatus(user)
	return responses.IsUserResponse{Status: status},
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
		return err
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

// GetNewTokens получает новые access и refresh токены для пользователя
func (s *AuthService) GetNewTokens(
	refreshTokenStr string) (responses.RefreshResponse, error) {

	refreshToken, err := s.refreshTokenRepo.FindByToken(refreshTokenStr)
	if err != nil {
		logger.Log.Error("Ошибка при обращении к БД: ", err)
		return responses.RefreshResponse{}, errors.ErrorInternal
	}
	if refreshToken == nil {
		logger.Log.Error("Указанный refresh-токен не найден")
		return responses.RefreshResponse{}, errors.ErrorUserNotFound
	}

	user, err := s.userRepo.FindByID(refreshToken.UserID)
	if err != nil {
		logger.Log.Error("Ошибка при обращении к БД: ", err)
		return responses.RefreshResponse{}, errors.ErrorInternal
	}
	if user == nil {
		logger.Log.Error("Пользователь не был найден")
		return responses.RefreshResponse{}, errors.ErrorUserNotFound
	}

	accessToken, refreshTokenStr, err := s.TokenService.CreateTokens(user)
	if err != nil {
		logger.Log.Error("Ошибка при получении обновлении: ", err)
		return responses.RefreshResponse{}, err
	}

	response := responses.RefreshResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshTokenStr,
	}
	return response, err
}

// GetUserStatus проверяет, зарегистрирован ли пользователь
func (s *AuthService) GetUserStatus(user *entities.User) string {
	switch {
	case user == nil:
		return "notFound"
	case !user.IsRegistered:
		return "notRegistered"
	default:
		return "registered"
	}
}
