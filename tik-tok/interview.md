# Список вопросов:

## Собеседование с аналогом Tik-Tok:

-----------------------

# Вопросы из записи в iCloud (Тех собес с аналогом TikTok):

# ОПЫТ:

## 1. Чем занимался на последнем месте работы? Какие проекты были? Что хочешь выделать? (ОПЫТ)
sber/devices/interview.md - 1. Расскажие о себе (2 года). Задачи, которыми занимался сам, но не команда. (ОПЫТ)

Смарт-трейд. Лид автоматизации и джун devops. 
Задачи: 
  1. подготовка CI/CD, 
  2. написание Dockerfile, docker-compose.yml.
  3. конфигурация раннеров
  4. развитие инфраструктуры для прогона тестов (физ сервера Linux Ubuntu 20.04, 22.04. Сборка билдов, запуск тестов в docker в VNC).
Инструменты: 
  1. Gitlab + gitlab runner + gitlab ci
  2. Docker
  3. Selenoid, selenoid-ui, ggr, ggr-ui
  4. Allure-server

МТС-Банк. middle-Devops.
Задачи:
  1. мониторинг бд, серверов, приложений, docker контейнеров и k8s кластера
  2. адмнистрирование linux серверов и ios 
  3. развитие инфраструктуры для прогона тестов, работы приложений и бд
  4. развитие аппиум фермы
  5. деплои в k8s кластер и конфигурация helm chart'ов (ingress, pods, services, rs, deployment)
  6. написание пайплайнов, баш скриптов, ansible-playbook

## 2. Как выглядит инфра для тестирования? Как выкатываются контейнеры? (При помощи Ansible?)

## 3. Сервера развёрнуты в Digital Ocean?

## 4. Digital Ocean за что берёт деньги за лицензии для k8s кластера?

Digital Ocean не берет дополнительной платы за лицензии для Kubernetes кластера. Они предоставляют управляемый сервис Kubernetes (Managed Kubernetes), который включает в себя все необходимые лицензии для работы с Kubernetes. Плата, которую вы платите за использование Kubernetes кластера на Digital Ocean, включает в себя стоимость ресурсов (виртуальных машин, хранилища и т.д.), а также услугу управления Kubernetes кластером.

В аккаунте на Digital Ocean в расходы входят лицензии для баз данных Oracle, PostgreSQL и FOT Admin DB. Это означает, что Digital Ocean предоставляет вам возможность использовать эти базы данных в своей инфраструктуре, и вам приходится оплачивать лицензионные расходы за их использование.

Digital Ocean может предоставлять управляемые базы данных, такие как Oracle, PostgreSQL и FOT Admin DB, как часть их сервисов. При использовании этих управляемых баз данных, может потребоваться оплачивать лицензионные расходы за использование соответствующих баз данных.

Таким образом, расходы за лицензии для баз данных в аккаунте на Digital Ocean означает, что используются управляемые базы данных от Digital Ocean, и нужно оплачивать лицензионные расходы за их использование.

## 5. Разворачивал ли в k8s PostgreSQL, Redis? (k8s)
https://habr.com/ru/companies/domclick/articles/649167/ - Разворачиваем PostgreSQL, Redis и RabbitMQ в Kubernetes-кластере

### Руководство по развертыванию базы данных в Kubernetes

1) **Создание Persistent Volume (PV) и Persistent Volume Claim (PVC):**

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

2) **Установка Helm-чарта целевого приложения:**

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install dev-pg bitnami/postgresql --set primary.persistence.existingClaim=pg-pvc,auth.postgresPassword=pgpass
```

3) **Проверка работы:**

```bash
$ kubectl get pvc
$ kubectl get pod,statefulset
```

4) **Перед началом работ нужно минимально настроить кластер Kubernetes.**
   - Версия Kubernetes 1.20+
   - Одна master-нода и одна worker-нода
   - Настроенный Ingress-controller
   - Установлен Helm

5) **Создание ресурса StorageClass и Применение манифеста:**

```yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

6) **Создание ресурса Persistent Volume:**
В matchExpressions указываем название ноды, на которой будет монтироваться диск. Посмотреть имя доступных узлов можно с помощью команды: `kubectl get nodes`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-for-pg
  labels:
    type: local
