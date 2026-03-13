// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// cardRepo - объект, содержащий методы для работысс карточками объявлений
type cardRepo struct {
	db *gorm.DB
}

// NewUserRepository создает и возвращает новый объект cardRepo
func NewCardRepository(db *gorm.DB) ports.CardRepository {
	return &cardRepo{db: db}
}

// FindByID находит карточку по ее ID
func (r *cardRepo) FindByID(cardID uuid.UUID) (*entities.Card, error) {
	var card entities.Card

	err := r.db.First(&card, cardID).Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &card, nil
}

// CreateCard создает новый объект карточки объявления в БД
func (r *cardRepo) CreateCard(card *entities.Card) error {
	return r.db.Create(card).Error
}

// UpdateCard изменяет данные карточки в БД
func (r *cardRepo) UpdateCard(card *entities.Card) error {
	return r.db.Save(card).Error
}
