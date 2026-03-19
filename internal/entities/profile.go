// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"gorm.io/datatypes"
	"gorm.io/gorm"

	"github.com/google/uuid"
)

// Profile - структура профиля пользователя в БД.
// Содержит описание пользователя, контакты,
// рейтинг, время создания и обновления
type Profile struct {
	ID     uuid.UUID `gorm:"type:uuid;primaryKey"`
	UserID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Description string
	Rating      float64

	Email         string
	Telegram      string
	OtherContacts datatypes.JSONMap `gorm:"type:jsonb"`

	CreatedAt time.Time `gorm:"not null"`
	UpdatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (p *Profile) BeforeCreate(db *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	if p.CreatedAt.IsZero() {
		p.CreatedAt = time.Now().UTC()
	}
	if p.UpdatedAt.IsZero() {
		p.UpdatedAt = time.Now().UTC()
	}
	return nil
}
