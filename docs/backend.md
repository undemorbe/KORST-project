Контракты для KORST

Авторизация

Отправка otp кода

POST .../authorize/send-otp

Request:
{
    "phone": "+79123456789"
}


Response:
200 Ok
{}


Подтверждение otp-кода. Если пользователя нет, то он создается. 

POST .../authorize/verify-otp

{
    "phone": "+79...",
    "otp": "6879"
}


200 Ok 
{
    "access-token": "nvrgdsbnvjtrsnbslrtnli",
    "refresh-token": "trbvdshbvkdjbntkfjv bn",
    "status": "registered"
}


Контракт на обновление access-токена: 

GET .../authorize/refresh

Request:

{
    "refresh-token": "tnbaoeriheahboerbt"
}

Response:

{
    "access-token": "tejq0e5h4bw45",
    "refresh-token": "trbh958hbq[0h5bwri"
}


Запрос на проверку пользователя (вместо authorize/is-user):

Проверка, является ли пользователем

Статус может быть:
notFound - не найден в БД
notRegistered - существует, но не зарегистрирован
user - обычный пользователь
admin - админ

В запросе verify-otp статусы такие же

GET .../authorize/check-user

{
    "phone": "+79..."
}

200 Ok 
{
    "status": "registered"
}



Контракт для выхода из аккаунта

POST …/authorize/logout

! В хедере передается access-токен пользователя

!! При этом access-токен пользователя после запроса удаляется на мобилке

Request:
{}

Response:
{}





Карточки



Контракт для отображения конкретной карточки: 

GET .../cards/card-info

Request:
{
    "card-id": "ytsjrtyndytnt"
}

Response:
{
    "name": "Наименование услуги",
    "description": "Описание",
    "image-url": "http://...",
    "price": 100,
    "currency": "USD",
    "type": "услуга",
    "author": {
        "id": "12345567",
        "name": "Олег",
        "surname": "Олегович",
        "image-url": "http://...",
        "phone": "+79123456789",
        "contacts": {
            "email": "merchant@example.com",
            "telegram": "@merchant",
            "others": {
                "facebook": "merchant",
                ...
            },
            "rating": 4.5
        }
    },
    "tags": ["tag1", "tag2", "tag3"],
    "created": "2023-01-01", # Только даты
    "updated": "2023-01-01"
}


Контракт на создание карточки услуги

POST .../cards/save-card

Request: 

!!! Внутри headers передается параметр Authorization, в котором содержится access-token.  По этому токену находится пользователь

{
    "name": "name",
    "description": "description",
    "price": 100,
    "currency": "USD",
    "type": "услуга",
    "tags": ["tag1", "tag2", "tag3"]
}

Если поле не указано пользователем (пустое), ставь null

Response:
{}


Контракт для обновления карточки объявления

POST …/cards/update-card

Если поле не обновляется - не добавлять это поле в json

Request:
{
    "card-id": "rntbsrlnbtrnbtdyjndt",
    "name": "name",
    "description": "description",
    "price": 100,
    "currency": "USD",
    "type": "услуга",
    "tags": ["tag1", "tag2", "tag3"]
}

Response:
{}

Контракт для сохранения изображения карточки

POST …/cards/save-image

! Content-Type: multipart/form-data

Request:
card-id: f83nfkgnrkf9evj4i3    
image: <file> - изображение в формате png (можно и другие, но лучше все в png хранить). Думаю сам разберешься, как отправить)

Response:
{
    "image-url": "http://..."
}

Контракт для отображения карточек (с использование крутой пагинации). Пока что базовая сортировка по времени создания:

GET .../cards/get-cards

Request:
key: “2026-03-16T14:32:10Z”    - если страница первая, то просто отправлять null



