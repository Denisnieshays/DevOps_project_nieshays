## Part 1. Удаленное конфигурирование узла через Ansible

В этой главе тебе предстоит осуществить удаленную настройку узла для разворачивания мультисервисного приложения.

### Задание

1. Создать с помощью Vagrant три машины: manager, node01, node02. Не устанавливать с помощью shell-скриптов docker при создании машин на Vagrant! Прокинуть порты node01 на локальную машину для доступа к пока еще не развернутому микросервисному приложению.

- Написанный Vagrantfile на три машины без установки docker с помощью shell-скриптов. А также прокинутые порты на node01 для доступа к микросервисному приложению.

![vagrantfile](./Screenshots/Part_1_vagrantfile.png)

2. Подготовить manager как рабочую станцию для удаленного конфигурирования (помощь по Ansible в материалах).
   - Зайти на manager. 
      - При помощи уже известной команды **vagrant ssh manager01** заходим в менеджер
   - На manager проверить подключение к node01 через ssh по приватной сети. 
      - После того, как зашли в менеджер через **ssh**, пробуем подключиться к **node01**. Так как ssh-ключ еще не сгенирирован, то он выдаст ошибку

      ![ssh node01](./Screenshots/Part_1_ssh_node01.png)
       
   - Сгенерировать ssh-ключ для подключения к node01 из manager (без passphrase). 
      1. Сгенерировать ssh-ключ можно при помощи команды **ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa -N ""**. Заранее я посмотрел, что в директории **.ssh** нету ранее созданных ssh-ключей.

      ![ssh-keygen](./Screenshots/Part_1_ssh-keygen.png)

      2. После я убедился, что ключи создались командой **ls -la .ssh**

      ![keys in .ssh](./Screenshots/Part_1_keys_in_ssh.png)

      3. Следующим шагом я вышел из менеджера и зашел в **node01** командой **vagrant ssh node01**.
      4. В node01 я поправил файл **/etc/ssh/sshd_config**. В нём я раскомментировал строки **PasswordAuthentication yes** и **PubkeyAuthentication yes**
      5. Самое важное в этом файле временно исправить **KbdInteractiveAuthentication no** на **KbdInteractiveAuthentication yes** пока копируется ключ. **Перезагрузить sshd**. Если этот флажок не поменять, то создастся конфликт между этим флагом и **UsePAM**. Как только скопировался ключ на ноды, то нужно обратно поставить **KbdInteractiveAuthentication no** для безопасности. Это метод аутентификации в SSH, при котором сервер может задать пользователю один или несколько вопросов.
      6. При помощи команды **ssh-copy-id -i .ssh/id_rsa.pub vagrant@ip-адрес машины**, копируем ключ на **node01**

      ![copy keys to the node](./Screenshots/Part_1_copy_keys_to_the_node.png)
      
      7. После копирования публичного ssh-ключа, можно зайти в node01 **ssh vagrant@ip-адрес машины**. Либо проверить имя нода:

      ![checking the node](./Screenshots/Part_1_checking_the_node.png)

   - Скопировать на manager docker-compose файл и исходный код микросервисов. (Используй проект из папки src и docker-compose файл из предыдущей главы. Помощь по ssh в материалах.)
      - Чтобы скопировать файлы из предыдущего проекта, я использовал командную строку на локальном хосте и команду **scp**, чтобы скопировать файлы на виртуальную машину. Использовал полный путь к предыдущему проекту, а в качестве принимающей стороны - основную виртуальную маишны **ws-11**. Так как в **Vagrantfile** у меня настоена синхронизация текущей директории, то все изменения и все файлы которые я перенесу на основную вм, будут обображаться также на менеджере

      ![copy files to the vb](./Screenshots/Part_1_copy_files_services.png)

      ![content directory](./Screenshots/Part_1_content_directory.png)

   - Установить Ansible на менеджер и создать папку ansible, в которой создать inventory-файл. 
      1. Командой **sudo apt install -y ansible** устанавливается инструмент **Ansible** на менеджер.
         - Чтобы установить **Ansible** до последней актуальной версии, нужно:
            1. Обновить список пакетов ```sudo apt update```
            2. Установить зависимости ```sudo apt install software-properties-common -y```
            3. Добавить официальный репозиторий **Ansible** ```sudo add-apt-repository ppa:ansible/ansible```
            4. Установить **Ansible** ```sudo apt install ansible -y```
            
      Проверка версии **Ansible**:

      ![install ansible](./Screenshots/Part_1_install_ansible.png)

      2. Создается простой **inventory-файл**

      ![inventory file](./Screenshots/Part_1_inventory-file.png)

   - Использовать модуль ping для проверки подключения через Ansible. 
      - Для проверки нужно использовать команду ```ansible all -i inventory -m ping```. Команда запускается на всех машинах без исключения.
   - Результат выполнения модуля поместить в отчет.

   ![inventory ping](./Screenshots/Part_1_inventory_ping.png)

