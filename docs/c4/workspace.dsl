workspace "Маркетплейс" "C4 контейнеры" {

  model {
    buyer  = person "Покупатель" "Смотрит ленту заказывает оплачивает"
    seller = person "Продавец"   "Добавляет товары следит за заказами"

    ui = softwareSystem "Сайт и приложение" "Интерфейс покупателя и продавца"

    mp = softwareSystem "Маркетплейс" "Бэкенд маркетплейса" {
      api = container "Шлюз API" "Один вход для UI" "HTTP"

      users    = container "Пользователи" "Аккаунты роли" "Service"
      catalog  = container "Каталог" "Товары категории атрибуты" "Service"
      feed     = container "Лента" "Выдача и ранжирование" "Service"
      orders   = container "Заказы" "Создание и статусы" "Service"
      payments = container "Платежи" "Факт оплаты и учет" "Service"
      notify   = container "Уведомления" "Отправка и лог" "Service"

      broker = container "Брокер событий" "События между сервисами" "Kafka или RabbitMQ"

      usersDb   = container "Users DB" "Данные пользователей" "PostgreSQL" "Database"
      catalogDb = container "Catalog DB" "Данные каталога" "PostgreSQL" "Database"
      feedDb    = container "Feed DB" "Read модель ленты" "Redis или PostgreSQL" "Database"
      ordersDb  = container "Orders DB" "Данные заказов" "PostgreSQL" "Database"
      payDb     = container "Payments DB" "Данные платежей" "PostgreSQL" "Database"
      notifyDb  = container "Notify DB" "История доставок" "PostgreSQL" "Database"
    }

    payProvider = softwareSystem "Платежный провайдер" "Внешняя оплата"
    msgProvider = softwareSystem "Провайдер сообщений" "Email SMS push"

    buyer  -> ui "sync"
    seller -> ui "sync"

    ui -> api "sync"

    api -> users    "sync"
    api -> catalog  "sync"
    api -> feed     "sync"
    api -> orders   "sync"
    api -> payments "sync"

    users    -> usersDb   "sync"
    catalog  -> catalogDb "sync"
    feed     -> feedDb    "sync"
    orders   -> ordersDb  "sync"
    payments -> payDb     "sync"
    notify   -> notifyDb  "sync"

    orders   -> broker "async"
    payments -> broker "async"
    catalog  -> broker "async"

    broker -> notify "async"
    broker -> feed   "async"
    broker -> orders "async"

    payments -> payProvider "sync"
    notify   -> msgProvider "sync"
  }

  views {
    container mp containers "containers" {
      include *
      include buyer
      include seller
      include ui
      include payProvider
      include msgProvider
      autoLayout lr
    }
  }
}
