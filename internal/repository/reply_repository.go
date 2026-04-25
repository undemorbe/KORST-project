// repositories - пакет с методами для работы с БД
package repositories

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"gorm.io/gorm"
)

// replyRepo - объект, содержащий методы для
// работы с сущностью отклика на объявление в БД
type replyRepo struct {
	db *gorm.DB
}

// NewReplyRepository создает и возвращает новый объект replyRepo
func NewReplyRepository(db *gorm.DB) ports.ReplyRepository {
	return &replyRepo{db: db}
}

// Createreply создает новый объект отклика в БД
func (r *replyRepo) CreateReply(reply *entities.Reply) error {
	return r.db.Create(reply).Error
}