Response:
{
    "cards": [
        {
            "id": "12345678 (В формате uuid)",
            "name": "наименование услуги",
            "image-url": "http://...",
            "price": 100,
            "currency": "USD",
            "type": "услуга",
            "author": {
                "id": "buostrndibndtrkynl",
                "name": "Олег",
                "surname": "Олегович", // Контакты думаю после нажатия покажем
                 "image-url": "http://...",
                "rating": 4.5
            },
            "tags": ["tag1", "tag2", "tag3"],
            "created": "2026-03-16T14:32:10Z"
        },
        {
            "id": "87654321",
            ...
        }
    ]
}


Контракт для получения карточек по поиску. Возможно потом изменится

GET .../cards/get-with-query

Request:
key: 2026-03-16T14:32:10Z    - если страница первая, то просто отправлять null
query: some string - фраза, по которой производится поиск

Response аналогичен /get-cards


Контракт для создания отклика на объявление

POST …/cards/create-reply

Request:
{
    "card-id": "rihgui4bwg"
}


Response:
{}


Контракт для утверждения исполнителя на карточку

PUT …/cards/approve-executor

Request:
{
    "card-id": "rihgui4bwg",
    "executor-id": "rwgrwwrht"
}

Response:
{}


Контракт для отклонения исполнителя для карточки

PUT …/cards/reject-executor

Request:
{
    "card-id": "rihgui4bwg",
    "executor-id": "rwgrwwrht"
}

Response:
{}


Контракт для закрытия карточки (только после назначения исполнителя)

Виды статусов:
completed - карточка выполнена и закрывается
closed-with-bad-result - закрыть карточку, не помечается как выполненное для исполнителя 
reopen-with-bad-result - переоткрытие карточки, не помечается как выполненное для исполнителя
reopen-with-good-result - переоткрытие карточки, помечается как выполненное для исполнителя

PUT …/cards/close

Request:
{
    "card-id": "rihgui4bwg",
    "status": "completed"
}

Response: 
{}



Пользователь


Контракт на обновление данных пользователя:

POST .../user/update

Также в хэдере передается access-token (его желательно передавать во всех запросах после авторизации)

Request:

{
    "name": "Олег",
    "surname": "Олегов",
    "description": "описание пользователя",
    "contacts": {
        "email": "oleg@gmail.com",
        "telegram": "@oleg",
        "others": {
            "instagram": "oleg",
            ...
        }
    }
}

Если поле не указано пользователем (пустое), ставь null

Response:
{}

Контракт на сохранение изображения в профиле пользователя

POST …/user/save-image

! Content-Type: multipart/form-data

Request:
image: <file>    - изображение в формате png (можно и другие, но лучше все в png хранить). Думаю сам разберешься, как отправить)

Response:
{
    "image-url": "http://..."
}

Контракт для получения информации о пользователе

GET .../user/get-info

Request:
{
    "user-id": "tknslb,fgn,ndn" // ID пользователя, которого хотим найти
}

Response:
{
    "name": "Денис",
    "surname": "Ткачёв",
    "image-url": "http://..."
    "phone": "+79123456789",
    "description": "Люблю прогуливать пары",
    "rating": 4.5,
    "contacts": {
        "email": "someEmail@gmail.com",
        "telegram": "@eth_higgs",
        "others": {
            "instagram": "tkachev"
        }
    },
    "updated": "2026-03-16T14:32:10Z",
    "created": "2026-03-16T14:32:10Z",
    "cards": [
        {
        "id": "terbj;srtnbsrtnb",
        "name": "Карточка 1",
        "image-url": "http://..."
        "price": 100,
        "currency": "USD",
        "type": "услуга",
        "created": "2026-03-16T14:32:10Z",
        "updated": "2026-03-16T14:32:10Z"
        },
        {
            "id": "er'rnt;bwjn'trb",
            ...
        }
    ]
}.


Контракт для получения информации о текущем пользователе приложения (response идентичен user/get-info) - передается статистика, а также ВСЕ карточки пользователя (активные, исполняемые и завершенные)

Виды статусов карточки:
“active” - карточка активна, ищется исполнитель
“in-progress” - карточка исполняется кем-то
“completed” - успешно завершена
“closed” - закрыта (без завершения)

GET …/user/me

! Передается access-токен

Request:
{}

