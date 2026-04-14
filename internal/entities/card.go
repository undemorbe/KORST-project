// entities - пакет с сущностями для БД
package entities

import (
	messenger "korst-backend/internal/messenger/entities"
	"time"

	"github.com/google/uuid"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

// Card - структура сущности карточки объявления.
// Содержит описание услуги (или товара)
// и информацию об авторе объявления
type Card struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Name        string `gorm:"not null"`
	Description string `gorm:"default:''"`
	ImageURL    string `gorm:"default:''"`

	Price    float64 `gorm:"not null"`
	Currency string  `gorm:"not null"`
	Type     string
	Tags     pq.StringArray `gorm:"type:text[]"`

	RelatedChats []messenger.Chat `gorm:"foreignKey:CardID;constraint:OnDelete:CASCADE"`

	CreatedAt time.Time `gorm:"not null"`
	UpdatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (c *Card) BeforeCreate(db *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	if c.Tags == nil {
		c.Tags = pq.StringArray{}
	}
	if c.CreatedAt.IsZero() {
		c.CreatedAt = time.Now().UTC()
	}
	if c.UpdatedAt.IsZero() {
		c.UpdatedAt = time.Now().UTC()
	}
	return nil
}
