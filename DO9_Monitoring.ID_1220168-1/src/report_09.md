## Part 1. Получение метрик и логов

В этой главе тебе предстоит настроить Prometheus и Loki для сбора метрик и логов приложения.

### Задание

1. Использовать Docker Swarm из первого проекта. 
- Для реализации этой части я взял необходимые файлы для успешного запуска из проекта **DO7**.
- Скрипты:
   1. init_swarm
   2. install_docker
   3. join-swarm
- Vagrantfile
- docker-compose.yml
- nginx из сервисов
- Далее я запустил **vagrant** и стэк сервисов командой **docker stack deploy --with-registry-auth -c docker-compose.yml my app**. Убедился, что всё работает командой **docker service ps $(docker service ls -q)**

![running services](./Screenshots/Part_1.1_running-services.png)

2. Написать при помощи библиотеки Micrometer сборщики следующих метрик приложения: 
   - количество отправленных сообщений в rabbitmq;
   - количество обработанных сообщений в rabbitmq;
   - количество бронирований;
   - количество полученных запросов на gateway;
   - количество полученных запросов на авторизацию пользователей.

   - В этом пункте редактируются 4 сервиса - **booking-service, session-service, report-service, gateway-service**. Ничего не удаляется, только добавляются сборщики метрик в файлы **pom.xml** и **application.properties**.
   - В **application.properties** в конец файла добавляется метрики:
   ```
   management.endpoints.web.exposure.include=prometheus,health,info
   management.metrics.export.prometheus.enabled=true
   management.endpoint.prometheus.enabled=true
   ```
   - Для файла **pom.xml** был создан отдельный файл с зависимостями **Micrometer** - **pom-dependency.xml**. Для добавления этих зависимостей в файл я использовал командну **sed -i '/<dependencies>/r /vagrant/pom-dependency.xml' services/booking-service/pom.xml**. 
   ```
   <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
      <version>1.12.5</version>
   </dependency>
   <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-amqp</artifactId>
   </dependency>
   ```
   - После редактирования и добавления всех зависимостей пересобираются образы сервисов, которые я использовал.
   - **mvn clean package -DskipTests**, **docker build -t ...**, **docker push ...**. Для сохранения изменений в **Docker Hub**, я использовал другой тег, чтобы можно было отличить рабочий образ, от нерабочего. Например, **do9**, вместо **latest**, как использовалось ранее.
   - Если во время сборки и пуша был использован другой **тэг**, то в docker-compose нужно поменять на нужный образ.
   - И только после этого запускать стек
   - Также не исключено, что во время собрки возникнут ошибки. Появятся так называемые "битые" сборки. Команда **rm -rf target ~/.m2/repository/io/micrometer** поможет их удалить и по-новой запустить сборку
   - Результатом того, что всё удачно собрано и работает является не только вывод работоспособности сервисов в консоли командой **docker service ps $(docker service ls -q)** или **docker stack ps -f "desired-state=Running"**, но и результаты тестов **Postman**. Потому что сервисы могут все работать, но если есть какие-то проблемы, то тесты их покажут точно.

![update services and tests postman](./Screenshots/Part_1_update_services_and_tests_postman.png)

3. Добавить логи приложения с помощью Loki.
   - Первым делом я устанаовил плагин **Loki** на всех 3-х нодах. Так как каждый из сервисов может быть запущен на любом ноде, то для сбора всех логов со всех контейнеров нужно как раз-таки установить плагин на каждом ноде командой **docker plugin install grafana/loki-docker-driver:3.0.0 --alias loki --grant-all-permissions**.
   - Далее командой **docker plugin ls** нужно проверить, что на каждом ноде установился плагин

   ![docker plugin ls](./Screenshots/Part_1.3_plugil_on_node.png)

   - После было добавлено логгирование каждого сервиса из стека **myapp** в **docker-compose**. Все логи от этого контейнера будут автоматически отправляться в централизованное хранилище **Loki** 

   ![added logging in docker-compose](./Screenshots/Part_1.3_logging_in_docker-compose.png)

