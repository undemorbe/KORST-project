// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
)

// ReplyService - объект, содержащий методы
// для работы с откликами на карточки
type ReplyService struct {
	cardRepo  ports.CardRepository
	replyRepo ports.ReplyRepository
}

// NewReplyService создает и возвращает новый объект
func NewReplyService(cardRepo ports.CardRepository,
	replyRepo ports.ReplyRepository) ports.ReplyService {
	return &ReplyService{
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

	reply := &entities.Reply{
		AuthorID: authorID,
		CardID:   cardID,
	}

	if err = s.replyRepo.CreateReply(reply); err != nil {
		logger.Log.Error("Ошибка при создании отклика: ", err)
		return err
	}

	return nil
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
