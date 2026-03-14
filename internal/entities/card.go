// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Card - структура сущности карточки объявления.
// Содержит описание услуги (или товара)
// и информацию об авторе объявления
type Card struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Name        string `gorm:"not null"`
	Description string

	Price    float64 `gorm:"not null"`
	Currency string  `gorm:"not null"`
	Type     string
	Tags     []string `gorm:"type:text[]"`

	CreatedAt time.Time `gorm:"not null"`
	UpdatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (c *Card) BeforeCreate(db *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	if c.Tags == nil {
		c.Tags = []string{}
	}
	if c.CreatedAt.IsZero() {
		c.CreatedAt = time.Now().UTC()
	}
	if c.UpdatedAt.IsZero() {
		c.UpdatedAt = time.Now().UTC()
	}
	return nil
}