4. Создать новый стек для Docker Swarm из сервисов с Prometheus Server, Loki, node_exporter, blackbox_exporter, cAdvisor. Проверить получение метрик на порту 9090 через браузер.
   - Для выполнения этого пункта задания был создан файл **monitoring-stack.yml**. В этом файле точно также как и в **docker-compose** описаны сервисы; какие образы скачивать и на каком порту работать.
   - Далее запускается стек командой **docker stack deploy -c monitoring-stack.yml monya**

   ![monya stack up](./Screenshots/Part_1.4_stack_up.png)

   ```То есть сначала запускается стек сервиса отелей, а потом стек мониторинга```

   - Проверка, что **loki** готов к работе.

   ![loki ready](./Screenshots/Part_1.4_loki_ready.png)

   - Проверка получения логов через **loki** в **grafana**. Для проверки я запустил тесты **Postman**, после запуска которых стали видны логи.

   ![logi in loki 1](./Screenshots/Part_1.4_logi_in_loki.png)

   ![logi in loki 2](./Screenshots/Part_1.4_logi_in_loki_2.png)

   - Далее я через браузер открыл **Prometheus**. Узнал, что все сервисы запущены и работают

   ![prometheus targets](./Screenshots/Part_1.4_up_targets.png)

   ![metrics services](./Screenshots/Part_1.4_metrics_services_monya.png)

   - После я проверил получение нескольких метрик 

   ![metrics cadvisor](./Screenshots/Part_1.4_metric_cadvisior.png)

   ![metrics node_exporter](./Screenshots/Part_1.4_metric_node_exporter.png)

## Part 2. Визуализация

В этой главе тебе предстоит настроить Grafana для визуализации метрик и логов.
**Допиши названия метрик и что они означают из первой части!!!!**
### Задани

1. Развернуть grafana как новый сервис в стеке мониторинга.
   - В файл **monitoring-stack** была указана визуализация **Grafana**

   ![grafana in monitoring stack](./Screenshots/Part_2.1_grafana_in_monitoring.png)

2. Добавить в Grafana дашборд со следующими метриками:
   - количество нод; - **count(count by (instance) (node_cpu_seconds_total))**

   ![quantity nods](./Screenshots/Part_2.2_metric_1.png)

   - количество контейнеров; - **count(node_cpu_seconds_total{mode="system"})**

   ![quantity containers](./Screenshots/Part_2.2_metric_2.png)

   - количество стеков; - **count(count by (container_label_com_docker_swarm_stack) (container_last_seen))**

   ![quantity stacks](./Screenshots/Part_2.2_metric_3.png)

   - использование CPU по сервисам; - **sum(rate(container_cpu_usage_seconds_total{image!=""}[1m])) by (name)**

   ![cpu of services](./Screenshots/Part_2.2_metric_4.png)

   - использование CPU по ядрам и узлам; - **sum(rate(node_cpu_seconds_total{mode!="idle"}[1m])) by (instance)**

   ![cpu cores and nodes](./Screenshots/Part_2.2_metric_5.png)

   - затраченная RAM; - **node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes**

   ![ram](./Screenshots/Part_2.2_metric_6.png)

   - доступная и занятая память; - **node_memory_MemAvailable_bytes**

   ![memory](./Screenshots/Part_2.2_metric_7.png)

   - количество CPU; - **count(count by (cpu) (node_cpu_seconds_total{mode="system"})) by (instance)**

   ![quantity cpu](./Screenshots/Part_2.2_metric_8.png)

   - доступность google.com; - **probe_duration_seconds{instance=~"$target"}**

   ![google](./Screenshots/Part_2.2_metric_9.png)

   - количество отправленных сообщений в rabbitmq; - **rabbitmq_published_total**

   ![sent message in rabbitmq](./Screenshots/Part_2.2_metric_10.png)

   - количество обработанных сообщений в rabbitmq; - **rabbitmq_consumed_total**

   ![processed message in rabbitmq](./Screenshots/Part_2.2_metric_11.png)

   - количество бронирований; - **http_server_requests_seconds_max**

   ![quantity booking](./Screenshots/Part_2.2_metric_12.png)

   - количество полученных запросов на gateway; - **http_server_requests_seconds_max{instance="192.168.56.10:8087"}**

   ![quantity request gateway](./Screenshots/Part_2.2_metric_13.png)

   - количество полученных запросов на авторизацию пользователей; - **http_server_requests_seconds_count{job="session-service"}**

   ![quantity request session](./Screenshots/Part_2.2_metric_14.png)

   - логи приложения.

   ![logs app](./Screenshots/Part_2.2_logs_app.png)

## Part 3. Отслеживание критических событий

В этой главе тебе предстоит настроить Alert Manager для оповещения о критических событиях.

