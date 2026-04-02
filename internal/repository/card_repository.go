// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// cardRepo - объект, содержащий методы для работы с карточками объявлений
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

// FindСardsByTime находит заданное количество карточек,
// которые больше ключа и отсортированны по времени.
func (r *cardRepo) FindCardsByTime(key *time.Time,
	limit int) ([]entities.Card, error) {

	var cards []entities.Card

	db := r.db.Order("updated_at DESC").Limit(limit)

	if key != nil {
		db = db.Where("updated_at < ?", *key)
	}

	err := db.Find(&cards).Error
	if err != nil {
		return nil, err
	}

	return cards, nil
}

// CreateCard создает новый объект карточки объявления в БД
func (r *cardRepo) CreateCard(card *entities.Card) error {
	return r.db.Create(card).Error
}

// UpdateCard изменяет данные карточки в БД
func (r *cardRepo) UpdateCard(card *entities.Card) error {
	return r.db.Save(card).Error
}
