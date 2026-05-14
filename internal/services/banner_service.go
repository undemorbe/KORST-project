// services - пакет, содержащий внутреннюю логику приложения
package services

import (
	"io"
	"korst-backend/internal/dto/responses"
	"korst-backend/internal/entities"
	"korst-backend/internal/infrastructure/logger"
	"korst-backend/internal/ports"
	"os"
	"strconv"

	"github.com/google/uuid"
)

// BannerService - объект, содержащий методы для
// сохранения и просмотра рекламных баннеров
type BannerService struct {
	bannerRepo  ports.BannerRepository
	fileService ports.FileService
}

// NewBannerService создает и возвращает новый объект BannerService
func NewBannerService(
	bannerRepo ports.BannerRepository,
	fileService ports.FileService) ports.BannerService {
	return &BannerService{
		bannerRepo:  bannerRepo,
		fileService: fileService,
	}
}

// SaveBanner сохраняет изображение баннера в локальное
// хранилище и сохраняет объект баннера в БД
func (s *BannerService) SaveBanner(company string,
	link string, file io.Reader, fileName string) error {

	bannerID := uuid.New()

	banner := &entities.Banner{
		ID:      bannerID,
		Company: company,
		Link:    link,
	}

	imageURL, err := s.fileService.SaveBannerImage(file, fileName, bannerID)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении изображения баннера: ", err)
		return err
	}

	banner.ImageURL = imageURL

	err = s.bannerRepo.CreateBanner(banner)
	if err != nil {
		logger.Log.Error("Ошибка при сохранении сущности баннера в БД: ", err)
		return err
	}

	return nil
}

// GetBanners получает и обрабатывает count случайных баннеров из БД
func (s *BannerService) GetBanners(count *int) (
	responses.GetBannersResponse, error) {

	var response responses.GetBannersResponse

	if count == nil || *count <= 0 {

		defaultCount, err := strconv.Atoi(os.Getenv("DEFAULT_BANNERS_COUNT"))
		if err != nil {
			return response, err
		}

		count = &defaultCount
	}

	banners, err := s.bannerRepo.FindBanners(*count)
	if err != nil {
		logger.Log.Error("Ошибка при получении баннеров")
		return response, err
	}

	baseURL := os.Getenv("BASE_URL")

	for _, banner := range banners {

		bannerInfo := responses.BannerInfo{
			Company:  banner.Company,
			ImageURL: baseURL + banner.ImageURL,
			Link:     banner.Link,
		}

		response.Banners = append(response.Banners, bannerInfo)
	}

	return response, nil
}