3. Написать первый плейбук для Ansible, который выполняет apt update, устанавливает docker, docker-compose, копирует compose-файл из manager'а и разворачивает микросервисное приложение. 

   ![apt update](./Screenshots/Part_1_apt_update.png)

   ![install docker](./Screenshots/Part_1_install_Docker.png)

   ![install docker compose](./Screenshots/Part_1_install_Docker_Compose.png)

   ![copy files to node01](./Screenshots/Part_1_copy_files.png)

   ![launch the application](./Screenshots/Part_1_launch_the_application.png)

   - Запуск плейбука осуществляется командой **ansible-playbook -i inventory playbook_01_docker.yml**. Обязательно  указывается файл инвентаря, чтобы плейбук знал, откуда брать информацию о машине указанной в плейбуке.

   ![launch palybook_01_docker](./Screenshots/Part_1_lauch_playbook_01_docker.png)

   ```Очень важно добавить пользователя в группу docker, иначе будет ошибка доступа, а именно node01```

   - После, если никаких ошибок нету, то через команду **ansible node01 -i inventory -m shell -a "cd /opt/app && docker compose ps -a"** видим все сервивисы, как запущенные, так и "упавшие". За сервисами лучше проследить какое-то время потому, что первые минуты они могут работать, а после остановиться. Я выбрал время наблюдения за сервисами более 10 минут. Если более 10 минут работают, значит с ними все в порядке и можно переходить к следующему пункту задания.
   - Скорее всего во время первого запуска при попытке проверить через **docker compose ps -a** все работающие сервисы, вылезет ошибка, что для демона докера нет доступа. Это означает, что пользователя **node01** нужно добавить в группу **docker**.

   ![up application](./Screenshots/Part_1_up_application.png)

4. Прогнать заготовленные тесты через postman и удостовериться, что все они проходят успешно. В отчете отобразить результаты тестирования.
   - Прогнал тесты несколько раз, чтобы убедиться, что сервисы действительно работают и не падают

   ![postman tests](./Screenshots/Part_1_Postman_tests.png)

