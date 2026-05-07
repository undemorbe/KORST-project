// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/dto/requests"
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	mockRepositories "korst-backend/internal/mocks/repositories"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/require"
)

// TestCreateReply тестирует создание отклика на объявление
func TestCreateReply(t *testing.T) {
	logger.InitLoggerTest()

	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockReplyRepo := &mockRepositories.MockReplyRepo{}

	replyService := NewReplyService(mockCardRepo, mockReplyRepo)

	authorID := uuid.New()
	cardID := uuid.New()

	reply := &entities.Reply{
		AuthorID: authorID,
		CardID:   cardID,
	}

	mockCardRepo.
		On("FindByID", cardID).
		Return(&entities.Card{ID: cardID}, nil)

	mockReplyRepo.On("CreateReply", reply).Return(nil)

	err := replyService.CreateReply(authorID, cardID)

	require.NoError(t, err)
	mockReplyRepo.AssertExpectations(t)
}

// TestApproveExecutor тестирует подтверждение отклика на объявление
func TestApproveExecutor(t *testing.T) {

	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockReplyRepo := &mockRepositories.MockReplyRepo{}

	replyService := NewReplyService(mockCardRepo, mockReplyRepo)

	authorID := uuid.New()
	cardID := uuid.New()
	executorID := uuid.New()

	card := &entities.Card{
		ID:     cardID,
		UserID: authorID,
		Status: entities.CardStatusActive,
	}

	reply := &entities.Reply{
		CardID:   cardID,
		AuthorID: authorID,
		Status:   entities.ReplyStatusPending,
	}

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	mockReplyRepo.
		On("FindByAuthorAndCard", executorID, cardID).
		Return(reply, nil)

	mockCardRepo.On("UpdateCard", card).Return(nil)

	mockReplyRepo.On("UpdateReply", reply).Return(nil)

	err := replyService.ApproveExecutor(authorID, cardID, executorID)

	require.NoError(t, err)
	require.Equal(t, entities.CardStatusInProgress, card.Status)
	require.Equal(t, entities.ReplyStatusAccepted, reply.Status)
	require.Equal(t, reply, card.ActiveReply)

	mockCardRepo.AssertExpectations(t)
	mockReplyRepo.AssertExpectations(t)
}

// TestRejectExecutor тестирует отклонение отклика на объявление
func TestRejectExecutor(t *testing.T) {

	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockReplyRepo := &mockRepositories.MockReplyRepo{}

	replyService := NewReplyService(mockCardRepo, mockReplyRepo)

	authorID := uuid.New()
	cardID := uuid.New()
	executorID := uuid.New()

	card := &entities.Card{
		ID:     cardID,
		UserID: authorID,
		Status: entities.CardStatusActive,
	}

	reply := &entities.Reply{
		CardID:   cardID,
		AuthorID: authorID,
		Status:   entities.ReplyStatusPending,
	}

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	mockReplyRepo.
		On("FindByAuthorAndCard", executorID, cardID).
		Return(reply, nil)

	mockReplyRepo.On("UpdateReply", reply).Return(nil)

	err := replyService.RejectExecutor(authorID, cardID, executorID)

	require.NoError(t, err)
	require.Equal(t, entities.CardStatusActive, card.Status)
	require.Equal(t, entities.ReplyStatusRejected, reply.Status)

	mockCardRepo.AssertExpectations(t)
	mockReplyRepo.AssertExpectations(t)
}

// TestCloseCard тестирует закрытие карточки
func TestCloseCard(t *testing.T) {

	mockCardRepo := &mockRepositories.MockCardRepo{}
	mockReplyRepo := &mockRepositories.MockReplyRepo{}

	replyService := NewReplyService(mockCardRepo, mockReplyRepo)

	authorID := uuid.New()
	cardID := uuid.New()
	status := requests.StatusCompleted

	reply := &entities.Reply{
		AuthorID: authorID,
		CardID:   cardID,
		Status:   entities.ReplyStatusAccepted,
	}

	card := &entities.Card{
		ID:          cardID,
		UserID:      authorID,
		Status:      entities.CardStatusInProgress,
		ActiveReply: reply,
	}

	mockCardRepo.On("FindByID", cardID).Return(card, nil)

	mockCardRepo.On("UpdateCard", card).Return(nil)

	mockReplyRepo.On("UpdateReply", reply).Return(nil)

	err := replyService.CloseCard(authorID, cardID, status)

	require.NoError(t, err)
	require.Equal(t, entities.CardStatusCompleted, card.Status)
	require.Equal(t, entities.ReplyStatusCompleted, reply.Status)

	mockCardRepo.AssertExpectations(t)
	mockReplyRepo.AssertExpectations(t)
}
