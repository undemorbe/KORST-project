// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"
)

// TokenService - объект, содержащий методы для создания и обновления токенов
type TokenService struct {
	userRepo         ports.UserRepository
	refreshTokenRepo ports.RefreshTokenRepository
}

// NewTokenService создает и возвращает новый объект TokenService
func NewJWTTokenService(
	userRepo ports.UserRepository,
	refreshTokenRepo ports.RefreshTokenRepository,
) ports.TokenService {
	return &TokenService{
		userRepo:         userRepo,
		refreshTokenRepo: refreshTokenRepo,
	}
}

// CreateTokens создает (или обновляет) refresh-токен,
// создает новый access-токен
func (s *TokenService) CreateTokens(user *entities.User) (string, string, error) {
	// TODO: сделать TokenSerive
	return "", "", nil
}

// UpdateAccessToken создает новый access-токен для пользователя
//func (s *TokenService) CreateAccessToken(user *entities.User) (string, error)
