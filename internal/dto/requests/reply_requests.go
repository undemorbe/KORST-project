// requests - пакет, содержащий структуры запросов по Api
package requests

import (
	"github.com/google/uuid"
)

// Константы для статуса карточки при ее закрытии
const (
	StatusCompleted            = "completed"
	StatusClosedWithBadResult  = "closed-with-bad-result"
	StatusReopenWithBadResult  = "reopen-with-bad-result"
	StatusReopenWithGoodResult = "reopen-with-good-result"
)

// CreateReply - структура для запроса
// на создание нового отклика на объявление
type CreateReplyRequest struct {
	CardID uuid.UUID `json:"card-id" binding:"required"`
}

// ChangeExecutorRequest - структура для запроса
// на подтверждение/отклонение исполнителя карточки
type ChangeExecutorRequest struct {
	CardID     uuid.UUID `json:"card-id" binding:"required"`
	ExecutorID uuid.UUID `json:"executor-id" binding:"required"`
}

// CloseCardRequest - структура для запроса на
// закрытие или обновление статуса карточки
type CloseCardRequest struct {
	CardID uuid.UUID `json:"card-id" binding:"required"`
	Status string    `json:"status" binding:"required"`
}
