# KORST

> **Маркетплейс услуг нового поколения** — мобильное приложение для размещения, поиска и обсуждения услуг с встроенным мессенджером, системой откликов и репутацией исполнителей.

📊 **Презентация проекта:** [Canva — KORST Pitch Deck](https://canva.link/fvqthe6w6uqvkhi)

---

## 📑 Содержание

- [О проекте](#-о-проекте)
- [Проблема и исследование](#-проблема-и-исследование)
- [Цели и задачи](#-цели-и-задачи)
- [Целевая аудитория](#-целевая-аудитория)
- [Ключевые возможности](#-ключевые-возможности)
- [Архитектура](#-архитектура)
- [Технологический стек](#-технологический-стек)
- [Структура проекта](#-структура-проекта)
- [Установка и запуск](#-установка-и-запуск)
- [Конфигурация](#-конфигурация)
- [API и Backend](#-api-и-backend)
- [Real-time подсистема](#-real-time-подсистема)
- [Локализация](#-локализация)
- [Дизайн-система](#-дизайн-система)
- [Тестирование](#-тестирование)
- [Сборка и релиз](#-сборка-и-релиз)
- [Дорожная карта](#-дорожная-карта)

---

## 🎯 О проекте

**KORST** — кроссплатформенное (iOS / Android / Web) мобильное приложение-маркетплейс, объединяющее заказчиков и исполнителей услуг в едином пространстве. Платформа решает задачу прозрачного поиска подрядчиков, ведения переговоров и фиксации репутационных метрик через рейтинги и отзывы.

Уникальность проекта — в визуальной концепции «Plague & Gold» (мрачная палитра с золотом и шрифтом Cinzel), которая выделяет KORST среди типичных «синих» маркетплейсов и формирует премиальный, узнаваемый бренд.

### Ключевые отличия

- 🔥 **Прямой контакт** заказчика и исполнителя без посредников
- 💬 **Встроенный WebSocket-мессенджер** с историей и пуш-уведомлениями
- ⭐ **Система рейтингов и отзывов** на уровне пользователя и карточки
- 🎨 **Уникальный визуальный язык** — тёмная палитра, золотые акценты, Cinzel-типографика
- 🌍 **Мультиязычность** — 5 локалей из коробки (RU / EN / DE / ES / ZH)
- 🔗 **Глубокие ссылки** — `korst://cards/{id}` и универсальные веб-ссылки
- 📡 **Офлайн-устойчивость** — Hive-кеш, восстановление состояния, очередь действий

---

## 🔬 Проблема и исследование

### Контекст рынка

Российский рынок услуг (C2C / SMB) перенасыщен агрегаторами, но страдает от трёх системных дефектов:

1. **Высокая комиссия** агрегаторов (15–30%), которая закладывается в стоимость для конечного клиента
2. **Шум и спам** в карточках — отсутствие фильтрации откликов, низкое качество исполнителей
3. **Слабая коммуникация** — переход в сторонние мессенджеры разрывает контекст сделки

### Проведённое исследование

В рамках предпроектной аналитики были изучены:

- **Конкурентный ландшафт** — Avito Услуги, YouDo, Profi.ru, Workle, Яндекс.Услуги
- **Customer Journey** — интервью с заказчиками и исполнителями
- **UX-аудит** — анализ конверсионных воронок и точек оттока в существующих решениях
- **Технологическая база** — выбор стека под требования к offline-устойчивости и real-time коммуникации

### Найденные инсайты

| Инсайт | Решение в KORST |
|--------|-----------------|
| Пользователи теряют контекст при переходе во внешние чаты | Встроенный WebSocket-мессенджер с привязкой к карточке |
| Регистрация по email отпугивает мобильную аудиторию | Авторизация только по телефону + OTP |
| Серые/синие UI воспринимаются как «ещё один маркетплейс» | Концепция Plague & Gold — дифференциация через визуал |
| Слабая обратная связь после отклика | Состояние «Вы откликнулись» + быстрый переход в чат |
| Потеря непрочитанных сообщений между сессиями | Hive-персистентность счётчиков непрочитанного |

---

## 🎯 Цели и задачи

### Стратегические цели

1. **Создать прямой канал** между заказчиком и исполнителем без потери контекста
2. **Снизить порог входа** до одного экрана авторизации (телефон + OTP)
3. **Сформировать визуальную идентичность**, отличающуюся от рыночных аналогов
4. **Подготовить технологическую базу** для масштабирования (FCM, фоновые задачи, deep links)

### Технические задачи

- ✅ Реализовать Clean Architecture с feature-based декомпозицией
- ✅ Внедрить реактивный state management на MobX с code generation
- ✅ Построить унифицированный HTTP-слой с автоматическим refresh токена
- ✅ Интегрировать WebSocket-канал с автореконнектом и offline-очередью
- ✅ Обеспечить кросс-сессионную персистентность через Hive
- ✅ Поддержать deep links и share-функциональность
- ✅ Локализовать UI на 5 языков с использованием ARB-файлов
- ✅ Покрыть критические сценарии тестами (unit + golden)

---

## 👥 Целевая аудитория

### Сегмент A — Заказчики (B2C)

- Возраст: 25–55 лет
- Регион: РФ, СНГ, расширение на EU/Азию
- Боль: поиск проверенного исполнителя без переплат агрегатору
- Сценарий: разовая или регулярная задача (ремонт, репетитор, фриланс, домашние услуги)

### Сегмент B — Исполнители (B2C / SMB)

- Самозанятые, фрилансеры, малые бригады
- Боль: высокие комиссии существующих платформ, низкое качество откликов
- Сценарий: размещение карточки, ведение портфолио, выстраивание репутации

---

## ✨ Ключевые возможности

### Авторизация и онбординг
- 📱 Вход по номеру телефона + OTP (без паролей)
- 🎬 5-слайдовый онбординг с автопереключением (10 сек)
- 👤 Создание профиля после первой авторизации
- 🔄 Автообновление access-токена через refresh-механизм
- 🚪 Защищённый выход из сессии

### Маркетплейс услуг
- 📋 Лента карточек с пагинацией и пуллом-обновлением
- 🔍 Поиск по названию, описанию и тегам
- 🏷️ Фильтры по категориям, цене, рейтингу
- ↕️ Сортировка (новые / цена ↑↓ / рейтинг)
- 📄 Детальная страница карточки с галереей, отзывами и автором
- ✏️ Создание / редактирование собственных карточек с загрузкой изображений
- 🔗 Глубокие ссылки на карточки + share

### Отклики и сделки
- 🤝 Отклик на чужую карточку с автоматическим созданием чата
- 💾 Персистентность состояния «Вы откликнулись» между сессиями
- ✅ Approve / Reject исполнителей (для заказчика)
- 🔒 Закрытие сделки со статусами (active / in-progress / completed / closed)
- 📊 Список исполнителей по карточке

### Мессенджер
- 💬 WebSocket-канал с realtime-доставкой
- 📥 Загрузка истории сообщений с пагинацией
- 🖼️ Отправка изображений
- ✏️ Редактирование / удаление собственных сообщений
- 👁️ Маркировка прочитанных, подсчёт непрочитанного
- 🔔 Push-уведомления при входящих сообщениях
- 🎴 Всплывающий fade-in/fade-out баннер при получении сообщения вне открытого чата
- 📑 Разделение на «как покупатель» / «как продавец»

### Отзывы и рейтинги
- ⭐ Отзывы на пользователей и карточки
- 📊 Подсчёт среднего рейтинга
- 📝 Раздел «Мои отзывы» в профиле

### Избранное
- ❤️ Добавление карточек в избранное
- 📂 Отдельная вкладка в нижней навигации

### Уведомления
- 🔔 Локальные push-уведомления (`flutter_local_notifications`)
- 🔗 Deep-link payload — переход на нужную карточку / чат
- ⚙️ Настройки приватности и режима тишины

### Прочее
- 🌐 Переключение языка интерфейса в настройках
- 🌗 Тёмная / светлая тема (Plague & Gold / Parchment)
- 📜 Privacy Policy и Terms of Use внутри приложения
- 🔌 Баннер при отсутствии интернет-соединения
- 📡 Фоновые задачи (`workmanager`) для поллинга при свёрнутом приложении

---

## 🏗 Архитектура

### Принципы

KORST построен на **Clean Architecture** с **feature-based** декомпозицией. Каждая фича изолирована и содержит три слоя:

```
features/<feature>/
├── data/           # Источники данных
│   ├── models/        # DTO и сериализация
│   ├── repositories/  # Реализация репозиториев
│   └── services/      # WebSocket, парсеры, etc.
├── domain/         # Бизнес-логика
│   ├── entities/      # Доменные сущности
│   └── repositories/  # Абстрактные интерфейсы
└── presentation/   # UI слой
    ├── pages/         # Экраны (StatefulWidget)
    ├── widgets/       # Переиспользуемые компоненты
    └── store/         # MobX-сторы (.dart + .g.dart)
```

### Поток данных

```
UI (Observer) → Store (@action) → Repository (interface)
                                      ↓
                            RepositoryImpl (data)
                                      ↓
                              ApiClient / Dio / WS
                                      ↓
                                  Backend API
```

UI подписывается на MobX-сторы через `Observer`. Действия пользователя вызывают `@action` методы, которые обращаются к репозиториям. Репозитории работают через интерфейсы (Dependency Inversion), что позволяет подменять реализацию на моки в тестах.

### Dependency Injection

Используется **GetIt** как Service Locator. Все зависимости регистрируются в `lib/core/di/injection_container.dart`:

```dart
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(sl(), sl(), sl()),
);
sl.registerLazySingleton(() => AuthStore(sl()));
```

Доступ к зависимостям — через `sl<Type>()` или `sl<Type>(instanceName: 'name')`.

### Навигация

**GoRouter** с поддержкой:
- StatefulShellRoute (нижняя навигация с сохранением состояния по вкладкам)
- Custom transitions (Fade + Slide + Scale)
- Deep linking (`korst://...` + universal links)
- Route guards (редирект на splash / auth / app по статусу сессии)

---

## 🛠 Технологический стек

### Core

| Категория | Технология | Версия | Назначение |
|-----------|-----------|--------|------------|
| Framework | Flutter | ^3.10.7 | Кросс-платформенный UI |
| Language | Dart | ^3.10.7 | Основной язык |
| State Mgmt | MobX | ^2.6.0 | Реактивный state |
| Code Gen | mobx_codegen | ^2.7.0 | Генерация `.g.dart` для сторов |
| DI | get_it | ^9.2.1 | Service Locator |
| Routing | go_router | ^17.1.0 | Декларативная навигация |
| HTTP | dio | ^5.9.2 | API-клиент с интерцепторами |
| WebSocket | web_socket_channel | ^3.0.3 | Real-time мессенджер |
| Storage | hive / hive_flutter | ^2.2.3 | Локальная типизированная БД |
| Logging | talker / talker_dio_logger | ^5.1.15 | Централизованное логирование |
| Notifications | flutter_local_notifications | ^21.0.0 | Локальные push |
| Background | workmanager | ^0.9.0+3 | Фоновые задачи |
| Deep Links | app_links | ^7.0.0 | Universal + custom scheme links |
| Connectivity | connectivity_plus | ^6.1.4 | Мониторинг сети |
| Fonts | google_fonts | ^6.3.2 | Cinzel + системные |
| Images | cached_network_image | ^3.4.1 | Кеш сетевых изображений |
| Picker | image_picker | ^1.1.2 | Выбор фото из галереи / камеры |
| PIN | pinput | ^6.0.2 | OTP-ввод |
| Mask | mask_text_input_formatter | ^2.9.0 | Маска номера телефона |
| Share | share_plus | ^12.0.1 | Шеринг ссылок |
| Launcher | url_launcher | ^6.3.1 | Открытие внешних URL |
| Review | in_app_review | ^2.0.10 | Запрос отзыва в сторах |
| Env | flutter_dotenv | ^6.0.0 | `.env` конфигурация |
| i18n | intl / flutter_localizations | ^0.20.2 | Локализация |

### Dev

| Категория | Технология | Назначение |
|-----------|-----------|------------|
| Code Gen | build_runner | Запуск всех генераторов |
| Lint | flutter_lints | Статический анализ |
| Testing | flutter_test | Unit / widget тесты |
| Mocks | mocktail | Мокирование зависимостей |
| Goldens | golden_toolkit | Snapshot-тестирование UI |

---

## 📁 Структура проекта

```
korst/
├── lib/
│   ├── main.dart                           # Точка входа, инициализация
│   ├── core/                               # Инфраструктура
│   │   ├── api/                            # ApiClient, Dio, токены, retry
│   │   ├── background/                     # WorkManager + поллинг
│   │   ├── config/                         # EnvConfig (.env-парсер)
│   │   ├── di/                             # GetIt контейнер
│   │   ├── logging/                        # Talker + safe interceptor
│   │   ├── network/                        # ConnectivityService, error banner
│   │   ├── router/                         # GoRouter + transitions
│   │   ├── storage/                        # Hive wrapper
│   │   ├── theme/                          # AppColors, AppTheme, gradient bg
│   │   └── widgets/                        # Glass, AppLayout, ConnectivityBanner
│   ├── features/                           # Доменные фичи
│   │   ├── auth/                           # OTP-логин, профиль, сессия
│   │   ├── banners/                        # Промо-баннеры на главной
│   │   ├── favorites/                      # Избранное
│   │   ├── main/                           # Shell с нижней навигацией
│   │   ├── messenger/                      # Чаты + WebSocket
│   │   ├── notifications/                  # NotificationService
│   │   ├── services/                       # Карточки услуг + отклики
│   │   ├── settings/                       # Настройки, профиль, policy
│   │   └── users/                          # Профили пользователей, отзывы
│   └── l10n/
│       ├── arb/                            # ARB-файлы (en/ru/de/es/zh)
│       └── generated/                      # Сгенерированные AppLocalizations
├── assets/                                 # Иконки приложения
├── docs/                                   # Документация
│   └── backend.md                          # Контракты API
├── test/                                   # Тесты
├── android/ ios/ web/ macos/ linux/ windows/  # Платформенные обёртки
├── pubspec.yaml                            # Зависимости
├── analysis_options.yaml                   # Линтер
└── l10n.yaml                               # Конфиг локализации
```

Всего **~105 Dart-файлов**, 9 фичей, 5 локалей.

---

## 🚀 Установка и запуск

### Предварительные требования

- Flutter SDK `^3.10.7`
- Dart SDK `^3.10.7`
- Xcode (для iOS-сборки)
- Android Studio / Android SDK (для Android-сборки)
- CocoaPods (для iOS)

### Шаги

```bash
# 1. Клонировать репозиторий
git clone <repo-url>
cd korst

# 2. Установить зависимости
flutter pub get

# 3. Создать .env (см. раздел "Конфигурация")
cp .env.example .env

# 4. Сгенерировать .g.dart для MobX и Hive
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Сгенерировать локализации
flutter gen-l10n

# 6. Запустить
flutter run                       # На подключённом устройстве
flutter run -d chrome             # В браузере
flutter run -d "iPhone 15 Pro"    # В симуляторе iOS
```

### Полезные команды

```bash
# Статический анализ
flutter analyze

# Запуск тестов
flutter test
flutter test test/features/auth/   # Конкретная фича

# Очистка
flutter clean && flutter pub get

# Watch-режим для build_runner
flutter pub run build_runner watch --delete-conflicting-outputs
```

---

## ⚙ Конфигурация

Все настройки приложения вынесены в **`.env`-файл**. Файл подгружается через `flutter_dotenv` в `EnvConfig.load()` при старте.

### Пример `.env`

```env
# Базовый URL API (с trailing slash)
API_BASE_URL=https://api.korst.example.com/api/

# Заголовки авторизации
API_HEADER_ACCESS_TOKEN=access-token
API_HEADER_AUTHORIZATION=Authorization
API_HEADER_USER_ID=user-id

# Эндпоинты авторизации
API_AUTHORIZE_SEND_OTP=authorize/send-otp
API_AUTHORIZE_VERIFY_OTP=authorize/verify-otp
API_AUTHORIZE_REFRESH=authorize/refresh
API_AUTHORIZE_LOGOUT=authorize/logout
API_AUTHORIZE_CHECK_USER=authorize/check-user

# Карточки
API_CARDS_GET_CARDS=cards/get-cards
API_CARDS_CARD_INFO=cards/card-info
API_CARDS_SAVE_CARD=cards/save-card
# ... (см. lib/core/config/env_config.dart для полного списка)

# Мессенджер
API_MESSENGER_CHATS=messenger/chats
API_MESSENGER_MESSAGES=messenger/messages
API_MESSENGER_SOCKET=wss://api.korst.example.com/ws
```

> **Важно:** `messengerSocketUrl` автоматически конвертирует `http://` → `ws://` и `https://` → `wss://`, если в `.env` передан HTTP-URL.

При отсутствии `.env` или конкретного ключа применяется **fallback-значение** из `EnvConfig._get(key, fallback)`.

---

## 🌐 API и Backend

Полные контракты API описаны в [`docs/backend.md`](docs/backend.md).

### Группы эндпоинтов

| Группа | Префикс | Назначение |
|--------|---------|------------|
| **Auth** | `/authorize/*` | OTP, refresh-токены, logout, проверка пользователя |
| **User** | `/user/*` | Профиль, отзывы, загрузка аватара |
| **Cards** | `/cards/*` | CRUD карточек, загрузка изображений |
| **Replies** | `/replies/*` | Отклики, approve/reject, закрытие сделки |
| **Messenger** | `/messenger/*` | Чаты, сообщения, создание чата |
| **Banners** | `/banners/*` | Промо-баннеры |

### HTTP-слой

Используются **два экземпляра Dio** через GetIt с `instanceName`:

- `'api'` — основной клиент с retry, логированием и автоматическим обновлением токена
- `'refresh'` — отдельный клиент для рефреша токенов (избегаем рекурсии при 401)

Интерцепторы:
- `SafeTalkerDioInterceptor` — лог без чувствительных данных
- `TalkerDioLogger` — детальный лог запросов / ответов
- `RetryInterceptor` — повтор сетевых ошибок с экспоненциальной паузой

---

## 📡 Real-time подсистема

### MessengerSocketService

```
WebSocket-канал на wss://<host>/ws
Авторизация: access-token из TokenStorage передаётся при handshake
Reconnect: автоматический при разрыве (exponential backoff)
Heartbeat: ping/pong для удержания соединения
```

### Поток событий

```
WS → MessengerEventParser → MessengerSocketEvent
                                    ↓
                          MessengerStore._handleSocketEvent
                                    ↓
                ┌──────────────────────────────────────┐
                ↓                  ↓                   ↓
   Обновление messages   Обновление chat list   IncomingMessageInfo
        (если открыт)      (lastMessage)         (для баннера)
```

### Управление жизненным циклом

WebSocket стартует при логине (`authStore.isLoggedIn → true`) и останавливается при logout. Реакция настроена через `Observer` на корневом уровне приложения:

```dart
if (loggedIn) {
  messengerStore.startRealtime();
  backgroundTaskManager.startPolling();
} else {
  messengerStore.stopRealtime();
  backgroundTaskManager.stopPolling();
}
```

### Фоновый поллинг

Когда приложение свёрнуто, WebSocket недоступен. `BackgroundTaskManager` через `workmanager` периодически опрашивает API и шлёт push при появлении новых сообщений.

---

## 🌍 Локализация

Поддерживаемые локали:

| Код | Язык | Файл |
|-----|------|------|
| `ru` | Русский | `lib/l10n/arb/app_ru.arb` |
| `en` | English | `lib/l10n/arb/app_en.arb` |
| `de` | Deutsch | `lib/l10n/arb/app_de.arb` |
| `es` | Español | `lib/l10n/arb/app_es.arb` |
| `zh` | 中文 | `lib/l10n/arb/app_zh.arb` |

Использование:

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.navHome);
```

Переключение языка — через `SettingsStore.setLocale(Locale code)`, сохраняется в Hive.

Регенерация после правки ARB:

```bash
flutter gen-l10n
```

---

## 🎨 Дизайн-система

### Концепция «Plague & Gold»

Тёмная палитра, отсылающая к эстетике средневековых манускриптов и алхимических трактатов. Золотые акценты на чёрно-коричневом фоне формируют премиальный, узнаваемый облик.

### Палитра (Dark theme)

```
Background     #080604   ← глубокий чёрный
Surface        #12100A
Surface Card   #1C1810   ← gradient start
Primary        #C49A22   ← золото
Primary Light  #D4AA55
On Background  #E8D4A0   ← пергамент
Border         #5A4820
Muted          #7A6A3A
Error          #AA4444
Success        #6AAA6A
```

### Light theme (Parchment)

Тёплая бежевая палитра для светлого режима — кремовые поверхности, тёмно-коричневый текст, тот же золотой акцент.

### Типографика

- **Заголовки:** Cinzel (Google Fonts) — латинская засечка, ассоциируется с эпиграфикой
- **Основной текст:** системный sans-serif

### Компоненты

- `Glass` — стеклянная карточка с blur-эффектом для bottom navigation и AppBar
- `AnimatedGradientBackground` — медленно движущийся градиентный фон
- `AppPageHeader` — заголовок страницы с иконкой и подписью
- `ChatShimmer`, `ErrorState`, `EmptyState` — состояния загрузки и ошибок

---

## 🧪 Тестирование

```bash
# Все тесты
flutter test

# С покрытием
flutter test --coverage

# Конкретная фича
flutter test test/features/auth/

# Golden-тесты
flutter test --update-goldens   # Регенерация эталонов
```

Используются:
- **mocktail** — моки репозиториев и сервисов
- **golden_toolkit** — snapshot-тесты UI-компонентов

---

## 📦 Сборка и релиз

### Android

```bash
flutter build apk --release             # APK
flutter build appbundle --release       # AAB (для Google Play)
```

### iOS

```bash
flutter build ios --release             # Архив через Xcode
flutter build ipa --release             # IPA напрямую
```

### Web

```bash
flutter build web --release             # Статика в build/web/
```

### Подписи

- Android: ключ настраивается в `android/key.properties` (не коммитится)
- iOS: профили / сертификаты через Apple Developer + Xcode

---

## 🗺 Дорожная карта

### v1.0 (текущая) ✅
- Авторизация по OTP
- Маркетплейс карточек + отклики
- Встроенный мессенджер на WebSocket
- Избранное, отзывы, рейтинги
- Мультиязычность (5 локалей)
- Темы Dark / Light
- Deep linking

### v1.1 (ближайший спринт) 🚧
- Платежи (внутренний кошелёк / эскроу)
- Видеозвонки внутри чата
- Геолокация и поиск исполнителей по карте
- Push-уведомления через FCM (вместо локальных)

### v1.2 🔮
- AI-помощник для составления карточек
- Рекомендательная лента на основе истории
- Подписки / Premium-аккаунты
- API для интеграции с CRM партнёров

### v2.0 🌟
- Веб-кабинет с расширенной аналитикой
- Marketplace расширений (плагины от сообщества)
- B2B-режим для агентств и бригад

---

## 📜 Лицензия

Проприетарный код. Все права принадлежат команде проекта KORST.

---

## 🤝 Контакты

- **Презентация:** [Canva — KORST Pitch Deck](https://canva.link/fvqthe6w6uqvkhi)
- **Документация Backend:** [`docs/backend.md`](docs/backend.md)
- **Issues:** трекер репозитория

---

<div align="center">

**KORST** — *где задача находит мастера.*

🟡⚫ Plague & Gold • Made with Flutter 💛

</div>
