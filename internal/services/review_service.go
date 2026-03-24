// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"

	"github.com/google/uuid"
)

// UserService - объект, содержащий методы для работы с отзывами
type ReviewService struct {
	userRepo   ports.UserRepository
	reviewRepo ports.ReviewRepository
}

// NewReviewService создает и возвращает новый объект ReviewService
func NewReviewService(userRepo ports.UserRepository,
	reviewRepo ports.ReviewRepository) ports.ReviewService {
	return &ReviewService{
		userRepo:   userRepo,
		reviewRepo: reviewRepo,
	}
}

// GetReviews получает все отзывы,
// относящиеся к определенному пользователю
func (s *ReviewService) GetReviews(userID uuid.UUID) (
	responses.GetReviewsResponse, error) {

	var response responses.GetReviewsResponse
	response.Reviews = []responses.Review{}

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return responses.GetReviewsResponse{},
			err
	}

	if user == nil {
		logger.Log.Warn("Пользователь с указанным ID не найден")
		return responses.GetReviewsResponse{},
			errors.ErrorUserNotFound
	}

	reviews := user.RelatedReviews

	for i := range reviews {
		convertedReview, err := s.getConvertedReview(&reviews[i])
		if err != nil {
			logger.Log.Error("Ошибка при обработке отзыва: ", err)
			continue
		}

		response.Reviews = append(response.Reviews, convertedReview)
	}

	return response, nil
}

// getConvertedReview конвертирует сущность
// отзыва в формат для response
func (s *ReviewService) getConvertedReview(
	review *entities.Review) (responses.Review, error) {

	var convertedReview responses.Review

	convertedReview.Rating = review.Rating
	convertedReview.Comment = review.Comment

	user, err := s.userRepo.FindByID(review.AuthorID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return responses.Review{},
			err
	}

	if user == nil {
		logger.Log.Warn("Пользователь с указанным ID не найден")
		return responses.Review{},
			errors.ErrorUserNotFound
	}

	var author responses.CompressedAuthor

	author.Name = user.Name
	author.Surname = user.Surname

	if user.Profile != nil {
		author.Rating = user.Profile.Rating
	}

	convertedReview.Author = author

	return convertedReview, nil
}

// PostReview сохраняет отзыв на указанного пользователя
func (s *ReviewService) PostReview(authorID uuid.UUID,
	req *requests.PostReviewRequest) error {
	// TODO: сделать размещение отзыва
	return nil
}
