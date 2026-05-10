package handlers

import (
	wsInfrastructure "korst-backend/internal/infrastructure/websocket"
	"korst-backend/internal/messenger/services"
	"korst-backend/internal/ports"

	"github.com/gin-gonic/gin"
)

// WSHandler - объект, содержащий методы для создания WebSocket
// соединения между сервером и мобильным устройством
type WSHandler struct {
	hub          *services.Hub
	tokenService ports.TokenService
}

// NewWSHandler создает и возвращает новый объект WSHandler
func NewWSHandler(hub *services.Hub,
	tokenService ports.TokenService) *WSHandler {
	return &WSHandler{
		hub:          hub,
		tokenService: tokenService,
	}
}

// Handle создает WebSocket соединение между мобильным устройством и сервером
func (h *WSHandler) Handle(c *gin.Context) {

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	conn, err := wsInfrastructure.Upgrader.Upgrade(
		c.Writer,
		c.Request,
		nil,
	)

	if err != nil {
		c.Error(err)
		return
	}

	client := &services.Client{
		UserID: userID,
		Conn:   conn,
		Send:   make(chan []byte, 50),
	}

	h.hub.Register <- client

	go client.WritePump(h.hub)
}
