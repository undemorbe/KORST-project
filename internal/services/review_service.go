// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"math"

	"github.com/google/uuid"
)

// UserService - объект, содержащий методы для работы с отзывами
type ReviewService struct {
	userRepo    ports.UserRepository
	profileRepo ports.ProfileRepository
	reviewRepo  ports.ReviewRepository
}

// NewReviewService создает и возвращает новый объект ReviewService
func NewReviewService(userRepo ports.UserRepository,
	profileRepo ports.ProfileRepository,
	reviewRepo ports.ReviewRepository) ports.ReviewService {
	return &ReviewService{
		userRepo:    userRepo,
		profileRepo: profileRepo,
		reviewRepo:  reviewRepo,
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

	if authorID == req.UserID {
		logger.Log.Warn("Попытка создать отзыв на самого себя")
		return errors.ErrorInvalidInput
	}

	review, err := s.reviewRepo.FindReviewToUser(authorID, req.UserID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске отзыва: ", err)
		return err
	}

	if review != nil {
		logger.Log.Warn("Попытка создать второй отзыв на пользователя")
		return errors.ErrorReviewExists
	}

	newReview := entities.Review{
		AuthorID:    authorID,
		RelatedToID: req.UserID,

		Rating: req.Rating,
	}

	if req.Comment != nil {
		newReview.Comment = *req.Comment
	}

	err = s.reviewRepo.CreateReview(&newReview)
	if err != nil {
		logger.Log.Error("Ошибка при создании отзыва: ", err)
		return err
	}

	return s.changeUserRating(newReview.RelatedToID)
}

// changeUSerRating изменяет средний рейтинг
// пользователя после получения нового отзыва
func (s *ReviewService) changeUserRating(userID uuid.UUID) error {

	user, err := s.userRepo.FindByID(userID)
	if err != nil {
		logger.Log.Error("Ошибка при поиске пользователя: ", err)
		return err
	}

	if user == nil {
		logger.Log.Warn("Пользователь, к которому отностится отзыв, не найден")
		return errors.ErrorUserNotFound
	}

	profile := user.Profile

	if profile == nil {
		logger.Log.Warn("Профиль пользователя не найден")
		return errors.ErrorUserNotFound
	}

	reviews := user.RelatedReviews
	var ratingSum float64

	for i := range reviews {
		ratingSum = ratingSum + reviews[i].Rating
	}

	averangeRating := ratingSum / float64(len(reviews))
	roundedRating := math.Round(averangeRating*10) / 10

	profile.Rating = roundedRating

	return s.profileRepo.UpdateProfile(profile)
}
