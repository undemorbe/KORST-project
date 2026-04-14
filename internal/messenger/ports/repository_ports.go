// ports - пакет, содержащий порты (интерфейсы) для мессенджера
package ports

import (
	"korst-backend/internal/messenger/entities"

	"github.com/google/uuid"
)

// ChatRepository содержит порты для взаимодействия с чатами в БД
type ChatRepository interface {
	// FindByID находит чат по его ID
	FindByID(chatID uuid.UUID) (*entities.Chat, error)

	// FindByCardAndUsers находит чат по ID карточки
	// и пользователей, к которым относится этот чат
	FindByCardAndUsers(cardID uuid.UUID, customerID uuid.UUID,
		merchantID uuid.UUID) (*entities.Chat, error)

	// CreateChat создает новый объект чата в БД
	CreateChat(chat *entities.Chat) error
}

// MessageRepository содержит порты для взаимодействия с сообщениями в БД
type MessageRepository interface {
	// FinByID находит сообщение по его ID
	FindByID(messageID uuid.UUID) (*entities.Message, error)

	// CreateMessage создает новый объект сообщения в БД
	CreateMessage(message *entities.Message) error

	// UpdateMessage изменят данные конкретного сообщения в БД
	UpdateMessage(message *entities.Message) error

	// DeleteMessage удаляет конкретное сообщение в БД
	DeleteMessage(message *entities.Message) error
}
