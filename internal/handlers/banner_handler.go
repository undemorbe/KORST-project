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

// BannerHandler - объект, содержащий методы для обработки
// Api запросов, связанных с рекламными баннерами
type BannerHandler struct {
	bannerService ports.BannerService
}

// NewBannerHandler создает и возвращает новый объект BannerHandler
func NewBannerHandler(
	bannerService ports.BannerService) *BannerHandler {
	return &BannerHandler{
		bannerService: bannerService,
	}
}

// SaveBanner обрабатывает запрос на сохранение баннера с его изображением
func (h *BannerHandler) SaveBanner(c *gin.Context) {

	company := c.PostForm("company")
	link := c.PostForm("link")

	if company == "" || link == "" {
		logger.Log.Warn("В запросе отсутствуют необходимые поля")
		c.Error(errors.ErrorInvalidInput)
		return
	}

	fileHeader, err := c.FormFile("image")
	if err != nil {
		logger.Log.Warn("Ошибка при получении файла: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}

	file, err := fileHeader.Open()
	if err != nil {
		logger.Log.Warn("Ошибка при открытии полученного файла: ", err)
		c.Error(errors.ErrorInvalidInput)
		return
	}
	defer file.Close()

	err = h.bannerService.SaveBanner(
		company, link, file, fileHeader.Filename)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Сохранение баннера успешно выполнено")
	c.JSON(http.StatusOK, responses.GenericResponse{})
}

// GetBanners обрабатывает запрос на получение нескольких случайных баннеров
func (h *BannerHandler) GetBanners(c *gin.Context) {

	var req requests.GetBannersRequest

	err := c.ShouldBindQuery(&req)
	if err != nil {
		c.Error(errors.ErrorInvalidInput)
		return
	}

	response, err := h.bannerService.GetBanners(req.Count)

	if err != nil {
		c.Error(err)
		return
	}

	logger.Log.Info("Получение баннеров успешно выполнено")
	c.JSON(http.StatusOK, response)
}
