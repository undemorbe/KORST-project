// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/mocks"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/mock"
	"github.com/stretchr/testify/require"
)

// TestGetReviews проверяет получение отзывов
// на конкретного пользователя
func TestGetReviews(t *testing.T) {
	logger.InitLoggerTest()

	mockUserRepo := &mocks.MockUserRepo{}
	mockProfileRepo := &mocks.MockProfileRepo{}
	mockReviewRepo := &mocks.MockReviewRepo{}

	reviewService := NewReviewService(mockUserRepo, mockProfileRepo, mockReviewRepo)

	userID := uuid.New()
	rating1 := 5.0
	rating2 := 2.5

	authorID1 := uuid.New()
	authorID2 := uuid.New()
	name := "Олег"

	author1 := &entities.User{}

	author2 := &entities.User{
		Name: name,
	}

	review1 := entities.Review{
		Rating:   rating1,
		AuthorID: authorID1,
	}

	review2 := entities.Review{
		Rating:   rating2,
		AuthorID: authorID2,
	}

	reviews := []entities.Review{
		review1,
		review2,
	}

	user := &entities.User{
		ID:             userID,
		RelatedReviews: reviews,
	}

	mockUserRepo.On("FindByID", userID).Return(user, nil)

	mockUserRepo.On("FindByID", authorID1).Return(author1, nil)

	mockUserRepo.On("FindByID", authorID2).Return(author2, nil)

	response, err := reviewService.GetReviews(userID)

	require.NoError(t, err)

	require.Equal(t, rating1, response.Reviews[0].Rating)
	require.Equal(t, name, response.Reviews[1].Author.Name)
}

// TestPostReview проверяет размещение нового отзыва
func TestPostReview(t *testing.T) {

	mockUserRepo := &mocks.MockUserRepo{}
	mockProfileRepo := &mocks.MockProfileRepo{}
	mockReviewRepo := &mocks.MockReviewRepo{}

	userID := uuid.New()
	authorID := uuid.New()
	rating := 4.0
	comment := "Комментарий"

	req := &requests.PostReviewRequest{
		UserID:  userID,
		Rating:  rating,
		Comment: &comment,
	}

	oldReview1 := entities.Review{
		Rating:  3.0,
		Comment: "",
	}

	oldReview2 := entities.Review{
		Rating:  4.0,
		Comment: "",
	}

	newReview := entities.Review{
		Rating:  rating,
		Comment: comment,
	}

	profile := &entities.Profile{
		UserID: userID,
		Rating: 3.5,
	}

	user := &entities.User{
		ID:             userID,
		Profile:        profile,
		RelatedReviews: []entities.Review{oldReview1, oldReview2, newReview},
	}

	reviewService := NewReviewService(mockUserRepo, mockProfileRepo, mockReviewRepo)

	mockReviewRepo.
		On("FindReviewToUser", authorID, userID).
		Return(nil, nil)

	mockReviewRepo.
		On("CreateReview", mock.AnythingOfType("*entities.Review")).
		Return(nil)

	mockUserRepo.On("FindByID", userID).Return(user, nil)

	mockProfileRepo.On("UpdateProfile", profile).Return(nil)

	err := reviewService.PostReview(authorID, req)

	require.NoError(t, err)

	require.Equal(t, rating, user.RelatedReviews[2].Rating)
	require.Equal(t, comment, user.RelatedReviews[2].Comment)

	require.Equal(t, 3.7, user.Profile.Rating)
}
