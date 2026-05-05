// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"io"
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"os"
	"time"

	"github.com/google/uuid"
)

// UserService - объект, содержащий методы для работы с пользователями
type UserService struct {
	userRepo    ports.UserRepository
	profileRepo ports.ProfileRepository
	fileService ports.FileService
}

// NewUserService создает и возвращает новый объект UserService
func NewUserService(userRepo ports.UserRepository,
	profileRepo ports.ProfileRepository,
	fileService ports.FileService) ports.UserService {
	return &UserService{
		userRepo:    userRepo,
		profileRepo: profileRepo,
		fileService: fileService,
	}
}

// UpdateUserInfo обновляет (или дополняет) информацию
// о каком-то конкретном пользователе
func (s *UserService) UpdateUserInfo(
	userID uuid.UUID, req *requests.UpdateUserRequest) error {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return err
	}
	if user == nil {
		logger.Log.Warn("Пользователь с указанным ID не найден")
		return errors.ErrorUserNotFound
	}

	profile := user.Profile

	if profile == nil {
		profile = &entities.Profile{
			UserID: userID,
		}

		err = s.profileRepo.CreateProfile(profile)
		if err != nil {
			logger.Log.Error("Ошибка при создании профиля: ", err)
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

	user.Status = entities.UserStatusActive

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

	profile.UpdatedAt = time.Now().UTC()
	user.Profile = profile

	err = s.profileRepo.UpdateProfile(profile)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении прифиля пользователя: ", err)
		return err
	}

	err = s.userRepo.UpdateUser(user)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении пользователя: ", err)
		return err
	}

	return nil
}

// SaveImage вызывает FileService для сохранения изображения в
// хранилище, сохраняет ссылку на него в профиле пользователя в БД
func (s *UserService) SaveImage(userID uuid.UUID,
	file io.Reader, fileName string) (string, error) {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return "", err
	}

	if user == nil {
		logger.Log.Warn("Указанный пользователь не найден")
		return "", errors.ErrorUserNotFound
	}

	profile := user.Profile

	if profile == nil {
		logger.Log.Warn("Профиль пользователя не найден")
		return "", errors.ErrorUserNotFound
	}

	url, err := s.fileService.SaveProfileImage(file, fileName, userID)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении изображения в профиле: ", err)
		return "", err
	}

	profile.ImageURL = url
	profile.UpdatedAt = time.Now().UTC()

	err = s.profileRepo.UpdateProfile(profile)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении профиля пользователя: ", err)
		return "", err
	}

	baseURL := os.Getenv("BASE_URL")

	return baseURL + url, nil
}

// GetUserInfo получает подробную информацию
// о каком-то конкретном пользователе
func (s *UserService) GetUserInfo(userID uuid.UUID) (
	responses.GetUserInfoResponse, error) {

	user, err := s.userRepo.FindWithCards(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return responses.GetUserInfoResponse{}, err
	}
	if user == nil {
		logger.Log.Warn("Пользователь с указанным ID не найден")
		return responses.GetUserInfoResponse{},
			errors.ErrorUserNotFound
	}

	return s.convertUser(user), nil
}

// GetMyInfo получает расширенную информацию о
// текущем пользователе для предоставления статистики
func (s *UserService) GetMyInfo(userID uuid.UUID) (
	responses.GetMyInfoResponse, error) {

	var response responses.GetMyInfoResponse

	user, err := s.userRepo.FindWithAllCards(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return responses.GetMyInfoResponse{}, err
	}
	if user == nil {
		logger.Log.Warn("Пользователь с указанным ID не найден")
		return responses.GetMyInfoResponse{},
			errors.ErrorUserNotFound
	}

	response.GetUserInfoResponse = s.convertUser(user)

	return response, nil
}

// convertUser преобразовывает данные о пользователе
// к нужному формату для ответа на запрос
func (s *UserService) convertUser(user *entities.User) responses.GetUserInfoResponse {

	var response responses.GetUserInfoResponse

	response.Name = user.Name
	response.Surname = user.Surname
	response.Phone = user.Phone

	profile := user.Profile

	if profile != nil {
		response.Description = profile.Description
		response.Rating = profile.Rating

		contacts := &responses.Contacts{
			Telegram: profile.Telegram,
			Email:    profile.Email,

			Others: profile.OtherContacts,
		}

		response.Contacts = contacts
		response.UpdatedAt = profile.UpdatedAt
		response.CreatedAt = profile.CreatedAt
	}

	baseURL := os.Getenv("BASE_URL")

	if profile.ImageURL != "" {
		response.ImageURL = baseURL + profile.ImageURL
	}

	cards := user.Cards

	for _, card := range cards {
		convertedCard := s.getCompressedCard(&card)
		convertedCard.Status = string(card.Status)

		response.Cards = append(response.Cards, convertedCard)
	}

	return response
}

// getCompressedCard преобразовывает карточку к
// формату CompressedCard для ответа на запрос
func (s *UserService) getCompressedCard(
	card *entities.Card) responses.CompressedCard {

	compressedCard := responses.CompressedCard{
		ID:   card.ID.String(),
		Name: card.Name,

		Price:    card.Price,
		Currency: card.Currency,
		Type:     card.Type,

		Tags: card.Tags,

		CreatedAt: card.CreatedAt,
		UpdatedAt: card.UpdatedAt,
	}

	baseURL := os.Getenv("BASE_URL")

	if card.ImageURL != "" {
		compressedCard.ImageURL = baseURL + card.ImageURL
	}

	return compressedCard
}
