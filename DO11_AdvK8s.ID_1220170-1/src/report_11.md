
## Part 1. Развертывание собственного кластера k3s

### Задание

1. Получить набор виртуальных машин для кластера.
    - Для выполнения этого проекта я написал простой **Vagrantfile** с 3-мя виртуальными машинами, где в дальнейшем будет установлен **k3s**

    ![vagrantfile](./Screenshots/Part_1.1_Vagrantfile.png)

2. Установить k3s на всех трех машинах. При установке не использовать стандартный Ingress Controller при помощи флага `--disable=traefik`.
    - В начале нужно установить **k3s** на **master** командой **curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.10 --node-external-ip=192.168.56.10 --flannel-backend=wireguard-native --flannel-external-ip --disable=traefik" sh -**
    - Аналогично для воркеров, только с правильными ip-адресами

    ![install k3s mastes](./Screenshots/Part_1.2_install_k3s_master.png)

3. Выполнить подключение узлов к кластеру, используя команду `k3s server` и флаги `--token` и `--server` для рабочих узлов и мастера соответственно. Когда k3s установлен, можно использовать переменную окружения `NODE_TOKEN`.
    - После установки и проверки статуса нужно получить токен для воркеров, чтобы подключить их к кластеру **sudo cat /var/lib/rancher/k3s/server/node-token**

    ![get token](./Screenshots/Part_1.3_get_token.png)

    - После на каждом воркере выполнить команду **curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --node-ip=<адрес воркера> --node-external-ip=<адрес воркера>" K3S_URL=https://192.168.56.10:6443 K3S_TOKEN=<указывается токен из мастера> sh -**
    - Также на каждом воркере проверяем статус подключения к кластеру. Должно быть тоже **Running** ```sudo systemctl status k3s-agent```

    ![worker status](./Screenshots/Part_1.3_worker_status.png)

    - После возвращаемся на **master** и командой **sudo kubectl get nodes -o wide** проверяем кластер. В нем должны находится 3 нода и быть в статусе **Ready**

    ![status nodes](./Screenshots/Part_1.3_get_nodes.png)

4. Установить Ingress Controller Nginx вместо стандартного. Ты можешь использовать официальный файл манифеста Ingress контроллера на базе Nginx, доступный на GitHub.
    - Далее командой **sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.15.1/deploy/static/provider/baremetal/deploy.yaml** Скачивается и устанавливается **Ingress Controller Nginx**

    ![install ingress](./Screenshots/Part_1.4_install_ingress.png)

    - Проверка командой **sudo kubectl get pods --namespace=ingress-nginx**, что контроллер успешно запущен и работает

    ![status controller](./Screenshots/Part_1.4_status_controlles.png)

5. Получить доменное имя и сконфигурировать внутри кластера утилиту `cert-manager`, которая должна генерировать wildcard-сертификат для полученного домена.
    - Для выполнения этого пункта сначала была выполнена установка утилиты **cert-manager** командой **kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.3/cert-manager.yaml**

    ![install cert-manager](./Screenshots/Part_1.5_install_cetr-manager.png)

    - Дальше я проверил командой **kubectl get pods -n cert-manager**, что поды установились и работают

    ![get pods](./Screenshots/Part_1.5_get_pods.png)

    - После проверки были написаны файлы: **selfsigned-issuer.yaml, root-ca-certificate.yaml, rootca-issuer.yaml, wildcatd-cert.yaml**. Они нужны для получения самоподписанного сертификата и получения домена.
    - Во время применения **selfsigned-issuer.yaml** возникла ошибка связанная с вебхуком. Помогла перезагрузка путем удаления **sudo kubectl delete pod -n cert-manager -l app.kubernetes.io/instance=cert-manager,app.kubernetes.io/name=webhook**    
    
    ```selfsigned-issuer.yaml:```

    ![selfsigned](./Screenshots/Part_1.5_selfsigned.png)

    ```root-ca-certificate.yaml```

    ![root certificate](./Screenshots/Part_1.5_root_certificate.png)

    ```rootca-issuer.yaml```

    ![root issuer](./Screenshots/Part_1.5_root_issuer.png)

    ```wildcard-cert.yaml:```

    ![wildcart-cert](./Screenshots/Part_1.5_wildcatd.png)

    - После создания я так же по очереди применил изменения командой **kubectl apply -f selfsigned-issuer.yaml**. Аналогично для Остальных файлов.
    - Проверка, что сертификат создан и работает:

    ![get certificate](./Screenshots/Part_1.5_get_certificate.png)

