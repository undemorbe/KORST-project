// repositories - пакет с методами для работы с БД
package repositories

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"gorm.io/gorm"
)

// reviewRepo - объект, содержащий методы для
// работы с сущностью отзыва на пользователя в БД
type reviewRepo struct {
	db *gorm.DB
}

// NewReviewRepository создает и возвращает новый объект reviewRepo
func NewReviewRepository(db *gorm.DB) ports.ReviewRepository {
	return &reviewRepo{db: db}
}

// CreateReview создает новый объект отзыва на пользователя в БД
func (r *reviewRepo) CreateReview(review *entities.Review) error {
	return r.db.Create(review).Error
}

// UpdateReview изменяет содержимое отзыва на пользователя в БД
func (r *reviewRepo) UpdateReview(review *entities.Review) error {
	return r.db.Save(review).Error
}
