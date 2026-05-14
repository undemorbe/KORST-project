// entities - пакет с сущностями для мессенджера
package entities

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Message - структура сущности сообщения, относящегося к
// определенному чату. Cодержит ссылки на чат и
// автора, текст сообщения и время создания
type Message struct {
	ID       uuid.UUID `gorm:"type:uuid;primaryKey"`
	ChatID   uuid.UUID `gorm:"type:uuid;uniqueIndex"`
	AuthorID uuid.UUID `gorm:"type:uuid;uniqueIndex"`

	Text     string
	ImageURL string

	IsSeen    bool      `gorm:"not null"`
	CreatedAt time.Time `gorm:"not null"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (m *Message) BeforeCreate(db *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	if m.CreatedAt.IsZero() {
		m.CreatedAt = time.Now().UTC()
	}
	return nil
}
