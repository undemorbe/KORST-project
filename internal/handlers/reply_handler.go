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

// ReplyHandler - объект, содержащий методы для обработки
// Api запросов, связанных с откликами на объявления
type ReplyHandler struct {
	replyService ports.ReplyService
	tokenService ports.TokenService
}

// NewReplyHandler создает и возвращает новый объект ReplyHandler
func NewReplyHandler(replyService ports.ReplyService,
	tokenService ports.TokenService) *ReplyHandler {
	return &ReplyHandler{
		replyService: replyService,
		tokenService: tokenService,
	}
}

// CreateReply обрабатывает запрос на создание
// нового отклика на определенное объявление
func (h *ReplyHandler) CreateReply(c *gin.Context) {
	var req requests.CreateReply

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

	err = h.replyService.CreateReply(authorID, req.CardID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Создание нового отклика успешно выполнено")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// ApproveExecutor обрабатывает запрос на утверждение
// исполнителя для определенного объявления
func (h *ReplyHandler) ApproveExecutor(c *gin.Context) {
	var req requests.ChangeExecutorRequest

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

	err = h.replyService.ApproveExecutor(
		authorID, req.CardID, req.ExecutorID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Утверждение исполнителя прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// RejectExecutor обрабатывает запрос на отклониение
// отклика на определенное объявление
func (h *ReplyHandler) RejectExecutor(c *gin.Context) {
	var req requests.ChangeExecutorRequest

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

	err = h.replyService.RejectExecutor(
		authorID, req.CardID, req.ExecutorID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Отклонение исполнителя прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// CloseCard обрабатывает запрос на закрытие карточки
// и отклика на нее с заданным статусом
func (h *ReplyHandler) CloseCard(c *gin.Context) {
	var req requests.CloseCardRequest

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

	err = h.replyService.CloseCard(
		authorID, req.CardID, req.Status)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Закрытие карточки прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
