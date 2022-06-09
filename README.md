https://www.zabbix.com/documentation/current/ru/manual/installation/containers

Делаем сеть 
docker network create --subnet 10.14.85.0/28 zabbix-net

docker run --name zabbix-java-gateway -t  --network=zabbix-net --restart unless-stopped -d zabbix/zabbix-java-gateway:ubuntu-5.4-latest

докер уже есть и работает на порту 54311
готовый образ базы --
docker run --name postgres-server -t \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="zabbix" \
--network=zabbix-net \
--restart unless-stopped \
-d postgres:latest


docker run --name zabbix-server-pgsql -t \
             -e DB_SERVER_HOST="192.168.234.106" \
             -e DB_SERVER_PORT="54311" \
             -e POSTGRES_USER="zabbix" \
             -e POSTGRES_PASSWORD="zabbix" \
             -e POSTGRES_DB="zabbix" \
             -e ZBX_JAVAGATEWAY_ENABLE="true" \
             -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
             --network=zabbix-net \
             -p 10051:10051 \
             --restart unless-stopped \
             -d zabbix/zabbix-server-pgsql:ubuntu-5.4-latest

docker run --name zabbix-web-nginx-pgsql -t \
-e ZBX_SERVER_HOST="zabbix-server-pgsql" \
-e DB_SERVER_HOST="192.168.234.106" \
-e DB_SERVER_PORT="54311" \
-e POSTGRES_USER="zabbix" \
-e POSTGRES_PASSWORD="zabbix" \
-e POSTGRES_DB="zabbix" \
--network=zabbix-net \
-p 8081:8080 \
--restart unless-stopped \
-d zabbix/zabbix-web-nginx-pgsql:ubuntu-5.4-latest

Устанавливаем zabbix-agent
Клиент может быть двух видов:

Обычный агент — сервер получает доступ к узлу мониторинга и забирает данные;
Активный агент — клиент сам отправляет данные серверу.
Активный агент.

Для добавления узла мониторинга не имеющего статического IP-адреса необходимо выполнить 4 условия:

В параметре ServerActive настройки агента указывается IP-адрес Zabbix server.
Межсетевой экран должен иметь разрешение на исходящий порт 10051. Будет не плохо если сразу добавите правило и для входящего порта 10050.
Шаблон, который используется для узла должен иметь во всех элементах данных параметр Zabbix agent (активный).
При настройке узла в параметре Интерфейсы агента указывается IP-адрес 0.0.0.0 — это говорит что принимать данные нужно с любого адреса, подключение через IP-адрес и указывается порт 10051.
По умолчанию почти во всех шаблонах параметр сбора стоит Zabbix agent. Менять эти параметры в стандартных шаблонах не целесообразно.

Например, для мониторинга узла без статического IP-адреса работающего на операционной системе Linux необходимо взять шаблон Template OS Linux и произвести его полное клонирование. Название шаблона сделайте понятным для понимания того, что в шаблоне используется параметр активного агента.

Внимание! Как в новом шаблоне сделать параметр Zabbix agent (активный) во всех параметрах вы разберетесь сами — это не сложно. Обязательно создайте полную копию шаблона Template App Zabbix Agent с аналогичным изменением параметра агента. Главное не забудьте поменять его в присоединенных шаблонах вашего нового шаблона.

nano /etc/zabbix/zabbix_agentd.conf
# IP-адрес, с которого будут подключаться к Zabbix agent
Server=192.168.0.30
# Порт, который слушает Zabbix agent (по умолчанию дефолту tcp порт 10050)
ListenPort=10050
# IP-адрес Zabbix agent - адрес, к которому Zabbix agent будет обращаться, что бы отправить результаты активной проверки
ServerActive=192.168.0.30:10051
# Имя Zabbix agent компьютера - тут указываем такое же имя как стоит на Zabbix server в настройках хоста, который мы мониторим
Hostname=cos7client1
# Время ожидания приёма-передачи информации между Zabbix server и Zabbix agent
Timeout=20
# Вы можете включить в файл конфигурации отдельные файлы или все файлы в каталоге
Include=/etc/zabbix/zabbix_agentd.d/*.conf
