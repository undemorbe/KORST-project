// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"github.com/google/uuid"
)

// Hub - объект, который представляет собой
// менеждер всех подключений по WebSocket
type Hub struct {
	Clients map[uuid.UUID]*Client

	Register   chan *Client
	Unregister chan *Client
}

// NewHub создает и возвращает новый объект Hub
func NewHub() *Hub {
	return &Hub{
		Clients:    make(map[uuid.UUID]*Client),
		Register:   make(chan *Client),
		Unregister: make(chan *Client),
	}
}

// Run запускает Hub для непрерывной работы с клиентами
func (h *Hub) Run() {

	for {
		select {

		case client := <-h.Register:
			h.Clients[client.UserID] = client

		case client := <-h.Unregister:
			delete(h.Clients, client.UserID)
		}
	}
}

// SendToUser отправляет сообщение определенному пклиенту по WebSocket
func (h *Hub) SendToUser(userID uuid.UUID, msg []byte) {
	client, ok := h.Clients[userID]
	if !ok {
		return
	}

	client.Send <- msg
}
