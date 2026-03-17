// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
)

// CardService - объект, содержащий методы для просмотра,
// создания и изменения карточек объявлений
type CardService struct {
	cardRepo     ports.CardRepository
	userRepo     ports.UserRepository
	tokenService ports.TokenService
}

// NewCardRepository создает и возвращает новый объект CardService
func NewCardRepository(
	cardRepo ports.CardRepository,
	userRepo ports.UserRepository,
	tokenService ports.TokenService) ports.CardService {
	return &CardService{
		cardRepo:     cardRepo,
		userRepo:     userRepo,
		tokenService: tokenService,
	}
}

// GetCards возвращает несколько сжатых карточек
// с объявлениями для просмотра пользователями
func (s *CardService) GetCards(page int) (
	responses.GetCardsResponse, error) {

	// TODO: нормально сделать пагинацию
	return responses.GetCardsResponse{}, nil
}

// GetCardInfo возвращает подробную информацию
// об одной конкретной карточке объявления
func (s *CardService) GetCardInfo(cardID uuid.UUID) (
	responses.CardInfoResponse, error) {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске карточки по ID", err)
		return responses.CardInfoResponse{}, err
	}

	if card == nil {
		logger.Log.Warn("Карточка с указанным ID не найдена")
		return responses.CardInfoResponse{}, errors.ErrorCardNotFound
	}

	createdDate := card.CreatedAt.Format("2006-01-02")
	updatedDate := card.UpdatedAt.Format("2006-01-02")

	author, err := s.getAuthor(card.UserID)
	if err != nil {
		logger.Log.Warn("Ошибка при получении автора карточки: ", err)
	}

	response := responses.CardInfoResponse{
		Name:        card.Name,
		Description: card.Description,

		Price:    card.Price,
		Currency: card.Currency,
		Type:     card.Type,

		Author: author,

		Tags: card.Tags,

		CreatedAt: createdDate,
		UpdatedAt: updatedDate,
	}

	return response, nil
}

func (s *CardService) getAuthor(userID uuid.UUID) (
	*responses.Author, error) {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return &responses.Author{},
			err
	}

	if user == nil {
		return &responses.Author{},
			errors.ErrorUserNotFound
	}

	profile := user.Profile
	if profile == nil {
		return &responses.Author{},
			errors.ErrorUserNotFound
	}

	contacts := &responses.Contacts{
		Email:    profile.Email,
		Telegram: profile.Telegram,

		Others: user.Profile.OtherContacts,
	}

	author := &responses.Author{
		ID:      userID.String(),
		Name:    user.Name,
		Surname: user.Surname,

		Phone:    user.Phone,
		Contacts: contacts,

		Rating: profile.Rating,
	}

	return author, nil
}

func (s *CardService) getCompressedCard(card entities.Card) (
	*responses.CompressedCard, error) {

	author, err := s.getCompressedAuthor(card.UserID)
	if err != nil {
		logger.Log.Warn("Ошибка при получении сжатой карточки: ", err)
		return &responses.CompressedCard{}, err
	}

	compressedCard := &responses.CompressedCard{
		ID:   card.ID.String(),
		Name: card.Name,

		Price:    card.Price,
		Currency: card.Currency,
		Type:     card.Type,

		Author: author,

		Tags:      card.Tags,
		CreatedAt: card.CreatedAt,
	}

	return compressedCard, nil
}

func (s *CardService) getCompressedAuthor(userID uuid.UUID) (
	*responses.CompressedAuthor, error) {

	author, err := s.getAuthor(userID)
	if err != nil {
		return &responses.CompressedAuthor{},
			err
	}

	compressedAuthor := &responses.CompressedAuthor{
		Name:    author.Name,
		Surname: author.Surname,

		Rating: author.Rating,
	}

	return compressedAuthor, nil
}
