// repositories - пакет с методами для работы с БД
package repositories

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"gorm.io/gorm"
)

// bannerRepo - объект, содержащий методы
// для работы с рекламными баннерами в БД
type bannerRepo struct {
	db *gorm.DB
}

// NewBannerRepository создает и возвращает новый объект bannerRepo
func NewBannerRepository(db *gorm.DB) ports.BannerRepository {
	return &bannerRepo{db: db}
}

// FindBanners находит count случайных баннеров из всех записей в БД
func (r *bannerRepo) FindBanners(count int) (
	[]entities.Banner, error) {

	var banners []entities.Banner

	err := r.db.
		Order("RANDOM()").
		Limit(count).
		Find(&banners).
		Error

	if err != nil {
		return nil, err
	}

	return banners, nil
}

// CreateBanner создает новый объект рекламного баннера в БД
func (r *bannerRepo) CreateBanner(banner *entities.Banner) error {
	return r.db.Create(banner).Error
}
