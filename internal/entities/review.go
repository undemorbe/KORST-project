// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Review - структура сущности отзыва о пользвателе.
// Содержит ссылку на автора и пользователя, к
// которому относится, рейтинг и текстовый отзыв
type Review struct {
	ID          uuid.UUID `gorm:"type:uuid;primaryKey"`
	AuthorID    uuid.UUID `gorm:"type:uuid;uniqueIndex"`
	RelatedToID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Rating  float64 `gorm:"not null"`
	Comment string

	CreatedAt time.Time `gorm:"not null"`
	UpdatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (r *Review) BeforeCreate(db *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	if r.CreatedAt.IsZero() {
		r.CreatedAt = time.Now().UTC()
	}
	if r.UpdatedAt.IsZero() {
		r.UpdatedAt = time.Now().UTC()
	}
	return nil
}
