// ports - пакет, содержащий порты (интерфейсы) для мессенджера
package ports

import (
	"korst-backend/internal/messenger/dto/requests"
	"korst-backend/internal/messenger/dto/responses"

	"github.com/google/uuid"
)

// ChatService содержит порты для методов работы с чатами
type ChatService interface {
	// GetChats получает все чаты пользователя вместе с
	// самыми последними сообщениями в них
	GetChats(userID uuid.UUID) (responses.GetChatsResponse, error)

	// CreateChat создает чат между двумя пользователями
	CreateChat(authorID uuid.UUID, req requests.CreateChatRequest) error

	// GetMessages получает все сообщения в определенном чате
	GetMessages(chatID uuid.UUID) (responses.GetMessagesReponse, error)
}

// MessageService содержит порты для методов работы с сообщениями
type MessageService interface {
	// SendMessage сохраняет сообщение в определенном чате
	// и отправляет его к другому пользователю
	SendMessage(authorID uuid.UUID, chatID uuid.UUID, text string) error

	// ChangeMessage изменяет текст определенного сообщения в чате
	ChangeMessage(authorID uuid.UUID, messageID uuid.UUID, text string) error

	// DeleteMessage удаляет определенное сообщение из чата
	DeleteMessage(authorID uuid.UUID, messageID uuid.UUID) error
}
