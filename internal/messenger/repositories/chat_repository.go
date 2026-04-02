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

type chatRepo struct {
	db *gorm.DB
}

func NewChatRepository(db *gorm.DB) ports.ChatRepository {
	return &chatRepo{db: db}
}

func (r *chatRepo) FindByID(chatID uuid.UUID) (
	*entities.Chat, error) {

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

func (r *chatRepo) CreateChat(chat *entities.Chat) error {
	return r.db.Create(chat).Error
}

func (r *chatRepo) DeleteChat(chatID uuid.UUID) error {
	return r.db.Where("id = ?", chatID).
		Delete(&entities.Chat{}).Error
}
