## Part 1. Использование готового манифеста

### Задание

1. Запустить окружение Kubernetes с памятью 4 GB.
    - Для выполнения этого задания мне потребовалось сначала установить **minikube** на виртуальную машину. А именно:
        1. Командой **curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64** установил актуальную версию **minikube**
        2. Установить **minikube** в системную директорию **sudo install minikube-linux-amd64 /usr/local/bin/minikube**
        3. Проверить установку **minikube version**

    ![install minikube](./Screenshots/Part_1.1_install_minikube.png)
    - Так как я с **Kubernetes** сталкиваюсь в первые, то также необходимо необходимо установить **kubectl** - это главный инструмент для управления **kubernetes**.
        1. **curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"**
        2. Делается исполняемым **chmod +x kubectl**
        3. Копируется в системную директорию **sudo mv kubectl /usr/local/bin/**
    
    ![install kubectl](./Screenshots/Part_1.1_install_kubectl.png)

    - Далее уже можно запустить окружение **Kubernetes** c памятью 4 GB командой **minikube start --driver=docker --memory 4096 --cpus 2**

    ![start minikube](./Screenshots/Part_1.1_start_minikube.png)

    - Можно проверить работоспособность кластера:
        1. **kubectl cluster-info** - показывает, что кластер запущен и работает (должно быть **Kubernetes control plane is running...**)
        2. **kubectl get nodes** - Показывает количество нод в кластере. Пока только один - **minikube**  в статусе **ready**
        3. **kubectl get pods -A** - Показывает, какие поды (контейнеры) уже работают

    ![check minikube](./Screenshots/Part_1.1_check_minikube.png)

2. Применить манифест из директории `/src/example` к созданному окружению Kubernetes.
    - Для выполнения этого пункта я использовал команду **kubectl apply -f example/microservices.yml**. 

    ![apply manifest](./Screenshots/Part_1.2_apply_manifest.png)

    - Чтобы проверить, что манифест был применен успешно, я использовал команду **kubectl get pods**. Команда, которая выводт на экран все поды (ну или ноды).

    ![running pods](./Screenshots/Part_1.2_running_pods.png)

3. Запустить стандартную панель управления Kubernetes с помощью команды `minikube dashboard`.
    - В этом пункте запустил командой **minikube dashboard** панель, которая вывела мне ссылку на **Kubernetes Dashboard**. 
    
    ![minikube dashboard](./Screenshots/Part_1.3_minikube_dashboard.png)

    - Но так как на вм нету браузера, то мне пришлось командой **ssh -L 42533:localhost:42533 nieshays@192.168.0.101** на локальном хосте пробросить порт, чтобы через браузер войти в эту панель (с другой консоли). 

    ![dashboard in browser](./Screenshots/Part_1.3_dashboard_in_browser.png)

    - В этом браузере визуализируется дашборд kubernetes. При помощи него можно управлять кластером. Например, добавлять новые сервисы, посмотреть сколько подов вообще запущено, хорошо помогает для отладки и настройки, можно увидеть логи любого сервиса, которые точно также выводятся в консоль. 

    ![logs in dashboard kubernetes](./Screenshots/Part_1.3_logs_in_dashboard_kubernetes.png)

    ![logs](./Screenshots/Part_1.3_logs.png)    

4. Прокинуть туннели для доступа к развернутым сервисам с помощью команды `minikube service`.
    - Командой **minikube service apache** (и так для всех 4-х сервисов) я пробросил порт к сервису. Команда **minikube service list** показало результат:

    ![ports list](./Screenshots/Part_1.4_ports_list.png)

    - Далее в консоли локального хоста я пробросил порты вручную **ssh -L 30331:192.168.49.2:30331 nieshays@192.168.0.101**
    - Затем консоль перекинула на виртуальную машину и через **curl** я проверил, что возврещается HTML-страница 
    - Но на всякий случай я пробросил все порты: ```ssh -L 30331:192.168.49.2:30331 -L 31272:192.168.49.2:31272 -L 31012:192.168.49.2:31012 -L 30323:192.168.49.2:30323 nieshays@192.168.0.101```

5. Удостовериться в работоспособности развернутого приложения, открыв в браузере страницу приложения (сервис apache).
    - Как только я увидел в консоли HTML-страницу, то далее уже открыл браузер на локальной машине и в строке адреса ввел URL **http://localhost:30331**, то сразу открылась страница (**apache**)

    ![apache in browser](./Screenshots/Part_1.5_apache.png)


## Part 2. Написание собственного манифеста

### Задание

1. Написать собственные yml-файлы манифестов для приложения из первого проекта (`/src/services`), реализующие следующее:
   - карту конфигурации со значениями хостов БД и сервисов,
   - секреты с паролем и логином к БД и ключами межсервисной авторизации (их можно найти в файлах `application.properties`),
   - поды и сервисы для всех модулей приложения: postgres, rabbitmq и 7 сервисов приложения. Для всех сервисов нужно использовать единственную реплику.

   - Для выполнения этого пункта были написаны манифесты в количестве 11 штук. Для каждого сервиса отдельно, в том числе карту конфигурации и секретов. Ниже в скриншоте я использовал пример манифеста **booking-service**. В этом файле очень важно указать все зависимости с которыми работает этот сервис!!!

   ![configuration map](./Screenshots/Part_2.1_configuration_map.png)

   ![file secrets](./Screenshots/Part_2.1_file_secrets.png)

   ![booking manifest](./Screenshots/Part_2.1_boking_manifest.png)

2. Запустить приложение путем последовательного применения манифестов командой `kubectl apply -f <манифест>.yaml`.
    - Можно, конечно по отдельности, но так как у меня много этих манифестов, то я использовал команду **kubectl apply -f services/**. Эта команда запускает все манифесты подряд.
    - Но можно и последовательно. Сначала запускается **configmap.yaml**, затем **secrets.yaml**, а после все остальные сервисы.

    ![apply manifest](./Screenshots/Part_2.2_mi=anifest_apply.png)

3. Проверить статус созданных объектов (секреты, конфигурационная карта, поды и сервисы) в кластере с помощью команд `kubectl get <тип_объекта> <имя_объекта>` и `kubectl describe <тип_объекта> <имя_объекта>`. Результат отобразить в отчете.
    
    - Командой **kubectl get pods** проверил, что все поды запущены и работают без ошибок. 

    ![running pods](./Screenshots/Part_2.3_running_pods.png)

    - Проверка статуса **secret** командами **kubectl get secrets** и **kubectl describe secret app-secrets**

    ![get secret](./Screenshots/Part_2.3_get_secrets.png)

    - Проверка статуса **configmap**. **kubectl get configmap** и **kubectl describe configmap app-config**

    ![get configmap](./Screenshots/Part_2.3_get_configmap.png)

    - Проверка статуса запущеных подов. **kubectl get pods -o wide** и **kubectl describe booking-service-9644ccdd65-c4r2q**

    ![get pods](./Screenshots/Part_2.3_get_pods.png)

    - Проверка статуса запущенных сервисов. **kubectl get services** и **kubectl describe service gateway-service**

    ![get services](./Screenshots/Part_2.3_get_service.png)

4. Проверить наличие правильных значений секретов, применив, например, команду `kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 --decode` для декодирования секрета.
    ```
    kubectl get secret app-secrets -o jsonpath='{.data.POSTGRES_USER}' | base64 --decode
    kubectl get secret app-secrets -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 --decode
    kubectl get secret app-secrets -o jsonpath='{.data.RABBITMQ_USER}' | base64 --decode
    kubectl get secret app-secrets -o jsonpath='{.data.RABBITMQ_PASSWORD}' | base64 --decode
    kubectl get secret app-secrets -o jsonpath='{.data.GATEWAY_UUID}' | base64 --decode
    kubectl get secret app-secrets -o jsonpath='{.data.BOOKING_UUID}' | base64 --decode
    ```

    ![secrets](./Screenshots/Part_2.4_secrets.png)

5. Проверить логи приложения, запущенного в кластере, командой `kubectl logs <имя_контейнера>`. Скриншот отобразить в отчете.
    - Для примера я взял логи **gateway-service**. Как видно из логов: никаких критических ошибок и предупреждений нету. 
    
    ```Если логов очень много, то очень удобно использовать утилиту **grep** для фильтрации логов. Например **kubectl logs gateway-service-549779c7c6-rtnbj | grep "WARN"**, здесь покажутся логи со статусом **WARN**. Но есть такие предупреждения из-за которых сервис будет постоянно перезагружаться и не будет стабильного состояния **Running**. В таком случает нужно внимательно читать логи и узнать чего именно не хватает этому сервису.```

    ![logs gateway-service](./Screenshots/Part_2.5_logs_gateway-service.png)

6. Прокинуть туннели для доступа к gateway service и session service.
    - Были открыты разные терминалы и в каждом из них был проброшены порты к **gateway** и **session**. 
    ``` 
    kubectl port-forward service/gateway-service 8087:8087
    kubectl port-forward service/session-service 8081:8081
    ```

    ![forwarding ports gateway](./Screenshots/Part_2.6_port_gateway.png)

    ![forwarding ports session](./Screenshots/Part_2.6_port_session.png)

7. Запустить функциональные тесты Postman и удостовериться в работоспособности приложения.
    - Для этого задания очень важно, чтобы порты в манифестах (файлах yaml) были правильно указаны. В противном случае тесты **Postman** не все пройдут.
    - Если какой-то из сервисов в тестах выдал ошибку, то можно попробовать его перезапустить командой **kubectl rollout restart deployment loyalty-service** (Это как пример)

    ![tests postman](./Screenshots/Part_2.7_postman_tests.png)

8. Запустить стандартную панель управления Kubernetes с помощью команды `minikube dashboard`. Отобразить в отчете следующую информацию в виде скриншотов с дашборда: текущее состояние узлов кластера, список запущенных Pod, а также другие метрики, такие как загрузка ЦП и память, логи Pod, конфигурации и секреты.

    ![dashboard kubernetes](./Screenshots/Part_2.8_dashboard_kubernetes.png)

    - Текущее состояние узлов кластера

    ![cluster info](./Screenshots/Part_2.8_cluster.png)

    - Список запущеных подов

    ![pods list](./Screenshots/Part_2.8_pods.png)

    - Загрузка CPU и памяти

    ![cpu and memory](./Screenshots/Part_2.8_cpu_and_memories.png)

    - Для примера я взял логи пода booking-service

    ![logs pod](./Screenshots/Part_2.8_logs_pod.png)

    - Файл конфигурации

    ![configmap](./Screenshots/Part_2.8_configuration.png)

    - Секреты

    ![secrets](./Screenshots/Part_2.8_secrets.png)

9. Обновить приложение (добавив новую зависимость в pom-файл) и пересобрать его со следующими стратегиями развертывания (замерить время переразвертывания приложения для каждого случая и отметить результаты в отчете):
   - пересоздание (recreate),
   - последовательное обновление (rolling).

   - 1. В сервисе бронирования в файле pom.xml была добавлена зависимость для скачивания библеотеки **common-lang3**:

   ```
    <dependency>
        <groupId>org.apache.commons</groupId>
        <artifactId>commons-lang3</artifactId>
        <version>3.12.0</version>
    </dependency>
   ```
    - 2. Далее командами **mnv cleap package -DskipTests**, **docker build -t nieshays/booking-service:do10 .**, **docker push nieshays/booking-service:do10** пересобрал образ и запушил его в репозиторий **docker hub**.
    - 3. В манифесте **booking.yaml** исправил образ на **do10**.
    - 4. Применил изменения командой **kubectl apply -f services/booking.yaml**
    - 5. Выполнил шаг пересоздания сервиса 
    ```
    echo "=== RECREATE START ===" && date
    kubectl rollout restart deployment/booking-service
    kubectl rollout status deployment/booking-service
    echo "=== RECREATE END ===" && date
    ```

    ![recreate](./Screenshots/Part_2.9_recreate.png)

    - 6. Последовательное обновление (rolling)
    ```
    echo "=== ROLLING START ===" && date
    kubectl set image deployment/booking-service booking-service=nieshays/booking-service:do10
    kubectl rollout status deployment/booking-service
    echo "=== ROLLING END ===" && date
    ```

    ![rolling](./Screenshots/Part_2.9_rolling.png)

    - 7. Я просто для проверки решил проверить dashboard с этим подом, что образ изменился.

    ![status booking-service](./Screenshots/Part_2.9_status_booking-service.png)

    - Ну и до кучи успешно пройденные тесты

    ![tests postman](./Screenshots/Part_2.9_tests_postman.png)   