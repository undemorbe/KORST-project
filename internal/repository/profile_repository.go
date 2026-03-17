// repositories - пакет с методами для работы с БД
package repositories

import (
	"korst-backend/internal/entities"
	"korst-backend/internal/ports"

	"gorm.io/gorm"
)

// profileRepo - объект, содержащий методы для
// работы с сущностью профиля пользователя
type profileRepo struct {
	db *gorm.DB
}

// NewProfileRepository создает и возвращает новый объект profileRepo
func NewProfileRepository(db *gorm.DB) ports.ProfileRepository {
	return &profileRepo{db: db}
}

// CreateProfile создает новый объект профиля в БД
func (r *profileRepo) CreateProfile(profile *entities.Profile) error {
	return r.db.Create(profile).Error
}

// UpdateProfile обновляет данные профиля пользователя в БД
func (r *profileRepo) UpdateProfile(profile *entities.Profile) error {
	return r.db.Save(profile).Error
}