Response:
{
    "name": "Денис",
    "surname": "Ткачёв",
    "image-url": "http://..."
    "phone": "+79123456789",
    "description": "Люблю прогуливать пары",
    "rating": 4.5,
    "contacts": {
        "email": "someEmail@gmail.com",
        "telegram": "@eth_higgs",
        "others": {
            "instagram": "tkachev"
        }
    },
    "updated": "2026-03-16T14:32:10Z",
    "created": "2026-03-16T14:32:10Z",
    "cards": [
        {
        "id": "terbj;srtnbsrtnb",
        "name": "Карточка 1",
        "image-url": "http://..."
        "price": 100,
        "currency": "USD",
        "type": "услуга",
        "status": "услуга", // ВАЖНО!!! У карточки появляется статус
        "created": "2026-03-16T14:32:10Z",
        "updated": "2026-03-16T14:32:10Z"
        },
        {
            "id": "er'rnt;bwjn'trb",
            ...
        }
    ]
}.

Контракт для отображения отзывов на пользователя

GET .../user/reviews

Request:
{
    "user-id": "ltkdbgsyublsz"
}

Response:
{
    "reviews": [
        {
            "rating": 1,
            "comment": "Просто отвратительный человек",
            "author": {
                "name": "Вася",
                "surname": "Пупкин",
                "image-url": "http://...",
                "rating": 4.5
            }
        },
        {
            "rating": 5,
            ...
        }
    ]
}


Контракт на размещение отзыва на человека

POST .../user/post-review

Request:
{
    "user-id": "blnsrvbsdlsfgbslr",
    "rating": 4.5,
    "comment": "Нормальный тип"
}

Response:
{}





Мессенджер

Контракт для просмотра чатов пользователя:

GET …/messenger/chats

Request: none

Response:
{
    // Чаты с авторами объявлений
    "merchant-chats": [
        {
            "id": "vre;abtruistri;g",


            "user": {
                "id": "vnedbrtednf",
                "name": "Олег",
                "surname": "Олег",
                "image-url": "http://..."
            },


            "last-message": {
                "id": "ernvrebvsj,r",
                "author-id": "ernvrebvsj,r",
                "text": "Привет",
                "created": "2026-03-16T14:32:10Z",
	     "is-seen": true // is-seen используется только для сообщений, где автор сообщения - пользователь. В противном случае поле будет отсутствовать
            }


            "card": {
                "id": "ireoenfdnvdsrb",
                "name": "Название 1",
                "image-url": "http://..."
            }
        }
    ],
    // Чаты, где пользователь - автор объявления
    "customer-chats": [
        {
            "id": "bbfnkdbnerb",
            ...
        }
    ]
}



Контракт для просмотра конкретного чата:

GET …/messenger/messages

Request (params): 

chat-id: 848a7em9fk3n8kif93

!!! Массив сообщений отсортирован по убыванию, т.е. первое сообщение в массиве - последнее отправленное

Response:
{
    "messages": [
        {
            "id": "vreoubeoor39vr",
            "author-id": "frjb0ej43v3",
            "text": "Привет", // может отсутствовать, если есть только изображение
            "imageURL": "https://..", // Присутствует только если есть картинка
            "created": "2026-01-02...",
	 "is-seen": true // is-seen используется только для сообщений, где автор         сообщения - наш пользователь. Я буду присылать для каждого сообщения, используй только для пользователя
        },
        {
            "id": "nrjvbeskbvf",
            ...
        }
    ]
}


Контракт для создания чата с пользователем (перед отправкой первого сообщения)

POST …/messenger/create-chat

Request:
{
    "user-id": "hutditbreu43ui3," // Id пользователя, с которым создается чат
    "card-id": "btdbfdnrnbdn" // Карточка, к которой относится чат
}

Response:
{}


Контракт для отправки сообщения

POST …/messenger/send-message

Request:

! Нужно отправлять access-токен в header

{
    "chat-id": "hutditbreu43ui3,",
    "text": "Здарова"
}


Response:
{}


