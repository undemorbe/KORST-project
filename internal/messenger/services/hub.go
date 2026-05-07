// services - пакет, содержащий внутреннюю
// логику для мессенджера
package services

import (
	"sync"

	"github.com/google/uuid"
)

// Hub - объект, который представляет собой
// менеждер всех подключений по WebSocket
type Hub struct {
	Clients map[uuid.UUID]*Client

	Register   chan *Client
	Unregister chan *Client

	mu sync.RWMutex
}

// NewHub создает и возвращает новый объект Hub
func NewHub() *Hub {
	return &Hub{
		Clients:    make(map[uuid.UUID]*Client, 100),
		Register:   make(chan *Client, 100),
		Unregister: make(chan *Client, 100),
	}
}

// Run запускает Hub для непрерывной работы с клиентами
func (h *Hub) Run() {

	for {
		select {

		case client := <-h.Register:
			h.mu.Lock()
			h.Clients[client.UserID] = client
			h.mu.Unlock()

		case client := <-h.Unregister:
			h.mu.Lock()
			delete(h.Clients, client.UserID)
			h.mu.Unlock()

			close(client.Send)
		}
	}
}

// SendToUser отправляет сообщение определенному пклиенту по WebSocket
func (h *Hub) SendToUser(userID uuid.UUID, msg []byte) {

	h.mu.RLock()
	client, ok := h.Clients[userID]
	h.mu.RUnlock()

	if !ok {
		return
	}

	select {
	case client.Send <- msg:
	default:
	}
}
