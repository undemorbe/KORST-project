// handlers - пакет, содержащий хэндлеры для обработки
// запросов, связанных с мессенджером
package handlers

import (
	"korst-backend/internal/errors"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/messenger/dto/requests"
	messengerPorts "korst-backend/internal/messenger/ports"
	"korst-backend/internal/ports"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// ChatHandler - объект, содержащий методы для обработки
// Api запросов, связанных с чатами между пользователями
type ChatHandler struct {
	chatService  messengerPorts.ChatService
	tokenService ports.TokenService
}

// NewChatHandler создает и возвращает новый объект ChatHandler
func NewChatHandler(
	chatService messengerPorts.ChatService,
	tokenService ports.TokenService) *ChatHandler {
	return &ChatHandler{
		chatService:  chatService,
		tokenService: tokenService,
	}
}

// GetChats обрабатывает запрос на получение
// информации о чатах определенного пользователя
func (h *ChatHandler) GetChats(c *gin.Context) {

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	response, err := h.chatService.GetChats(userID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение чатов пользователя успшно выполнено")
	c.JSON(http.StatusOK, response)
}

// GetMessages обрабатывает запрос на получение всех
// сообщений из определенного чата
func (h *ChatHandler) GetMessages(c *gin.Context) {
	var req requests.GetMessagesRequest

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	chatID, err := uuid.Parse(req.ChatID)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.chatService.GetMessages(chatID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение всех сообщений в чате  прошло успешно")
	c.JSON(http.StatusOK, response)
}