5. Сформировать три роли: 
   - роль application выполняет развертывание микросервисного приложения при помощи docker-compose;

   ![role application](./Screenshots/Part_1_role_application.png)

   - apache устанавливает и запускает стандартный apache сервер;

   ![role apache](./Screenshots/Part_1_role_apache.png)

   - postgres устанавливает и запускает postgres, создает базу данных с произвольной таблицей и добавляет в нее три произвольные записи. 

   ![role postgres](./Screenshots/Part_1_role_postgres.png)

   - Назначить первую роль node01 и вторые две роли node02, проверить postman-тестами работоспособность микросервисного приложения, удостовериться в доступности postgres и apache-сервера. Для Apache веб-страница должна открыться в браузере. Что касается PostgreSQL, необходимо подключиться с локальной машины и отобразить содержимое ранее созданной таблицы с данными.
      1. Распределение ролей по нодам

      ![distribution of roles](./Screenshots/Part_1_distribution_of_roles.png)

      2. Тесты постман прошли успешно

      ![tests postman](./Screenshots/Part_1.5_postman_tests.png)

      3. Проверка **postgres**. А чтобы вывести нужную таблицу, то нужно ввести команду в **manager01** - **ansible node02 -i inventory -m shell -a "sudo -u postgres psql -d testdb -c 'SELECT * FROM users;'"**.
         - Если не работает, то первым делом нужно проверить создалась ли таблица **testdb** командой **ansible node02 -i inventory -m shell -a "sudo -u postgres psql -d testdb -c '\d'"**. Обязательно в имени должно стоять **users**. Если эта база данных не созданна, то нужно создать её в ручную. Подсказку можно использовать из файла **postgres/tasks/main.yml** пункт 4. 

      ![postgres up](./Screenshots/Part_1.5_postgres_up.png)

      ![postgers db](./Screenshots/Part_1.5_test_db.png)

      4. Проверка **Apache**

      ![apache up](./Screenshots/Part_1.5_apache_up.png)

      После того, как убедились, что **Apache** работает, можно перейти в браузер и отобразить нужную нам страницу. Заранее на **node02** были проброшены порты, поэтому нужно в строке поиска вводить **http://ip-адрес-основной-вм:8080** (В примере ниже используется нестандартный ip-адрес, так как ноут подключил к роутеру на телефоне).

      ![apache in browser](./Screenshots/Part_1.5_apache_in_browser.png) 

6. Созданные в этом разделе файлы разместить в папке `src\ansible01` в личном репозитории.

## Part 2. Service Discovery

Теперь перейдем к обнаружению сервисов. В этой главе тебе предстоит сымитировать два удаленных сервиса — api и БД, и осуществить между ними подключение через Service Discovery с использованием Consul.

### Задание

1. Написать два конфигурационных файла для consul (информация по consul в материалах):
   - consul_server.hcl:
      - настроить агент как сервер;
      - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant;

   - Разница между этими 2-мя файлами лишь во флагах **server**. Для конфигурационного файла **consul_server** устанавливается флаг **server = true** означающий, что агент будет использоваться как **сервер**

      ![consul server ](./Screenshots/Part_2_consul_server.hcl.png)

   - consul_client.hcl:
      - настроить агент как клиент;
      - указать в advertise_addr интерфейс, направленный во внутреннюю сеть Vagrant.
   - У **consul_client** наоборот устанавливается **server = false**, что означает агент будет использоваться как **клиент**
   
      ![consul client](./Screenshots/Part_2_consul_client.hcl.png)

2. Создать с помощью Vagrant четыре машины: consul_server, api, manager и db.
   - Прокинуть порт 8082 с api на локальную машину для доступа к пока еще не развернутому api.
   - Прокинуть порт 8500 с consul_server для доступа к ui consul. 

   ![vagrantfile](./Screenshots/Part_2_Vagrantfile.png)

3. Написать плейбук для ansible и четыре роли: 
   - install_consul_server, которая:
      - работает с consul_server;
      - копирует consul_server.hcl;
      - устанавливает consul и необходимые для consul зависимости;
      - запускает сервис consul;

      ![install_consul_server](./Screenshots/Part_2_consul_server.png)

   - install_consul_client, которая:
      - работает с api и db;
      - копирует consul_client.hcl;
      - устанавливает consul, envoy и необходимые для consul зависимости; 
      - запускает сервис consul и consul-envoy;

      ![install consul client](./Screenshots/Part_2_consul_client.png)
      
   - install_db, которая:
      - работает с db;
      - устанавливает postgres и запускает его;
      - создает базу данных `hotels_db`;

      ![install db](./Screenshots/Part_2_install_db.png)

   - install_hotels_service, которая:
      - работает с api;
      - копирует исходный код сервиса;
      - устанавливает `openjdk-8-jdk`;
      - создает глобальные переменные окружения:
         - POSTGRES_HOST="127.0.0.1";
         - POSTGRES_PORT="5432";
         - POSTGRES_DB="hotels_db";
         - POSTGRES_USER="<имя пользователя>";
         - POSTGRES_PASSWORD="<пароль пользователя>";
      - запускает собранный jar-файл командой `java -jar <путь до hotel-service>/hotel-service/target/<имя jar-файла>.jar`.

   ![install hotel service](./Screenshots/Part_2_install_hotel_service.png)

