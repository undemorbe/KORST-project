// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"encoding/json"
	"fmt"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"

	"korst-backend/internal/dto/requests"
	"korst-backend/internal/dto/responses"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// TestGetReviews проверяет обработку запроса на
// получение отзывов на определенного пользователя
func TestGetReviews(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockReviewService := &mockServices.MockReviewService{}
	mockTokenService := &mockServices.MockTokenService{}

	reviewHandler := NewReviewHandler(mockReviewService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.GET("/reviews", reviewHandler.GetReviews)

	userID := uuid.New()
	rating := 4.5
	name := "Олег"

	target := fmt.Sprintf("/reviews?user-id=%s", userID.String())

	review := responses.Review{
		Rating: rating,
		Author: responses.CompressedAuthor{
			Name: name,
		},
	}

	responseFromFunc := responses.GetReviewsResponse{
		Reviews: []responses.Review{review},
	}

	mockReviewService.
		On("GetReviews", userID).
		Return(responseFromFunc, nil)

	req := httptest.NewRequest(
		http.MethodGet,
		target,
		nil,
	)
	req.Header.Set("Content-Type", "application/json")

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	var response responses.GetReviewsResponse
	err := json.Unmarshal(writer.Body.Bytes(), &response)

	require.NoError(t, err)
	require.Equal(t, rating, response.Reviews[0].Rating)
	require.Equal(t, name, response.Reviews[0].Author.Name)
	mockReviewService.AssertExpectations(t)
}

// TestPostReview проверяет обработку запроса на
// размещение отзыва на пользователя
func TestPostReview(t *testing.T) {

	mockReviewService := &mockServices.MockReviewService{}
	mockTokenService := &mockServices.MockTokenService{}

	reviewHandler := NewReviewHandler(mockReviewService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/post-review", reviewHandler.PostReview)

	authorID := uuid.New()
	userID := uuid.New()
	rating := 4.5
	accessToken := "access-token"

	body := fmt.Sprintf(`{
		"user-id": "%s",
		"rating": %f
	}`, userID.String(), rating)

	requiredReq := &requests.PostReviewRequest{
		UserID: userID,
		Rating: rating,
	}

	mockTokenService.
		On("DecodeAccessToken", accessToken).
		Return(authorID, nil)

	mockReviewService.
		On("PostReview", authorID, requiredReq).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/post-review",
		bytes.NewBufferString(body),
	)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)
	mockTokenService.AssertExpectations(t)
	mockReviewService.AssertExpectations(t)
}
