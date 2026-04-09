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
	"github.com/google/uuid"
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

// SaveImage обрабатывает запрос на сохранение
// изображения для профиля пользователя
func (h *UserHandler) SaveImage(c *gin.Context) {

	fileHeader, err := c.FormFile("image")
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	file, err := fileHeader.Open()
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}
	defer file.Close()

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	url, err := h.userService.SaveImage(userID, file, fileHeader.Filename)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Сохранение изображения для профиля успешно выполнено")
	c.JSON(http.StatusOK, responses.SaveImageResponse{ImageURL: url})
}

// GetUserInfo обрабатывает запрос на получение
// информации о каком-то конкретном пользователе
func (h *UserHandler) GetUserInfo(c *gin.Context) {
	var req requests.UserIDRequest

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	userID, err := uuid.Parse(req.UserID)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.userService.GetUserInfo(userID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение данных о пользователе успешно выполнено")
	c.JSON(http.StatusOK, response)
}

// GetMyInfo обрабатывает запрос на получение
// информации о текущем пользователе приложения
func (h *UserHandler) GetMyInfo(c *gin.Context) {

	accessToken := c.GetHeader("Authorization")

	userID, err := h.tokenService.DecodeAccessToken(accessToken)
	if err != nil {
		c.Error(err)
		return
	}

	response, err := h.userService.GetUserInfo(userID)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение данных о текущем пользователе успешно выполнено")
	c.JSON(http.StatusOK, response)
}