4. Проверить работоспособность CRUD-операций над сервисом отелей. В отчете отобразить результаты тестирования.
   - Для того, чтобы проверить работоспособность сервиса отелей, нужно:
      1. Запустить виртуальные машины командой **vagrant up**
      2. Я добавил ssh-ключи с менеджера на остальные 3 вм (**consul_server, api, db**). Также с **api** до **db**, чтобы **api** могла подключиться к базе данных на вм **db**
      3. Запустить **playbook**
      4. Установить postgres-client на **api**
      5. Проверить подключение с **api** к **db** командой **nc -zv 192.168.56.13 5432**. Вывод должен быть: **Connection successful**. (Иначе перейти к следующему пункту)
      6. Проверить занят ли порт **5432**. Если занят, то освободить нужно именно на **db**.
      7. Запустить контейнер на **db** командой:
      ``` sudo docker run -d   --name postgres-db   --network host   -e POSTGRES_USER=postgres   -e POSTGRES_PASSWORD=postgres   -e POSTGRES_DB=hotels_db   postgres:14-alpine```
      8. Только после этого запускается контейнер на **api** командой: ```sudo docker run -d   --name hotels-service   -p 8082:8082   -e SPRING_DATASOURCE_URL="jdbc:postgresql://192.168.56.13:5432/hotels_db"   -e SPRING_DATASOURCE_USERNAME="postgres"   -e SPRING_DATASOURCE_PASSWORD="postgres"   -e SPRING_JPA_DATABASE_PLATFORM="org.hibernate.dialect.PostgreSQLDialect"   -v /opt/hotel-service.jar:/app.jar   eclipse-temurin:8-jre-alpine   java -jar /app.jar```
      9. Командой **sudo docker ps -a** проверяем, что сервис на **api** запустился и не "упал". В идеале я жду минимум 5 минут. Если работает более 5 минут, то всё ок!
      10. В самом конце как только всё работает, то можно проверить и работоспособность CRUD-операций. 

- Для создания отеля используется команда: ```curl -X POST http://192.168.56.11:8082/hotels \
  -H "Content-Type: application/json" \
  -d '{
    "hotelUid": "'$(cat /proc/sys/kernel/random/uuid)'",
    "name": "Мой отель",
    "address": "Москва, Красная площадь",
    "rooms": 50,
    "cost": 3500.0
  }'```

   ![create hotel](./Screenshots/Part_2_create_hotel.png)

- Для вывода достаточно команды: **curl http://localhost:8082/hotels**

   ![read hotels 1](./Screenshots/Part_2_read_hotels_1.png)

   ![read hotels 2](./Screenshots/Part_2_read_hotels_2.png)

- Для обновления или изменения нужна команда, которая напрямую подключается к **db** и изменяет параметры **psql -h 192.168.56.13 -U postgres -d hotels_db -c "UPDATE hotels SET hotel_name='Nieshays' WHERE hotel_uid='9d05ba36-bf8d-11eb-8529-0242ac130003';"**. После вводится пароль и можно посмотреть, что необходимые поля исправлены. В данном примере имя отеля.

   ![update hotel](./Screenshots/Part_2_update_hotel.png)

- Для удаления вводится команда: **psql -h 192.168.56.13 -U postgres -d hotels_db -c "DELETE FROM hotels WHERE hotel_uid='9d05ba36-bf8d-11eb-8529-0242ac130003';"**. Обязательным является праивльное заполнение с **UUID**. Если указать неправильно, то выдаст ошибку.

   ![delete hotel](./Screenshots/Part_2_delete_hotel.png)

5. Созданные в этом разделе файлы разместить в папках `src\ansible02` и `src\consul01` в личном репозитории.