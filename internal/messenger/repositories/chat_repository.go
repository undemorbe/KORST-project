// repositories - пакет с методами для
// работы с БД для мессенджера
package repositories

import (
	"errors"
	"korst-backend/internal/messenger/entities"
	"korst-backend/internal/messenger/ports"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// chatRepo - объект, содержащий методы для
// работы с сущностью чата в БД
type chatRepo struct {
	db *gorm.DB
}

// NewChatRepository создает и возвращает новый объект chatRepo
func NewChatRepository(db *gorm.DB) ports.ChatRepository {
	return &chatRepo{db: db}
}

// FindByID находит чат по его ID
func (r *chatRepo) FindByID(chatID uuid.UUID) (*entities.Chat, error) {
	var chat entities.Chat

	err := r.db.
		Preload("Messages").
		First(&chat, chatID).
		Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &chat, nil
}

// CreateChat создает новый объект чата в БД
func (r *chatRepo) CreateChat(chat *entities.Chat) error {
	return r.db.Create(chat).Error
}
