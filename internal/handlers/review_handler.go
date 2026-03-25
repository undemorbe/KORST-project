// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"net/http"

	"github.com/gin-gonic/gin"
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

func (h *ReviewHandler) GetReviews(c *gin.Context) {
	var req requests.UserIDRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.reviewService.GetReviews(req.UserID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение отзывов на пользователя успешно выполнено")
	c.JSON(http.StatusOK, response)
}

func (h *ReviewHandler) PostReview(c *gin.Context) {
	var req requests.PostReviewRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	accessToken := c.GetHeader("Authorization")

	authorID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.reviewService.PostReview(authorID, &req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Создание нового отзыва успешно выполнено")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
