// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"korst-backend/internal/ports"
)

// ReviewHandler - объект, содержащий методы для обработки
// Api запросов, связанных с отзывами на пользователей
type ReviewHandler struct {
	reviewService ports.ReviewService
	tokenService  ports.TokenService
}

// NewReviewHandler создает и возвращает новый объект ReviewHandler
func NewReviewHandler(reviewService ports.ReviewService,
	tokenService ports.TokenService) *ReviewHandler {
	return &ReviewHandler{
		reviewService: reviewService,
		tokenService:  tokenService,
	}
}
