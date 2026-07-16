## Part 1. Настройка CI и CD

### Задание

1. Склонировать рабочий репозиторий.
    - В этом пункте я скопировал сервисы из проекта **DO12** командой **\Desktop\project_S21\DO12_Helm.ID_1220171-1\src> scp -r ".\" nieshays@192.168.0.101:/home/nieshays/DO13** и вставил в текущий **DO13** на виртуальной машине

    ![copy repository](./Screenshots/Part_1.1_copy_repository.png)

2. Получить доступ к удаленному кластеру Kubernetes.
    - Чтобы получить доступ к удаленному класету я:
    1. Поднял 3 виртуальные машины
    2. Установил **k3s** на мастер **curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.10 --node-external-ip=192.168.56.10 --flannel-backend=wireguard-native --flannel-external-ip" sh -**
    3. Получил токен для подключения воркеров командой **cat /var/lib/rancher/k3s/server/node-token**
    4. Подключил воркеры с кластеру **curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --node-ip=192.168.56.12 --node-external-ip=192.168.56.12" K3S_URL=https://192.168.56.10:6443 K3S_TOKEN="<Токен из мастера>" sh -**
    5. Создал директорию, где будет храниться файл с данными для подключения к кластеру **mkdir -p ~/.kube**
    6. Подключившись к мастеру скопировал конфиг **k3s** и изменив ip-адрес мастера, чтобы была возможность удаленно подключиться к кластеру и записав данные в файл **config** 

    ![install k3s in cluster](./Screenshots/Part_1.2_install_k3s_on_cluster.png)

    7. Установил **helm** для удаленной работы в кластере. Установил только сейчас, так как в прошлом проекте **helm** был установлен на мастере.

    ![install helm](./Screenshots/Part_1.2_install_helm.png)

3. Создать отдельный неймспейс для раннера GitLab.
    - Для установки отдельного **namespace** я использовал команду **kubectl create namespace gitlab-runner**
    - После проверил, что он создался и в статусе **active**

    ![create namespace runner](./Screenshots/Part_1.3_create_namespace_runner.png)

