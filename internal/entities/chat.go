// // entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Chat - структура сущности чата в БД.
// Содержит массив сообщений, относящихся к
// этому чату, время создания и обновления
type Chat struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey"`
	CardID     uuid.UUID `gorm:"type:uuid;uniqueIndex"`
	CustomerID uuid.UUID `gorm:"type:uuid;uniqueIndex"`
	MerchantID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Messages []Message `gorm:"foreignKey:ChatID;constraint:OnDelete:CASCADE"`

	CreatedAt time.Time `gorm:"not null"`
	UpdatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (c *Chat) BeforeCreate(db *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	if c.CreatedAt.IsZero() {
		c.CreatedAt = time.Now().UTC()
	}
	if c.UpdatedAt.IsZero() {
		c.UpdatedAt = time.Now().UTC()
	}
	return nil
}
