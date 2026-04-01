// entities - пакет с сущностями для БД
package entities

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User - структура сущности пользователя в БД
// Содержит ID, телефон, имя и фамилию пользователя,
// значение IsRegistered, ссылку на refresh токен,
// профиль, созданные и полученные отзывы, карточки
type User struct {
	ID    uuid.UUID `gorm:"type:uuid;primaryKey"`
	Phone string    `gorm:"unique;not null"`

	Name    string
	Surname string
	Status  string `gorm:"not null"`

	RefreshToken *RefreshToken `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Profile      *Profile      `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`

	CreatedReviews []Review `gorm:"foreignKey:AuthorID;constraint:OnDelete:CASCADE"`
	RelatedReviews []Review `gorm:"foreignKey:RelatedToID;constraint:OnDelete:CASCADE"`

	CustomerChats []Chat `gorm:"foreignKey:MerchantID;constraint:OnDelete:CASCADE"`
	MerchantChats []Chat `gorm:"foreignKey:CustomerID;constraint:OnDelete:CASCADE"`

	Cards []Card `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
}

// BeforeCreate создает необходимые отсутствющие поля при создании сущности
func (u *User) BeforeCreate(db *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	if len(u.Status) == 0 {
		if len(u.Name) == 0 || len(u.Surname) == 0 {
			u.Status = "notRegistered"
		} else {
			u.Status = "user"
		}
	}
	return nil
}
