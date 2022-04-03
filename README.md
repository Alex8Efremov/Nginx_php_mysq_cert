# Nginx_php_mysq_cert Debian 9+

## Для установки с нуля:

Даем права исполнения chmod +x sert.sh nginx.sh cert_update.sh.

## В файлах HE меняем example.com на свой домен. Меняется автоматически.

В файле cert_update.sh в конце можно заменить git repository на ту в которой хранится сайт.

## Запуск установки: 

Будет задан вопрос о назначении domain name. вписываем свой www (будет добавлен автоматом).

По очереди запускаю файлы в папке:

# ./nginx.sh  ./sert.sh  ./cert_update.sh

На втором файле вписываю свой email и со всем соглашаюсь. В конце выбираю "1 2".

Разделение файлов, сделано для того чтобы можно было без ошибок установить как с сертификатом, так и без него.

## На этом этапе у нас установлен nginx с поддержкой php, mysql, переадресацией http на https и самообновляющимся бесплатным ssl сертификатом.

# Добавить домен:

Папка add_domain содержит 2 вида добавления домена

1) Создание отдельного конфиг файла и назначение сертификата

2) Аналогично первой но еще добавлен функционал proxy