### Задание

1. Развернуть Alert Manager как новый сервис в стеке монтиторинга.
   - Для выполнения этого пункта был добавлен новый сервис в файл **monitoring-stack.yml**. 

   ![added alert manager](./Screenshots/Part_3.1_alertmanager.png) 

2. Добавить следующие критические события:
   - В проекте был создан файл **alerts.yml**. В нем указаны критические события из задания указанных ниже
   - доступная память меньше 100 Мб;
   - затраченная RAM больше 1 Гб;
   - использование CPU по сервису превышает 10%.

```

groups:
- name: critical_alerts
   interval: 30s
   rules:
   # 1. Доступная память меньше 100 Мб
   - alert: LowAvailableMemory
      expr: node_memory_MemAvailable_bytes < 100 * 1024 * 1024
      for: 1m
      labels:
         severity: critical
      annotations:
         summary: "Критически мало свободной памяти"
         description: "На ноде {{ $labels.instance }} осталось менее 100 Мб свободной памяти. Текущее значение: {{ $value | humanize1024 }}"

   # 2. Затраченная RAM больше 1 Гб
   - alert: HighUsedMemory
      expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) > 1 * 1024 * 1024 * 1024
      for: 2m
      labels:
         severity: warning
      annotations:
         summary: "Высокое использование памяти"
         description: "На ноде {{ $labels.instance }} используется более 1 Гб RAM. Текущее значение: {{ $value | humanize1024 }}"

   # 3. Загрузка процессора сервисом превышает 10%
   - alert: HighContainerCPU
      expr: rate(container_cpu_usage_seconds_total{container_label_com_docker_swarm_service_name!=""}[5m]) > 0.1
      for: 2m
      labels:
         severity: warning
      annotations:
         summary: "Высокая нагрузка CPU на контейнер"
         description: "Контейнер {{ $labels.container_label_com_docker_swarm_service_name }} использует >10% CPU. Текущее значение: {{ $value | humanizePercentage }}"

```

3. Настроить получение оповещений через личные email и Телеграм.

   - Далее был написан файл **alertmanager.yml**. В этом файле указываются **почта**, куда будет приходить письмо о критических событиях, **тг-бот** для получения оповещений. Настаиваются токены доступа, пароли приложений. Обязательно добавляются в этот файл, чтобы менеджер знал куда отправлять оповещения. Без этих данных работать ничего не будет.
   - После внесения изменений, а также создания новых файлов. Нужно перезапустить **стек мониторинга** полностью, чтобы новый сервис отобразился в консоли и начал свою работу.

   ![new alertmanager](./Screenshots/Part_3.3_alert_up.png)

   - После того как стек запустился, можно открыть браузер на локальном хосте и ввести адрес **http://localhost:9090/rules** - должны отобразиться правила, которые были прописаны в **alerts.yml**. И другой вкладке (например) открыть **http://localhost:9090/alerts**. Там будут показана нагрузка на ноды. ```Если нагрузка будет критической, то на почту и в тг-бот придет уведомление```

   - Правила, которые отображаются в браузере, где запущен **prometheus**

   ![rules in prometheus](./Screenshots/Part_3.3_rules_in_prometheus.png)

   - До нагрузки:

   ![no load](./Screenshots/Part_3.3_no_load.png)

   - После нагрузки:

   ![on load](./Screenshots/Part_3.3_on_load.png)

   - Оповещение, которое мне пришло на почту
   
   ![message in mail](./Screenshots/Part_3.3_mail.png)

   ![message in mail 2](./Screenshots/Part_3.3_mail_2.png)

   ![message in mail 3](./Screenshots/Part_3.3_mail_3.png)

   - Оповещение из тг-бота:

   ![message in telegram](./Screenshots/Part_3.3_tg_alert.png)

   ![message in telegram 2](./Screenshots/Part_3.3_tg_alert_2.png)

   ![message in telegram 3](./Screenshots/Part_3.3_tg_alert_3.png)

```
Для проверки получения сообщений в телеграме мне помогла команда, которая отправляет простое сообщение при условии, что всё настроено правильно. Если сообщение пришло, но алерты нет, то дело в конфиге файла
curl -X POST https://api.telegram.org/bot<ТВОЙ_ТОКЕН>/sendMessage \
  -d chat_id="<ТВОЙ_CHAT_ID>" \
  -d text="Тестовое сообщение из консоли"
```