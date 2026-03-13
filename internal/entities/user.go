// entities - пакет с сущностями для БД
package entities

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User - структура сущности пользователя в БД
// Содержит ID, телефон, имя и фамилию пользователя,
// значение IsRegistered, ссылку на refresh токен
type User struct {
	ID    uuid.UUID `gorm:"type:uuid;primaryKey"`
	Phone string    `gorm:"unique;not null"`

	Name    string
	Surname string

	RefreshToken *RefreshToken `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Profile      *Profile      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Cards        []Card        `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (u *User) BeforeCreate(db *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return nil
}
