// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/ports"
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
