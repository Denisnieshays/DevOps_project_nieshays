## Part 1. Развертывание приложения с помощью Kustomize

### Задание

1. Получить набор виртуальных машин с развернутым кластером.
    - В этом пункте я использовал **Vagrantfile**, чтобы далее работать с кластером виртуальных машин

    ![vagrantfile](./Screenshots/Part_1.1_vagrantfile.png)

    - Установил **k3s** сначала на мастер, чтобы получить токен для подключения воркеров к мастеру
    - А потом подключил при помощи токера воркеры к мастеру

    ![cluster running](./Screenshots/Part_1.1_running_cluster.png)

2. Перенести манифесты из предыдущих блоков.
    - Командой **ssh -r ".\src\services\" nieshays@192.168.0.101:/home/nieshays/DO12** я перенёс манифесты с локального хоста на виурутальную машину. Предварительно находившись в директории проекта **DO11**
    - После проверил на мастере, что в папке **services** скопировались маниместы из предыдущего проекта

    ![copy manifests](./Screenshots/Part_1.2_copy_manifests.png)

3. Установить *kustomize* на локальной машине.
    - Установку **kustomize** я решил произвести на мастере, так как это управляющия нода, от которой воркеры подтянут измения **curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash**

    ![install kustomize](./Screenshots/Part_1.3_install_kustomize.png)

4. Cоздать скелет проекта развертывания с одной базовой конфигурацией (base) и одной оверлейной конфигурацией (production):

```
├── base
│   ├── deployment.yaml
│   ├── kustomization.yaml
│   ├── service.yaml
│   └── ...
├── overlays
│   └── production
│       ├── kustomization.yaml
│       ├── configMap.yaml
│       ├── secret.yaml
│       └── ...
├── kustomization.yaml
└── ...
```
    
![conf](./Screenshots/Part_1.4_structure.png)

5. Написать базовые и оверлейные конфигурации для kustomize. В базовых указать сервисы и развертывания, в production добавить конкретные секреты и конфигурационные значения.
    - В базовых конфигурациях я указал файлы сервисов из предыдущего проекта. Я не стал отделять сервисы от развертывания, потому как для **kustomize** варианты как разделения, так и оставления конфигураций не на что не влияет.

    ![structure configuration](./Screenshots/Part_1.5_structure_configuration.png)

6. Создать `replicas-patch.yaml` для оверлей production, который модифицирует количество реплик для деплоймента gateway service до 3 реплик.
    - В этом пункте был написан файл для **gateway-service**, который создает 3 реплики этого сервиса
    - То, что файл создает 3 реплики сервиса можноо увидеть в **8-ом пункте**

    ![replicas file](./Screenshots/Part_1.6_replicas_file.png)

7. Собрать результирующий конфигурационный файл, учитывая оверлей `production`.
    - Для сборки конфигурационного файла я использовал команду **kustomize build overlays/production/ > production-deploy.yaml**. Эта команда ищет все файлы с именем **kustomization.yaml** и берёт данные из этих файлов. После берутся все манифесты для работы приложения, в том числе из директории **base** и сохраняются в файл с именем **production-deploy.yaml** 

    ![production deploy](./Screenshots/Part_1.7_production-deploy.png)

    ```
    Важно: имена файлов должны совпадать с именами указанными в kustomization.yaml. Kustomize чувствителен к регистру букв!
    ```

8. Запустить функциональные тесты Postman и удостовериться в работоспособности приложения.
    - После того, как собрали результирующий файл, можно его запустить командой **kubectl apply -f production-deploy.yaml**. В этот раз не нужно каждый манифест запускать отдельно и по очереди. Достаточно запустить файл **production-deploy.yaml** и сервисы с подами создадуться из этого файла.

    ![running services 1](./Screenshots/Part_1.8_running_services_1.png)

    ![running services 2](./Screenshots/Part_1.8_running_services_2.png)

    - Успешно пройденные тесты **Postman**

    ![tests postman](./Screenshots/Part_1.8_tests_postman.png)

## Part 2. Развертывание приложения с помощью Helm

### Задание 

1. Получить набор виртуальных машин с развернутым кластером.

2. Перенести манифесты из предыдущих блоков.

