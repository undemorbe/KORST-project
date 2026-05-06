// entities - пакет с сущностями для БД
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Banner - структура сущности рекламного баннера в БД.
// Содержит название баннера и компании, изображение и
// ссылку, на которую ведет данный баннер.
type Banner struct {
	ID      uuid.UUID `gorm:"type:uuid;primaryKey"`
	Company string

	ImageURL string `gorm:"not null"`
	Link     string `gorm:"not null"`

	CreatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (b *Banner) BeforeCreate(db *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	if b.CreatedAt.IsZero() {
		b.CreatedAt = time.Now().UTC()
	}
	return nil
}