6. Создать ресурс Ingress для своего личного домена и настроить его для использования контроллера nginx ingress и полученного сертификата.
    - В этом пункте задачи был написан файл **ingress.yaml**. В некотором роде это "дверь" в созданный кластер. Когда кто-то заходит по домену, то перенаправляется к **gateway-service**. Без этого файла пришлось бы вручную прокидывать порты к каждому сервису.

    ![ingress](./Screenshots/Part_1.6_ingress.png)

    - На этом моменте у меня тоже возникли проблемы при запуске **ingress** с вебхуком, но в этот раз перезагрузка не помогла. Тогда пришлось удалить его вовсе **sudo kubectl delete validatingwebhookconfiguration ingress-nginx-admission**
    - После отключения вебхука я снова попробовал применить файл **kubectl apply -f ingress.yaml**. На этот раз получилось запустить.

    ![ingress running](./Screenshots/Part_1.6_ingress_running.png)

7. Создать PV (Persistent Volume) для базы данных PostgreSQL в манифесте из десятого проекта.
    - В манифесте **postgres.yaml** я добавил фрагменты, которые отвечают за сохранность базы данных на случай каких-либо сбоев или перезагрузки сервиса
    
    ![pv and pvc 1](./Screenshots/Part_1.7_pv_&_pvc_1.png)

    ![pv and pvc 2](./Screenshots/Part_1.7_pv_&_pvc_2.png)

    - Вообще для проверки мне пришлось запустить приложение из пункта 8. Но достаточно было только первые 3 пункта. После запуска **postgres.yaml** я убедился, что **pv* работает

    ![pv status](./Screenshots/Part_1.7_postgres_pvc.png)

8. Запустить приложение, описанное в манифесте.
    - На этом этапе возникли трудности с запуском приложения. При запуске приложения и распределения подов на разные ноды, сервисы не видели друг друга, не смотря на то, что ноды находятся в одном кластере. Очень долго искал, где допустил ошибку. В итоге во втором пункте при установке **k3s** на мастер я добавил 2 флага **--flannel-backend=wireguard-native --flannel-external-ip**. После чего перезапустил приложение. 

    ![application running](./Screenshots/Part_1.8_app_running.png)

9. Запустить функциональные тесты Postman и удостовериться в работоспособности приложения.
    - Для запуска тестов нужно открыть 2 окна командной строки и в каждой пробросить порт к виртуальной машине. **ssh -L 8087:localhost:8087 nieshays@192.168.0.101** в одном окне, а **ssh -L 8081:localhost:8081 nieshays@192.168.0.101** в другом. И каждой командой заходим в вм, где после заходим на мастер и нужно так же пробросить порты к сервисам 

    ```
    sudo kubectl port-forward --address 0.0.0.0 svc/gateway-service 8087:8087 &
    sudo kubectl port-forward --address 0.0.0.0 svc/session-service 8081:8081 &
    ```

    - После подключения можно зайти в **Postman** и настроить его. Так как в первой команде проброса указано **localhost**, то и в тестах нужно указывать тоже самое.
    - Если какой-то из сервисов выдаёт ошибку, то можно попробовать его перезагрузить **kubectl rollout restart deployment/gateway-service**. 
    - Если какой-то из тестов не запускается, то проверить на мастере не отключилось ли соединение. Если отключилось, то выполнить подключение заново.

    ![postman](./Screenshots/Part_1.9_postman.png)

10. Установить и запустить Prometheus Operator для сбора метрик в системе. Продемонстрировать в отчете результат выполнения команды `kubectl get pods -n monitoring`.
    - Для установки **Prometheus Operator** я скачал репозиторий с манифестами и поместил во временную папку **git clone https://github.com/prometheus-operator/kube-prometheus.git /tmp/kube-prometheus**
    - После применяем файлы настройки **kubectl create -f /tmp/kube-prometheus/manifests/setup/**
    - А уже потом всё остальное **kubectl create -f /tmp/kube-prometheus/manifests/**

    ![monitoring running](./Screenshots/Part_1.10_service_monitoring.png)

    - И через браузер проверил, что работает:

    ![prometheus in browser](./Screenshots/Part_1.10_prometheus_in_browser.png)