Контракт для отправки сообщения с картинкой (можно без текста, только изображение)

POST …/messenger/send-image

Request:
! Content-Type: multipart/form-data

chat-id: gjdi6nv9enohermb4 
text: Текст к изображению   - Если текста нет, оставить поле пустым (а лучше вообще его не отправлять)    
image: <file> - изображение в формате png (можно и другие, но лучше все в png хранить). Думаю сам разберешься, как отправить)

Response:
{}

Контракт для изменения сообщения

PUT …/messenger/change-message

Request:
{
    "message-id": "srbdabsbestvsrae",
    "text": "Измененный текст"
}

Response:
{}

Контракт для удаления сообщения

DELETE …/messenger/delete-message

Request:
{
    "message-id": "srbdabsbestvsrae"
}

Response:
{}






Рекламные баннеры

Контракт для размещения рекламного баннера

POST …/banners/post-banner

! Content-Type: multipart/form-data

Request:
image: <file>
link: https://…
name: <Название баннера>  - название баннера
company: <Название компании> - просто формальность, чтобы в теории можно было определять баннеры компании

Response: 
{}

Контракт скорее не для мобилки, а просто для ручного размещения баннеров.




Контракт для отображения баннеров

GET …/banners/get-banners

Дефолтное значение для count - 5, смысла в отправке вообще всех баннеров не вижу - просто указывай сколько надо (если столько не наберется, то пришлю сколько есть)

Request:
count: 5 - количество баннеров

Response:




WebSocket мессенджер

Подключение

WS …/messenger/ws

! Токен передаётся в header и в query-параметре:
  Header: access-token: <token>
  Query:  ?access-token=<token>

Соединение устанавливается при входе пользователя в приложение и держится всё время сессии.
Переподключение — с экспоненциальной задержкой (1, 2, 4, 8, 16 … 30 сек).


Формат входящего события — новое сообщение в чате

{
    "chat-id": "848a7em9fk3n8kif93",
    "message": {
        "id": "vreoubeoor39vr",
        "author-id": "frjb0ej43v3",
        "text": "Привет",               // может отсутствовать, если только изображение
        "imageURL": "https://...",       // присутствует только если есть картинка
        "created": "2026-01-01T00:00:00Z",
        "is-seen": false                 // только для исходящих сообщений (автор = текущий пользователь)
    }
}

Формат входящего события — обновление чата (например, первое сообщение / смена last-message)

{
    "chat-id": "848a7em9fk3n8kif93",
    "chat": {
        "id": "848a7em9fk3n8kif93",
        "user": {
            "id": "vnedbrtednf",
            "name": "Олег",
            "surname": "Олегов",
            "image-url": "http://..."
        },
        "last-message": {
            "id": "ernvrebvsj,r",
            "author-id": "ernvrebvsj,r",
            "text": "Привет",
            "created": "2026-03-16T14:32:10Z",
            "is-seen": false
        },
        "card": {
            "id": "ireoenfdnvdsrb",
            "name": "Название",
            "image-url": "http://..."
        }
    }
    
}
Контракт для получения исполнителей для карточки



GET …/replies/executors



Request (Params):

card-id: 848a7em9fk3n8kif93



Response:

{

    "executors": [

        {

            "id": "kefknbkwnkmnwk",

            "name": "Олег",

             "surname": "Олегов",

            "image-url": "https://...",

            "rating": 4.5

        },

        ...

    ]

}



!! Поле data — допустимая обёртка. Если payload приходит внутри data, клиент разворачивает его автоматически:

{
    "chat-id": "848a7em9fk3n8kif93",
    "data": {
        "message": { ... }   // или "chat": { ... }
    }
}

Поведение клиента при получении события:
- Если событие содержит message и chat-id совпадает с открытым чатом → вставить сообщение в начало списка (дедупликация по id)
- Если событие содержит chat (или chat-id + message) → обновить last-message в списке чатов
- Если чат не найден в локальном списке → перезагрузить список чатов с сервера
- Если message.author-id ≠ текущий пользователь → показать push-уведомление





