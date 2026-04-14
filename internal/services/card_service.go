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
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
)

// CardService - объект, содержащий методы для просмотра,
// создания и изменения карточек объявлений
type CardService struct {
	cardRepo    ports.CardRepository
	userRepo    ports.UserRepository
	fileService ports.FileService
}

// NewCardService создает и возвращает новый объект CardService
func NewCardService(
	cardRepo ports.CardRepository,
	userRepo ports.UserRepository,
	fileService ports.FileService) ports.CardService {
	return &CardService{
		cardRepo:    cardRepo,
		userRepo:    userRepo,
		fileService: fileService,
	}
}

// SaveCard сохраняет карточку объявления, созданную пользователем
func (s *CardService) SaveCard(userID uuid.UUID,
	req *requests.SaveCardRequest) error {

	newCard := entities.Card{
		UserID: userID,
		Name:   req.Name,

		Price:    req.Price,
		Currency: req.Currency,
		Type:     req.Type,
		Tags:     pq.StringArray(req.Tags),
	}

	if req.Description != nil {
		newCard.Description = *req.Description
	}

	return s.cardRepo.CreateCard(&newCard)
}

// UpdateCard обновляет данные определенной карточки объявления
func (s *CardService) UpdateCard(userID uuid.UUID,
	req *requests.UpdateCardRequest) error {

	card, err := s.cardRepo.FindByID(req.CardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске карточки: ", err)
		return err
	}

	if userID != card.UserID {
		logger.Log.Warn("Попытка изменить чужую карточку")
		return errors.ErrorForbidden
	}

	if req.Name != nil {
		card.Name = *req.Name
	}
	if req.Description != nil {
		card.Description = *req.Description
	}

	if req.Price != nil {
		card.Price = *req.Price
	}
	if req.Currency != nil {
		card.Currency = *req.Currency
	}
	if req.Type != nil {
		card.Type = *req.Type
	}
	if req.Tags != nil {
		card.Tags = *req.Tags
	}

	card.UpdatedAt = time.Now().UTC()

	err = s.cardRepo.UpdateCard(card)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении карточки в БД: ", err)
		return err
	}

	return nil
}

// SaveImage вызывает FileService для сохранения изображения,
// сохраняет ссылку на картинку для карточки в БД
func (s *CardService) SaveImage(cardID uuid.UUID,
	file io.Reader, fileName string) (string, error) {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске карточки: ", err)
		return "", err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return "", errors.ErrorCardNotFound
	}

	url, err := s.fileService.SaveCardImage(file, fileName, cardID)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении изображения карточки: ", err)
		return "", err
	}

	card.ImageURL = url
	card.UpdatedAt = time.Now().UTC()

	err = s.cardRepo.UpdateCard(card)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении карточки: ", err)
		return "", err
	}

	baseURL := os.Getenv("BASE_URL")

	return baseURL + url, nil
}

// GetCards возвращает несколько сжатых карточек
// с объявлениями для просмотра пользователями
func (s *CardService) GetCards(key *time.Time, query *string) (
	responses.GetCardsResponse, error) {

	response := responses.GetCardsResponse{
		Cards: []responses.CompressedCard{},
	}

	limit, err := strconv.Atoi(os.Getenv("CARD_LIMIT"))
	if err != nil {
		return responses.GetCardsResponse{},
			errors.ErrorInternal
	}

	var cards []entities.Card

	if query != nil && len(*query) > 0 {
		cards, err = s.cardRepo.FindCardsByQuery(key, *query, limit)
	} else {
		cards, err = s.cardRepo.FindCardsByTime(key, limit)
	}

	if err != nil {
		return responses.GetCardsResponse{},
			err
	}

	for i := range cards {
		card, err := s.getCompressedCard(&cards[i])
		if err != nil {
			logger.Log.Warn("Ошибка при обработке карточки: ", err)
			continue
		}

		response.Cards = append(response.Cards, card)
	}

	return response, nil
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

	baseURL := os.Getenv("BASE_URL")

	if card.ImageURL != "" {
		response.ImageURL = baseURL + card.ImageURL
	}

	return response, nil
}

// getAuthor находит автора карточки и приводит его к
// формату Author, необходимому для response
func (s *CardService) getAuthor(userID uuid.UUID) (
	*responses.Author, error) {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		return &responses.Author{},
			err
	}

	if user == nil {
		logger.Log.Warn("Автор карточки не был найден")
		return &responses.Author{},
			errors.ErrorUserNotFound
	}

	profile := user.Profile
	if profile == nil {
		logger.Log.Warn("Профиль автора не был найден")
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

	baseURL := os.Getenv("BASE_URL")

	if profile.ImageURL != "" {
		author.ImageURL = baseURL + profile.ImageURL
	}

	return author, nil
}

// getCompressedCard приводит карточку объявления к формату CompressedCard
func (s *CardService) getCompressedCard(card *entities.Card) (
	responses.CompressedCard, error) {

	author, err := s.getCompressedAuthor(card.UserID)
	if err != nil {
		logger.Log.Warn("Ошибка при получении сжатой карточки: ", err)
		return responses.CompressedCard{}, err
	}

	compressedCard := responses.CompressedCard{
		ID:   card.ID.String(),
		Name: card.Name,

		Price:    card.Price,
		Currency: card.Currency,
		Type:     card.Type,

		Author: author,

		Tags:      card.Tags,
		CreatedAt: card.CreatedAt,
		UpdatedAt: card.UpdatedAt,
	}

	baseURL := os.Getenv("BASE_URL")

	if card.ImageURL != "" {
		compressedCard.ImageURL = baseURL + card.ImageURL
	}

	return compressedCard, nil
}

// getCompressedAuthor приводит автора карточки к формату
// CompressedAuthor, необходимому для response
func (s *CardService) getCompressedAuthor(userID uuid.UUID) (
	*responses.CompressedAuthor, error) {

	author, err := s.getAuthor(userID)
	if err != nil {
		return &responses.CompressedAuthor{},
			err
	}

	compressedAuthor := &responses.CompressedAuthor{
		ID:       author.ID,
		Name:     author.Name,
		Surname:  author.Surname,
		ImageURL: author.ImageURL,

		Rating: author.Rating,
	}

	return compressedAuthor, nil
}
