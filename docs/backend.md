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

Пока что так, потом возможно изменится

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


Контракт для получения информации о текущем пользователе приложения (response идентичен user/get-info)

GET …/user/me

! Передается access-токен

Request:
{}

Response: идентичен предыдущему контракту GET …/user/get-info

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
                "created": "2026-03-16T14:32:10Z"
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
            "text": "Привет",
            "created": "2026-01-02..."
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

