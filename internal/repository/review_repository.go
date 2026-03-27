// repositories - пакет с методами для работы с БД
package repositories

import (
	"errors"
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
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

// FindReviewToUser находит отзыв, созданный пользователем с authorID
// и относящийся к пользователю с relatedToID
func (r *reviewRepo) FindReviewToUser(authorID uuid.UUID,
	relatedToID uuid.UUID) (*entities.Review, error) {

	var review entities.Review

	err := r.db.
		Where("author_id = ?", authorID).
		Where("related_to_id = ?", relatedToID).
		First(&review).
		Error

	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &review, nil
}

// CreateReview создает новый объект отзыва на пользователя в БД
func (r *reviewRepo) CreateReview(review *entities.Review) error {
	return r.db.Create(review).Error
}

// UpdateReview изменяет содержимое отзыва на пользователя в БД
func (r *reviewRepo) UpdateReview(review *entities.Review) error {
	return r.db.Save(review).Error
}
