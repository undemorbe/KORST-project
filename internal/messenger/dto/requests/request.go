// requests - пакет, содержащий модели запросов для
// api запросов, связанных с мессенджером
package requests

import (
	"github.com/google/uuid"
)

// CreateChatRequest - структура для запроса
// на создания чата между двумя пользователями
type CreateChatRequest struct {
	UserID uuid.UUID `json:"user-id" binding:"required"`
	CardID uuid.UUID `json:"card-id" binding:"required"`
}

// GetMessagesReponse - структура для запроса
// получения всех сообщений в чате
type GetMessagesRequest struct {
	ChatID string `form:"chat-id" binding:"required"`
}

// SendMessageRequest - структура для запроса
// на отправку сообщения пользователю
type SendMessageRequest struct {
	ChatID uuid.UUID `json:"chat-id" binding:"required"`
	Text   string    `json:"text" binding:"required"`
}

// ChangeMessageRequest - структура для запроса
// на изменение текста сообщения
type ChangeMessageRequest struct {
	MessageID uuid.UUID `json:"message-id" binding:"required"`
	Text      string    `json:"text" binding:"required"`
}

// DeleteMessageRequest - структура для запроса
// на удаление определенного сообщения
type DeleteMessageRequest struct {
	MessageID uuid.UUID `json:"message-id" binding:"required"`
}
