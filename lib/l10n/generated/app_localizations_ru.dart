// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Korst';

  @override
  String get appSubtitle => 'Маркетплейс услуг';

  @override
  String get homeTitle => 'Услуги';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get themeTitle => 'Тема';

  @override
  String get languageTitle => 'Язык';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get systemTheme => 'Системная';

  @override
  String get serviceDetailsTitle => 'Детали задания';

  @override
  String get priceLabel => 'Цена';

  @override
  String priceFormat(Object price, Object currency) {
    return '$price $currency';
  }

  @override
  String get errorLoading => 'Ошибка загрузки';

  @override
  String get emptyList => 'Нет доступных элементов';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get close => 'Закрыть';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get back => 'Назад';

  @override
  String get next => 'Далее';

  @override
  String get done => 'Готово';

  @override
  String get navHome => 'Главная';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navChats => 'Чаты';

  @override
  String get navBookings => 'Бронирования';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navMessages => 'Сообщения';

  @override
  String get navProfile => 'Профиль';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get bookingsTitle => 'Мои бронирования';

  @override
  String get bookNow => 'Забронировать';

  @override
  String get bookingSuccess => 'Услуга успешно забронирована!';

  @override
  String get bookingDate => 'Дата бронирования';

  @override
  String get noFavorites => 'В избранном пока пусто.';

  @override
  String get noBookings => 'Бронирований пока нет.';

  @override
  String get searchHint => 'Поиск услуг...';

  @override
  String get searchResults => 'Результаты поиска';

  @override
  String get noSearchResults => 'Ничего не найдено';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryCleaning => 'Уборка';

  @override
  String get categoryRepair => 'Ремонт';

  @override
  String get categoryConsulting => 'Консультации';

  @override
  String get categoryOther => 'Другое';

  @override
  String get categoryDelivery => 'Доставка';

  @override
  String get categoryTutoring => 'Репетиторство';

  @override
  String get categoryDesign => 'Дизайн';

  @override
  String get categoryDevelopment => 'Разработка';

  @override
  String get authTitle => 'Добро пожаловать';

  @override
  String get authSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get phoneLabel => 'Номер телефона';

  @override
  String get phoneHint => '+7 (___) ___-__-__';

  @override
  String get sendOtp => 'Отправить код';

  @override
  String get verifyOtp => 'Подтвердить';

  @override
  String get otpLabel => 'Код подтверждения';

  @override
  String get otpHint => 'Введите 4-значный код';

  @override
  String otpSent(Object phone) {
    return 'Код отправлен на $phone';
  }

  @override
  String get otpError => 'Неверный код. Попробуйте снова.';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileName => 'Имя';

  @override
  String get profileSurname => 'Фамилия';

  @override
  String get profilePhone => 'Телефон';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDescription => 'О себе';

  @override
  String get profileRating => 'Рейтинг';

  @override
  String get profileReviews => 'Отзывы';

  @override
  String get profileServices => 'Мои задания';

  @override
  String get profileNoServices => 'У вас пока нет заданий';

  @override
  String get profileAddService => 'Опубликовать задание';

  @override
  String get serviceCreateTitle => 'Создать задание';

  @override
  String get serviceEditTitle => 'Редактировать задание';

  @override
  String get serviceName => 'Название задания';

  @override
  String get serviceDescription => 'Описание';

  @override
  String get servicePrice => 'Бюджет';

  @override
  String get serviceCurrency => 'Валюта';

  @override
  String get serviceType => 'Тип';

  @override
  String get serviceTags => 'Теги';

  @override
  String get serviceTagsHint => 'Добавьте теги через запятую';

  @override
  String get serviceImage => 'Изображение задания';

  @override
  String get serviceAddImage => 'Добавить изображение';

  @override
  String get serviceChangeImage => 'Изменить изображение';

  @override
  String get serviceAuthor => 'Заказчик';

  @override
  String get serviceYou => 'Вы';

  @override
  String get servicePublished => 'Опубликовано';

  @override
  String get serviceUpdated => 'Обновлено';

  @override
  String get messagesTitle => 'Сообщения';

  @override
  String get messagesAsBuyer => 'Как работник';

  @override
  String get messagesAsSeller => 'Как работодатель';

  @override
  String get messagesNoChatsBuyer =>
      'У вас пока нет чатов как заказчика\nДождитесь откликов исполнителей';

  @override
  String get messagesNoChatsSeller =>
      'У вас пока нет чатов как исполнителя\nОткликнитесь на интересующее задание';

  @override
  String get messagesStart => 'Начать чат';

  @override
  String get messagesTypeHint => 'Введите сообщение...';

  @override
  String get messagesSend => 'Отправить';

  @override
  String get messagesEdit => 'Редактировать';

  @override
  String get messagesDelete => 'Удалить';

  @override
  String get messagesDeleteConfirm => 'Удалить это сообщение?';

  @override
  String get messagesEmpty => 'Пока нет сообщений';

  @override
  String get messagesLoadingError => 'Не удалось загрузить сообщения';

  @override
  String get errorGeneric => 'Что-то пошло не так';

  @override
  String get errorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errorUnauthorized => 'Сессия истекла. Войдите снова.';

  @override
  String get errorNotFound => 'Не найдено';

  @override
  String get errorValidation => 'Проверьте введенные данные';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get termsOfUse => 'Условия использования';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get currencyUSD => 'USD';

  @override
  String get currencyEUR => 'EUR';

  @override
  String get currencyRUB => 'RUB';

  @override
  String get currencyKZT => 'KZT';

  @override
  String get share => 'Поделиться';

  @override
  String get shareService => 'Посмотрите это задание на Korst';

  @override
  String get copied => 'Скопировано в буфер обмена';

  @override
  String get filter => 'Фильтр';

  @override
  String get sort => 'Сортировка';

  @override
  String get sortByDate => 'По дате';

  @override
  String get sortByPrice => 'По цене';

  @override
  String get sortByRating => 'По рейтингу';

  @override
  String get loading => 'Загрузка...';

  @override
  String get loadMore => 'Загрузить еще';

  @override
  String get noMoreItems => 'Больше нет элементов';

  @override
  String get created => 'Создано';

  @override
  String get updated => 'Обновлено';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get errorOops => 'Упс! Что-то пошло не так';

  @override
  String get settingsKorstPromo =>
      'Korst — сервисы рядом.\\n\\nОткрыть приложение: korst:/// \\n';

  @override
  String get myProfile => 'Мой профиль';

  @override
  String get publicProfile => 'Публичный профиль';

  @override
  String get myReviews => 'Мои отзывы';

  @override
  String get appSettings => 'Настройки приложения';

  @override
  String get russianLanguage => 'Русский';

  @override
  String get additional => 'Дополнительно';

  @override
  String get rateApp => 'Оценить приложение';

  @override
  String get shareApp => 'Поделиться приложением';

  @override
  String get high => 'Высокий';

  @override
  String get medium => 'Средний';

  @override
  String get low => 'Низкий';

  @override
  String get statistics => 'Статистика';

  @override
  String get services => 'Услуги';

  @override
  String get earned => 'Заработано';

  @override
  String get rating => 'Рейтинг';

  @override
  String get trustFactor => 'Фактор доверия';

  @override
  String get trustFactorDesc =>
      'Рассчитывается на основе количества услуг, отзывов и рейтинга.';

  @override
  String get user => 'Пользователь';

  @override
  String get welcomeToKorst => 'Добро пожаловать в Korst';

  @override
  String get findServicesNearby =>
      'Заказчик... Исполнитель?\nНайдите лучшие задачи и исполнителей неподалеку!';

  @override
  String get start => 'Начать';

  @override
  String get pleaseEnterValidNumber => 'Пожалуйста, введите корректный номер';

  @override
  String get yourPhoneNumber => 'Ваш номер телефона';

  @override
  String get weWillSendVerificationCode =>
      'Мы отправим код подтверждения на этот номер';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get enterSmsCode => 'Введите код из SMS';

  @override
  String get weSentCodeTo => 'Мы отправили код на номер ';

  @override
  String get profileCreatedButPhotoFailed =>
      'Профиль создан, но фото не загружено: ';

  @override
  String get editProfile => 'Редактирование профиля';

  @override
  String get createProfile => 'Создание профиля';

  @override
  String get saveChanges => 'Сохранить изменения';

  @override
  String get createProfileBtn => 'Создать профиль';

  @override
  String get basicData => 'Основные данные';

  @override
  String get firstName => 'Имя';

  @override
  String get enterFirstName => 'Введите имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get aboutMe => 'О себе';

  @override
  String get additionalContact => 'Дополнительный контакт';

  @override
  String get errorLoadingPrefix => 'Ошибка загрузки: ';

  @override
  String get profileNotFound => 'Профиль не найден';

  @override
  String get youHaveNoReviewsYet => 'У вас пока нет отзывов';

  @override
  String get errorLoadingPhotoPrefix => 'Ошибка загрузки фото: ';

  @override
  String get noMoreData => 'Дальше бога нет';

  @override
  String get taskNotFound => 'Задание не найдено';

  @override
  String get errorUserNotFound => 'Ошибка: пользователь не найден';

  @override
  String get task => 'задание';

  @override
  String get editTask => 'Редактирование задания';

  @override
  String get newTask => 'Новое задание';

  @override
  String get updateTask => 'Обновить задание';

  @override
  String get createTask => 'Создать задание';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get taskDetails => 'Детали задания';

  @override
  String get title => 'Название';

  @override
  String get enterTitle => 'Введите название';

  @override
  String get description => 'Описание';

  @override
  String get budget => 'Бюджет';

  @override
  String get enterBudget => 'Введите бюджет';

  @override
  String get invalidBudget => 'Некорректный бюджет';

  @override
  String get category => 'Категория';

  @override
  String get currency => 'Валюта';

  @override
  String get tags => 'Теги';

  @override
  String get tagsHint => 'ремонт, быстро, срочно';

  @override
  String get failedToCreateChatPrefix => 'Не удалось создать чат: ';

  @override
  String get serviceCard => 'Карточка услуги';

  @override
  String get openInKorstPrefix => '\\n\\nОткрыть в Korst: ';

  @override
  String get authorPrefix => 'Автор: ';

  @override
  String get you => 'Вы';

  @override
  String get respondToTask => 'Откликнуться на задание';

  @override
  String get errorUpdatingToken => 'Ошибка обновления токена';

  @override
  String get failedToSendOtp => 'Не удалось отправить OTP';

  @override
  String get failedToVerifyUser => 'Не удалось проверить пользователя';

  @override
  String get invalidServerResponse => 'Некорректный ответ сервера';

  @override
  String get failedToConfirmOtp => 'Не удалось подтвердить OTP';

  @override
  String get failedToUpdateProfile => 'Не удалось обновить профиль';

  @override
  String get failedToLoadChats => 'Не удалось загрузить чаты';

  @override
  String get failedToLoadMessages => 'Не удалось загрузить сообщения';

  @override
  String get failedToCreateChat => 'Не удалось создать чат';

  @override
  String get failedToSendMessage => 'Не удалось отправить сообщение';

  @override
  String get failedToEditMessage => 'Не удалось изменить сообщение';

  @override
  String get failedToDeleteMessage => 'Не удалось удалить сообщение';

  @override
  String get invalidServerResponseInfo => 'Некорректный ответ сервера (info)';

  @override
  String get failedToLoadUserProfile =>
      'Не удалось загрузить профиль пользователя';

  @override
  String get failedToSendReview => 'Не удалось отправить отзыв';

  @override
  String get failedToLoadProfile => 'Не удалось загрузить профиль';

  @override
  String get errorLoadingImage => 'Ошибка загрузки изображения';

  @override
  String get failedToLoadImage => 'Не удалось загрузить изображение';

  @override
  String get service => 'услуга';

  @override
  String get failedToLoadCards => 'Не удалось загрузить карточки';

  @override
  String get failedToLoadCard => 'Не удалось загрузить карточку';

  @override
  String get failedToCreateCard => 'Не удалось создать карточку';

  @override
  String get failedToUpdateCard => 'Не удалось обновить карточку';

  @override
  String get failedToLoadCardImage =>
      'Не удалось загрузить изображение карточки';
}