3. Установить *helm* на локальной машине и удостовериться, что этот инструмент имеет валидное подключение к полученному удаленному кластеру Kubernetes.
    - Командой **curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash** я установил **helm** на мастер и проверил версию

    ![install helm and version](./Screenshots/Part_2.3_install_helm_and_version.png)
    
    - Далее создал директорию **mkdir -p /home/vagrant/.kube**, в котором находится конфиг подключения к кластеру, но пока пуст
    - Скопировал конфиг из **k3s** командой **sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config**
    - Поменял владельца **sudo chown vagrant:vagrant /home/vagrant/.kube/config**, чтобы иметь доступ к конфигу без **sudo** и можно было прочитать этот файл
    - И наконец командой **sed -i 's/127.0.0.1/192.168.56.10/g' /home/vagrant/.kube/config** поменял ip-адрес в конфиге на адрес мастера **192.168.56.10**, иначе вылезала ошибка, что **helm** не может подключиться к кластеру
    - После того, как поменял адрес проверил, что подключиться к кластеру удалось командой **helm ls**

    ![connection helm](./Screenshots/Part_2.3_install_and_connection_helm.png)

4. Создать *helm*-чарты и шаблоны для своего приложения с помощью команды `helm create`. Эта команда создаст базовую структуру чарта с шаблонами для ресурсов: deployment, service и ingress.
    - Чтобы создать базовую структуру чарта я использовал команду **helm create hotel-chart**

    ![create hotel-chart](./Screenshots/Part_2.4_create_hotel-chart.png)

    - После посмотрел созданную структуру:

    ![struct hotel-chart](./Screenshots/Part_2.4_struct_chart.png)

5. Отредактировать файл `values.yaml` на диаграмме, чтобы указать параметры конфигурации для твоего приложения, необходимые для создания манифестов Kubernetes для указанных развертываний (deployments). Описать объекты развертывания и сервисов в директории шаблонов (templates).
    - В этом пункте были отредактированы файлы **values.yaml**, **tempates/deployments.yaml**, **tempates/configmap.yaml**, **tempates/secrets.yaml**
    - В файлах **tempates/deployments.yaml**, **tempates/configmap.yaml**, **tempates/secrets.yaml** были указаны значения, которые повторяются в манифестах
    - А в файле **values.yaml** указываются уникальные значения. Например: **образ, кол-во реплик, имя сервиса, порт**.

    - Содержание **deployment**:

    ![deployment](./Screenshots/Part_2.5_deployment.png)

    - Содержание **values** (небольшой пример):

    ![values 1](./Screenshots/Part_2.5_values_1.png)

    ![values 2](./Screenshots/Part_2.5_values_2.png)

    - Пробная генерация манифестов, что всё собирается без ошибок:

    ![test](./Screenshots/Part_2.5_helm_test.png)

6. Упаковать *helm*-чарт с помощью команды `helm package` для создания файла `*.tgz`, содержащего чарт и его зависимости.
    - Командой **helm package hotel-chart/** создается **hotel-chart-1.0.0.tgz**
    - При выполнении этой команды учитываются все файлы на ходящиеся в директории **hotel-chart**, за исключением **.helmignore**

    ![helm package](./Screenshots/Part_2.6_helm_package.png)

7. Развернуть *helm*-чарт в кластере Kubernetes с помощью команды `helm install`. Указать произвольный `namespace` и `release-name`.
    - Для запуска **helm-чарта** я использовал команду **helm install hotel-release hotel-chart/ --namespace production-helm**

    ![helm install chart](./Screenshots/Part_2.7_helm_install.png)

8. Проверить статус развернутого приложения при помощи команды `kubectl get`. Результаты представить в отчете.
    - После запуска чарта необходимо проверить статус запущенных подов. Я проверял командой **kubectl get pods -n production-helm**

    ![get pods](./Screenshots/Part_2.8_get_pods.png)

    - Как видно на скриншоте выше, несколько раз перезагружается один из сервисов.
    - Чтобы понять в чем дело и почему он перезагружается я начал читать логи с ошибками, которые явно говорили в чем дело
    - Оишбка говорит о том, что в файле **values.yaml** в секции **report** не хватает переменной, которую нужно добавить

9. Внести как минимум одно изменение в `values.yaml` и выполнить команду `helm upgrade`. 
    - Далее я нашел этот фрагмент файла:

    ![report v1](./Screenshots/Part_2.9_file_v1.png)

    - И добавил нужную переменную:

    ![report v2](./Screenshots/Part_2.9_file_v2.png)

    - После внесения изменений в файл я выполнил обновление кластера командой **helm upgrade hotel-release hotel-chart/ --namespace production-helm**

    ![helm upgrade](./Screenshots/Part_2.9_helm_upgrade.png)

    - Далее проверка, что все поды работают без перезугрузки и критических ошибок:

    ![get pods upgrade](./Screenshots/Part_2.9_get_pods.png)

10. Запустить функциональные тесты Postman и удостовериться в работоспособности приложения.
    - Успешно пройденные тесты **postman**

    ![tests postman](./Screenshots/Part_2.10_tests_postman.png)
