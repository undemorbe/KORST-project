// repositories - пакет с методами для
// работы с БД для мессенджера
package repositories

import (
	"korst-backend/internal/messenger/entities"
	"korst-backend/internal/messenger/ports"

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
