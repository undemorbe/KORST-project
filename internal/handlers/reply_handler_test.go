// handlers - пакет, содержащий в себе обработчики Api запросов
package handlers

import (
	"bytes"
	"fmt"
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/middleware"
	mockServices "korst-backend/internal/mocks/services"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// TestCreateReply проверяет обработку запроса на
// создание отклика пользователя на объявление
func TestCreateReply(t *testing.T) {
	gin.SetMode(gin.TestMode)
	logger.InitLoggerTest()

	mockReplyService := &mockServices.MockReplyService{}
	mockTokenService := &mockServices.MockTokenService{}

	replyHandler := NewReplyHandler(mockReplyService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/create-reply", replyHandler.CreateReply)

	authorID := uuid.New()
	cardID := uuid.New()
	accessToken := "access-token"

	body := fmt.Sprintf(`{
		"card-id": "%s"
	}`, cardID.String())

	mockTokenService.
		On("DecodeAccessToken", accessToken).
		Return(authorID, nil)

	mockReplyService.
		On("CreateReply", authorID, cardID).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/create-reply",
		bytes.NewBufferString(body),
	)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	mockTokenService.AssertExpectations(t)
	mockReplyService.AssertExpectations(t)
}

// TestApproveExecutor проверяет обработку запроса на
// утверждение исполнителя для объявления
func TestApproveExecutor(t *testing.T) {
	mockReplyService := &mockServices.MockReplyService{}
	mockTokenService := &mockServices.MockTokenService{}

	replyHandler := NewReplyHandler(mockReplyService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/approve-executor", replyHandler.ApproveExecutor)

	authorID := uuid.New()
	cardID := uuid.New()
	executorID := uuid.New()
	accessToken := "access-token"

	reqBody := requests.ChangeExecutorRequest{
		CardID:     cardID,
		ExecutorID: executorID,
	}

	body := fmt.Sprintf(`{
		"card-id": "%s",
		"executor-id": "%s"
	}`, reqBody.CardID, reqBody.ExecutorID)

	mockTokenService.
		On("DecodeAccessToken", accessToken).
		Return(authorID, nil)

	mockReplyService.
		On(
			"ApproveExecutor",
			authorID,
			cardID,
			executorID,
		).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/approve-executor",
		bytes.NewBufferString(body),
	)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	mockTokenService.AssertExpectations(t)
	mockReplyService.AssertExpectations(t)
}

// TestRejectExecutor проверяет обработку запроса на
// отклонение отклика на определенное объявление
func TestRejectExecutor(t *testing.T) {
	mockReplyService := &mockServices.MockReplyService{}
	mockTokenService := &mockServices.MockTokenService{}

	replyHandler := NewReplyHandler(mockReplyService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/reject-executor", replyHandler.RejectExecutor)

	authorID := uuid.New()
	cardID := uuid.New()
	executorID := uuid.New()
	accessToken := "access-token"

	body := fmt.Sprintf(`{
		"card-id": "%s",
		"executor-id": "%s"
	}`, cardID.String(), executorID.String())

	mockTokenService.
		On("DecodeAccessToken", accessToken).
		Return(authorID, nil)

	mockReplyService.
		On(
			"RejectExecutor",
			authorID,
			cardID,
			executorID,
		).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/reject-executor",
		bytes.NewBufferString(body),
	)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	mockTokenService.AssertExpectations(t)
	mockReplyService.AssertExpectations(t)
}

// TestCloseCard проверяет обработку запроса на
// закрытие карточки с определенным статусом
func TestCloseCard(t *testing.T) {
	mockReplyService := &mockServices.MockReplyService{}
	mockTokenService := &mockServices.MockTokenService{}

	replyHandler := NewReplyHandler(mockReplyService, mockTokenService)

	router := gin.New()
	router.Use(middleware.ErrorHandler())
	router.POST("/close", replyHandler.CloseCard)

	authorID := uuid.New()
	cardID := uuid.New()
	accessToken := "access-token"

	status := requests.StatusCompleted

	body := fmt.Sprintf(`{
		"card-id": "%s",
		"status": "%s"
	}`, cardID.String(), status)

	mockTokenService.
		On("DecodeAccessToken", accessToken).
		Return(authorID, nil)

	mockReplyService.
		On("CloseCard", authorID, cardID, status).
		Return(nil)

	req := httptest.NewRequest(
		http.MethodPost,
		"/close",
		bytes.NewBufferString(body),
	)

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", accessToken)

	writer := httptest.NewRecorder()

	router.ServeHTTP(writer, req)

	require.Equal(t, http.StatusOK, writer.Code)

	mockTokenService.AssertExpectations(t)
	mockReplyService.AssertExpectations(t)
}
