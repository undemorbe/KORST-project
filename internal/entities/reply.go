// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ReplyStatus показывает текущий статус отклика на объявление
type ReplyStatus string

const (
	ReplyStatusPending   ReplyStatus = "pending"
	ReplyStatusAccepted  ReplyStatus = "accepted"
	ReplyStatusRejected  ReplyStatus = "rejected"
	ReplyStatusCompleted ReplyStatus = "completed"
	ReplyStatusFailed    ReplyStatus = "failed"
)

// Reply - структура сущности отклика на объявление.
// Содержит ссылку на автора и карточку объявления,
// статус и время создания
type Reply struct {
	ID       uuid.UUID `gorm:"type:uuid;primaryKey"`
	AuthorID uuid.UUID `gorm:"type:uuid;uniqueIndex"`
	CardID   uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Status ReplyStatus `gorm:"not null"`

	CreatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (r *Reply) BeforeCreate(db *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	if len(r.Status) == 0 {
		r.Status = ReplyStatusPending
	}
	if r.CreatedAt.IsZero() {
		r.CreatedAt = time.Now().UTC()
	}
	return nil
}
