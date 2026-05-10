// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
)

// ReplyService - объект, содержащий методы
// для работы с откликами на карточки
type ReplyService struct {
	userRepo  ports.UserRepository
	cardRepo  ports.CardRepository
	replyRepo ports.ReplyRepository
}

// NewReplyService создает и возвращает новый объект
func NewReplyService(userRepo ports.UserRepository,
	cardRepo ports.CardRepository,
	replyRepo ports.ReplyRepository) ports.ReplyService {
	return &ReplyService{
		userRepo:  userRepo,
		cardRepo:  cardRepo,
		replyRepo: replyRepo,
	}
}

// CreateReply создает отклик на определенной объявление
func (s *ReplyService) CreateReply(
	authorID uuid.UUID, cardID uuid.UUID) error {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при получении карточки: ", err)
		return err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return errors.ErrorCardNotFound
	}

	if card.UserID == authorID {
		logger.Log.Warn("Попытка создать отклик на свою карточку")
		return errors.ErrorForbidden
	}

	reply, err := s.replyRepo.FindByAuthorAndCard(authorID, cardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске отклика в Бд: ", err)
		return err
	}

	if reply != nil {
		logger.Log.Warn("Попытка создать второй отклик на объявление")
		return errors.ErrorForbidden
	}

	reply = &entities.Reply{
		AuthorID: authorID,
		CardID:   cardID,
	}

	if err = s.replyRepo.CreateReply(reply); err != nil {
		logger.Log.Error("Ошибка при создании отклика: ", err)
		return err
	}

	return nil
}

// GetExecutors получает всех исполниелей для определенной карточки
func (s *ReplyService) GetExecutors(cardID uuid.UUID) (
	responses.GetExecutorsResponse, error) {

	var response responses.GetExecutorsResponse

	card, err := s.cardRepo.FindWithReplies(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при получении карточки: ", err)
		return response, err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return response, errors.ErrorCardNotFound
	}

	for _, reply := range card.Replies {

		convertedUser, err := s.getUserFromReply(&reply)
		if err != nil {
			logger.Log.Warn("Ошибка при обработке автора отклика: ", err)
			continue
		}

		response.Executors = append(response.Executors, convertedUser)
	}

	return response, nil
}

// getUserFromReply находит и приводит к
// нужному формату сущность автора отклика
func (s *ReplyService) getUserFromReply(reply *entities.Reply) (
	responses.CompressedAuthor, error) {

	var convertedUser responses.CompressedAuthor

	user, err := s.userRepo.FindByID(reply.AuthorID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return convertedUser, err
	}

	if user == nil {
		logger.Log.Warn("Автор отклика не найден")
		return convertedUser, errors.ErrorUserNotFound
	}

	convertedUser = responses.CompressedAuthor{
		ID:      user.ID.String(),
		Name:    user.Name,
		Surname: user.Surname,
	}

	profile := user.Profile

	if profile != nil {
		convertedUser.ImageURL = profile.ImageURL
		convertedUser.Rating = profile.Rating
	}

	return convertedUser, nil
}

// ApproveExecutor yтверждает исполнителя для определенной
// карточки (меняет статус отклика и карточки)
func (s *ReplyService) ApproveExecutor(authorID uuid.UUID,
	cardID uuid.UUID, executorID uuid.UUID) error {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при получении карточки: ", err)
		return err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return errors.ErrorCardNotFound
	}

	if card.UserID != authorID {
		logger.Log.Warn("Текущий пользователь не является автором карточки")
		return errors.ErrorForbidden
	}

	reply, err := s.replyRepo.FindByAuthorAndCard(executorID, cardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске отклика на вакансию")
		return err
	}

	if reply == nil {
		logger.Log.Warn("Отклик данного пользователя не был найден")
		return errors.ErrorReplyNotFound
	}

	card.Status = entities.CardStatusInProgress
	card.ActiveReply = reply

	err = s.cardRepo.UpdateCard(card)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении карточки: ", err)
		return err
	}

	reply.Status = entities.ReplyStatusAccepted

	err = s.replyRepo.UpdateReply(reply)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении отклика: ", err)
		return err
	}

	return nil
}

// RejectExecutor отклоняет отклик исполнителя на объявление
// (меняет статус отклика на объявление)
func (s *ReplyService) RejectExecutor(authorID uuid.UUID,
	cardID uuid.UUID, executorID uuid.UUID) error {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при получении карточки: ", err)
		return err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return errors.ErrorCardNotFound
	}

	if card.UserID != authorID {
		logger.Log.Warn("Текущий пользователь не является автором карточки")
		return errors.ErrorForbidden
	}

	reply, err := s.replyRepo.FindByAuthorAndCard(executorID, cardID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске отклика на вакансию")
		return err
	}

	if reply == nil {
		logger.Log.Warn("Отклик данного пользователя не был найден")
		return errors.ErrorReplyNotFound
	}

	reply.Status = entities.ReplyStatusRejected

	err = s.replyRepo.UpdateReply(reply)
	if err != nil {
		logger.Log.Error("Ошибка при обновлении отклика: ", err)
		return err
	}

	return nil
}

// CloseCard закрывает (или открывает карточку заново) с определенным статусом
func (s *ReplyService) CloseCard(authorID uuid.UUID,
	cardID uuid.UUID, status string) error {

	card, err := s.cardRepo.FindByID(cardID)
	if err != nil {
		logger.Log.Error("Ошибка при получении карточки: ", err)
		return err
	}

	if card == nil {
		logger.Log.Warn("Указанная карточка не найдена")
		return errors.ErrorCardNotFound
	}

	if card.UserID != authorID {
		logger.Log.Warn("Текущий пользователь не является автором карточки")
		return errors.ErrorForbidden
	}

	reply := card.ActiveReply

	switch status {

	case requests.StatusCompleted:

		card.Status = entities.CardStatusCompleted
		reply.Status = entities.ReplyStatusCompleted

	case requests.StatusClosedWithBadResult:

		card.Status = entities.CardStatusClosed
		reply.Status = entities.ReplyStatusFailed

	case requests.StatusReopenWithBadResult:

		card.Status = entities.CardStatusActive
		reply.Status = entities.ReplyStatusFailed

	case requests.StatusReopenWithGoodResult:

		card.Status = entities.CardStatusActive
		reply.Status = entities.ReplyStatusCompleted

	default:

		logger.Log.Warn("Неверный формат статуса карточки в запросе")
		return errors.ErrorInvalidInput
	}

	if err = s.cardRepo.UpdateCard(card); err != nil {
		logger.Log.Error("Ошибка при обновлении карточки: ", err)
		return err
	}

	if err = s.replyRepo.UpdateReply(reply); err != nil {
		logger.Log.Error("Ошибка при обновлении отклика: ", err)
		return err
	}

	return nil
}
