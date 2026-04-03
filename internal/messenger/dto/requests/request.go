// requests - пакет, содержащий модели запросов для
// api запросов, связанных с мессенджером
package requests

import (
	"github.com/google/uuid"
)

// GetMessagesReponse - структура для запроса
// получения всех сообщений в чате
type GetMessagesRequest struct {
	ChatID string `form:"chat-id" binding:"required"`
}

type SendMessageRequest struct {
	ChatID uuid.UUID `json:"chat-id" binding:"required"`
	Text   string    `json:"text" binding:"required"`
}
