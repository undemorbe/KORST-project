// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"korst-backend/internal/ports"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
)

// Client - объект, задающий одно активное
// WebSocket-соединение одного устройства
type Client struct {
	UserID uuid.UUID
	Conn   ports.Connection
	Send   chan []byte
}

// WritePump непрерывно отправляет
// поступающие сообщения на WebSocket клиента
func (c *Client) WritePump(h *Hub) {

	defer func() {
		h.Unregister <- c
		c.Conn.Close()
		close(c.Send)
	}()

	for msg := range c.Send {

		err := c.Conn.WriteMessage(
			websocket.TextMessage,
			msg,
		)

		if err != nil {
			break
		}
	}
}