spec:
  capacity:
    storage: 4Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /devkube/postgresql
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - 457344.cloud4box.ru
```

7) **Для удобства монтируем диск на мастер-ноде:**

```bash
$ mkdir -p /devkube/postgresql
```

8) **Применение манифеста Persistent Volume:**

```bash
$ kubectl apply -f pv.yaml
```

9) **Проверка состояния:**

```bash
$ kubectl get pv
```

10) **Применение манифеста Persistent Volume Claim:**

```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pg-pvc
spec:
  storageClassName: "local-storage"
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 4Gi
```

11) **Проверка состояния ресурса PVC:**
Ресурс PVC в ожидании привязки. 

```bash
$ kubectl get pvc
```

12) **Подтягиваем к себе репозиторий Bitnami и Устанавливаем Helm-чарт с Postgres:**

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami

$ helm install dev-pg bitnami/postgresql --set primary.persistence.existingClaim=pg-pvc,auth.postgresPassword=pgpass
```

13) **Проверка состояния PVC:**
теперь pod с Postgres будет писать данные в директорию /devkube/postgresql.

```bash
$ kubectl get pvc
```

14) **Проверка состояния Pod и StatefulSet:**

```bash
$ kubectl get pod,statefulset
```

### База успешно развёрнута, теперь попробуем подключиться к ней и создать пользователя, таблицу и настроить доступы. После установки чарта в консоли будут показаны некоторые способы подключения к БД. Есть два способа:

15.1) **Подключение к БД:**

   - Проброс порта на локальную машину:
     ```bash
     $ kubectl port-forward --namespace default svc/dev-pg-postgresql 5432:5432
     ```
   - Подключение к БД:
     ```bash
     $ psql --host 127.0.0.1 -U postgres -d postgres -p 5432
     ```

15.2) **Создание поды с psql клиентом:**

```bash
$ kubectl run dev-pg-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:14.2.0-debian-10-r22 --env="PGPASSWORD=$POSTGRES_PASSWORD" \
      --command -- psql --host dev-pg-postgresql -U postgres -d postgres -p 5432
```

16) **Создание роли и пароля для пользователя:**

```sql
CREATE ROLE qa_user WITH LOGIN ENCRYPTED PASSWORD 'qa-pg-pass';
```

17) **Создание базы данных с владельцем qa_user:**

```sql
CREATE DATABASE qa_db OWNER qa_user;
```

18) **Подключение к базе данных с новым пользователем:**

```bash
$ kubectl run dev-pg-postgresql-client --rm --tty -i --restart='Never' --namespace default --image docker.io/bitnami/postgresql:14.2.0-debian-10-r22 --env="PGPASSWORD=qa-pg-pass"  --command -- psql --host dev-pg-postgresql -U qa_user -d qa_db -p 5432
```

19) **База успешно развёрнута!**
    - Адрес БД для приложения: `DATABASE_URI=postgresql://qa_user:qa-pg-pass@dev-pg-postgresql:5432/qa_db`

Это руководство поможет вам успешно развернуть и настроить базу данных в Kubernetes.


## 6. Как разворачивал PostgreSQL без k8s? (БД)

Для развертывания PostgreSQL без Kubernetes, но с использованием Docker на сервере Ubuntu, вам потребуется следующий набор шагов:

1) **Установка Docker на сервер Ubuntu:**

```bash
$ sudo apt update
$ sudo apt install docker.io
$ sudo systemctl start docker
$ sudo systemctl enable docker
```

2) **Создание каталога для хранения данных PostgreSQL:**

```bash
$ mkdir -p /opt/postgresql/data
```

3) **Создание и настройка файла конфигурации PostgreSQL:**

```bash
$ touch /opt/postgresql/postgresql.conf
```

Пример содержимого `postgresql.conf`:

```plaintext
listen_addresses = 'localhost'
port = 5432
max_connections = 100
```

4) **Запуск контейнера PostgreSQL:**

```bash
$ sudo docker run -d --name postgresql-container -v /opt/postgresql/data:/var/lib/postgresql/data -v /opt/postgresql/postgresql.conf:/etc/postgresql/postgresql.conf -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 postgres
```

5) **Подключение к контейнеру PostgreSQL:**

```bash
$ sudo docker exec -it postgresql-container psql -U postgres
```

6) **Создание роли и базы данных:**

```sql
CREATE ROLE qa_user WITH LOGIN ENCRYPTED PASSWORD 'qa-pg-pass';
CREATE DATABASE qa_db OWNER qa_user;
```

7) **Подключение к базе данных с новым пользователем:**

```bash
$ sudo docker exec -it postgresql-container psql -U qa_user -d qa_db
```

8) **База данных PostgreSQL успешно развернута на сервере Ubuntu с использованием Docker!**

Эти шаги помогут вам развернуть PostgreSQL на сервере Ubuntu при помощи Docker.

## 7. Как разворачивал PostgreSQL без k8s и docker? (БД)



## 8. 



## 9. 




## Продолжить (Тех собес с аналогом TikTok) с 00:13:36