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

// messageRepo - объект, содержащий методы для работы
// с сообщениями внутри чата
type messageRepo struct {
	db *gorm.DB
}

// NewMessageRepository создает и возвращает новый объект messageRepo
func NewMessageRepository(db *gorm.DB) ports.MessageRepository {
	return &messageRepo{db: db}
}

// FinByID находит сообщение по его ID
func (r *messageRepo) FindByID(messageID uuid.UUID) (*entities.Message, error) {
	var message entities.Message

	err := r.db.First(&message, messageID).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &message, nil
}

// CreateMessage создает новый объект сообщения в БД
func (r *messageRepo) CreateMessage(message *entities.Message) error {
	return r.db.Create(message).Error
}

// UpdateMessage изменят данные конкретного сообщения в БД
func (r *messageRepo) UpdateMessage(message *entities.Message) error {
	return r.db.Save(message).Error
}

// DeleteMessage удаляет конкретное сообщение в БД
func (r *messageRepo) DeleteMessage(message *entities.Message) error {
	return r.db.Delete(message).Error
}