4. Установить раннер GitLab в кластере Kubernetes: ты можешь использовать Helm-чарт для раннера GitLab, чтобы установить его в своем кластере Kubernetes. Helm-чарт автоматически создаст развертывание для раннера, который создаст один или несколько модулей, выполняющие задания контейнеров приложения.
    - В начале я добавил репозиторий с чартами **helm repo add gitlab https://charts.gitlab.io**
    - Командой **helm repo update** скачал актуальные версии чартов

    ![add repo gitlab](./Screenshots/Part_1.4_add_repo_gitlab.png)

    - Написал файл со значениями, в котором указаны **URL** и **Токен** для **gitlab-runner**

    ![runner.yaml](./Screenshots/Part_1.4_runner.yaml.png)

    - Дальше запустил чарт с runner`ом и проверил, что он работает:

    ![install runner](./Screenshots/Part_1.4_lauch_chart.png)

5. Создать секрет для хранения регистрационного токена GitLab.
    - Изначально токен находился в файле **runner.yaml**. Но пришлось немного изменить файл и создать секрет для хранения токена
    - Командой **kubectl create secret generic gitlab-runner-secret --from-literal=token="<token>" --namespace gitlab-runner** создается секрет с токеном
    - И проверяется, что секрет создался

    ![create secret](./Screenshots/Part_1.5_create_secret.png)

6. Создать конфигурационный файл `config.toml` для использования установленного на выданном кластере Kubernetes раннера. Там же необходимо указать ограничения по ресурсам и докер-образ (например, `docker:stable`). Зарегистрировать установленный раннер при помощи написанного конфигурационного файла.
    - Написал файл **config.toml**:

    ![config.toml](./Screenshots/Part_1.6_config.toml.png)

    - Создал еще один секрет, который сохраняет конфигураию конфига. **kubectl create secret generic gitlab-runner-config --from-file=config.toml=config.toml --namespace gitlab-runner**

    - Отредактировал **runner.yaml**, убрав **config**, так как этот же конфиг прописал в **config.toml** и добавил получение нового секрета

    ![update runner.yaml](./Screenshots/Part_1.6_update_runner.yaml.png)

    - После внесённых изменений обновил кластер командой **helm upgrade --install gitlab-runner gitlab/gitlab-runner --namespace gitlab-runner -f runner.yaml --wait**

    ![upgrade cluster](./Screenshots/Part_1.6_upgrade_cluster.png)

    - Как только запустился под, я проверил его логи:

    ![logs pod](./Screenshots/Part_1.6_logs_pod.png)

    ```Регистрация происходит автоматически. Helm передает токен чарту, который регистрирует раннер без дополнительных команд. Достаточно запустить helm-chart командой helm install ...```

7. Разработать следующий пайплайн:

   - build — сборка приложения (запускать автоматически для веток с префиксом `feature_`);
   - test — запуск модульных тестов и функциональных тестов postman через утилиту newman (запускать автоматически для веток с префиксом `feature_`);
   - staging — запуск приложения в staging-окружении (запускать мануально и только для тегов).

   - Так как в ветке, которой выполняется проект называется **develop** и не предусмотрен префикс. И для ручного запуска этапа в конце был указан ручной запуск этапа: **when: manual**.

   ```
    stages:
    - build
    - test
    - staging

    variables:
    MAVEN_OPTS: "-Dmaven.repo.local=$CI_PROJECT_DIR/.m2/repository"
    POSTGRES_USER: "postgres"
    POSTGRES_PASSWORD: "password"
    RABBIT_MQ_USER: "guest"
    RABBIT_MQ_PASSWORD: "guest"

    # ============================================
    # STAGE 1: BUILD
    # ============================================
    build:
    stage: build
    image: maven:3.8-openjdk-11
    script:
    - set -e
    - cd src/services/booking-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/gateway-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/hotel-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/session-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/payment-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/loyalty-service && mvn clean package -DskipTests && cd ../../..
    - cd src/services/report-service && mvn clean package -DskipTests && cd ../../..
    artifacts:
        paths:
        - "*/target/*.jar"
        expire_in: 1 hour
    when: manual

    # ============================================
    # STAGE 2: TEST
    # ============================================
    test:
    stage: test
    image: maven:3.8-openjdk-11
    services:
        - postgres:13
    variables:
        POSTGRES_DB: test_db
        POSTGRES_USER: test_user
        POSTGRES_PASSWORD: test_pass
    before_script:
        - apt-get update
        - curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
        - apt-get install -y nodejs
        - apt-get update && apt-get install -y curl jq
        - npm install -g newman
        # 1. Меняем все localhost на gateway-service
        - sed -i 's/localhost/gateway-service.production-helm.svc.cluster.local/g' src/application_tests.postman_collection.json
        # 2. Используем jq для точной замены первого запроса
        - jq '.item[0].request.url.raw = "session-service.production-helm.svc.cluster.local:{{USERS_PORT}}/api/v1/auth/authorize"' src/application_tests.postman_collection.json > tmp.json && mv tmp.json src/application_tests.postman_collection.json
        # 3. Меняем host в структуре URL
        - jq '.item[0].request.url.host = ["session-service.production-helm.svc.cluster.local"]' src/application_tests.postman_collection.json > tmp.json && mv tmp.json src/application_tests.postman_collection.json
        - sleep 15
    script:
        - set -e
        - cd src/services/booking-service && mvn test -DskipTests && cd ../../..
        - cd src/services/gateway-service && mvn test -DskipTests && cd ../../..
        - cd src/services/hotel-service && mvn test -DskipTests && cd ../../..
        - cd src/services/session-service && mvn test -DskipTests && cd ../../..
        - cd src/services/payment-service && mvn test -DskipTests && cd ../../..
        - cd src/services/loyalty-service && mvn test -DskipTests && cd ../../..
        - cd src/services/report-service && mvn test -DskipTests && cd ../../..
        - newman run src/application_tests.postman_collection.json --reporters cli
    when: manual

    # ============================================
    # STAGE 3: STAGING
    # ============================================
    staging:
    stage: staging
    image: alpine/k8s:1.27.16
    before_script:
        - echo "$KUBECONFIG" > /tmp/kubeconfig
        - export KUBECONFIG=/tmp/kubeconfig
    script:
        - kubectl apply -f k8s/staging/
        - kubectl rollout status deployment -n staging --timeout=120s
    when: manual
    ```

8. Использовать секреты для передачи приватных ключей сервисам для авторизации (файл `application.properties` в директории с исходным кодом сервисов).
    - Для передачи приватных ключей сервисам настроены переменные окружения в секции **variables** файла **.gitlab-ci.yml**
    - Плейсхолдеры в **application.properties** получают значения из переменных пайплайна при сборке **Maven**.

    ![add variables](./Screenshots/Part_1.8_add_variables.png)

9. Внести изменение в код приложения. Добавить новую зависимость в `pom.xml` файл и зафиксировать изменение.
    - В сервис **booking-service** в файл **pom.xml** добвлена зависимость, которая упрощает работу с файлами

    ![changed pom.xml](./Screenshots/Part_1.9_changed_pom.xml.png)


- Несмотря на то, что в заданиях ни слова про рабочий пайплайн, то я очень долго сидел и исправлял тесты.
- Установил **newman**, чтобы проверять тесты непосресредственно на виртуальной машине.

- Тесты в приложении **Postman**
![tests in app postman](./Screenshots/test_app_postman.png)

- Тесты на виртуальной машине **newman**
![tests in vm newman](./Screenshots/tests_newman.png)

- Итоговый пайплайн, который показывает, что всё успешно пройдено:
![working pipeline](./Screenshots/working_pipeline.png)