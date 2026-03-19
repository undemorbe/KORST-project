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

// UserHandler - объект, содержащий методы для обработки
// Api запросов, связанных с пользователями
type UserHandler struct {
	userService  ports.UserService
	tokenService ports.TokenService
}

// NewUserHandler создает и возвращает новый объект UserHandler
func NewUserHandler(userService ports.UserService,
	tokenService ports.TokenService) *UserHandler {
	return &UserHandler{
		userService:  userService,
		tokenService: tokenService,
	}
}

// UpdateUser обрабатывает запрос на обноление
// данных какого-то конкретного пользователя
func (h *UserHandler) UpdateUserInfo(c *gin.Context) {
	var req requests.UpdateUserRequest

	err := c.ShouldBindJSON(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	err = h.userService.UpdateUserInfo(userID, &req)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Обновление данных пользователя прошло успешно")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}
