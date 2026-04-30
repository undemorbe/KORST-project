// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
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

// FindByAuthorAndCard находит отклик на объявление по
// его автору и карточке, на которую был оставлен отклик
func (r *replyRepo) FindByAuthorAndCard(authorID uuid.UUID,
	cardID uuid.UUID) (*entities.Reply, error) {

	var reply entities.Reply

	err := r.db.
		Where("author_id = ?", authorID).
		Where("card_id = ?", cardID).
		First(&reply).
		Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &reply, nil
}

// Createreply создает новый объект отклика в БД
func (r *replyRepo) CreateReply(reply *entities.Reply) error {
	return r.db.Create(reply).Error
}

// UpdateReply изменяет статус отклика на объявление в БД
func (r *replyRepo) UpdateReply(reply *entities.Reply) error {
	return r.db.Save(reply).Error
}
