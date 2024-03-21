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

Для развертывания PostgreSQL без использования Kubernetes и Docker на сервере Ubuntu, вам потребуется установить PostgreSQL напрямую на сервер. Вот инструкция с шагами и командами:

1) **Установка PostgreSQL на сервер Ubuntu:**

```bash
$ sudo apt update
$ sudo apt install postgresql postgresql-contrib
```

2) **Настройка файла конфигурации PostgreSQL:**

```bash
$ sudo nano /etc/postgresql/<version>/main/postgresql.conf
```

Пример настроек в `postgresql.conf`:

```plaintext
listen_addresses = 'localhost'
port = 5432
max_connections = 100
```

3) **Настройка файлов pg_hba.conf для разрешения подключений:**

```bash
$ sudo nano /etc/postgresql/<version>/main/pg_hba.conf
```

Пример настройки в `pg_hba.conf`:

```plaintext
host    all             all             127.0.0.1/32            md5
```

4) **Перезапуск PostgreSQL для применения изменений:**

```bash
$ sudo systemctl restart postgresql
```

5) **Подключение к PostgreSQL и создание роли и базы данных:**

```bash
$ sudo -u postgres psql
```

```sql
CREATE ROLE qa_user WITH LOGIN ENCRYPTED PASSWORD 'qa-pg-pass';
CREATE DATABASE qa_db OWNER qa_user;
```

6) **Подключение к базе данных с новым пользователем:**

```bash
$ psql -U qa_user -d qa_db
```

7) **База данных PostgreSQL успешно развернута на сервере Ubuntu без использования Kubernetes и Docker!**

Эти шаги помогут вам установить и настроить PostgreSQL на сервере Ubuntu напрямую, без использования контейнеров или оркестраторов.

## 8. Что еще делал в k8s? Приведи примеры. (k8s)

В качестве Senior DevOps Engineer работал с Kubernetes, я выполнял следующие задачи и могу похвастаться следующими достижениями:

1) **Горизонтальное масштабирование приложения:**

- **Задача:** Настройка автоматического горизонтального масштабирования для приложения в Kubernetes.
- **Шаги:**
  - Создание горизонтального масштабирования для деплоя приложения:

```bash
$ kubectl autoscale deployment <deployment-name> --cpu-percent=70 --min=3 --max=10
```

- **Конфигурационный файл для автомасштабирования:**

```yaml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: <hpa-name>
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: <deployment-name>
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

2) **Управление секретами и конфигурациями:**

- **Задача:** Безопасное хранение и использование секретов и конфигураций в Kubernetes.
- **Шаги:**
  - Создание секрета для базы данных:

```bash
$ kubectl create secret generic db-credentials --from-literal=username=db_user --from-literal=password=db_password
```

- **Использование секрета в Pod:**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
    - name: mycontainer
      image: nginx
      env:
        - name: DB_USERNAME
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```

3) **Настройка мониторинга и логирования:**

- **Задача:** Настройка мониторинга и сбора логов для кластера Kubernetes.
- **Шаги:**
  - Установка Prometheus и Grafana для мониторинга:

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/grafana-prometheus.yaml
```

- **Настройка сбора логов с помощью Fluentd:**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kubernetes.*
      read_from_head true
      format json
    </source>

    <match kubernetes.**>
      @type elasticsearch
      host elasticsearch
      port 9200
      logstash_format true
      logstash_prefix kubernetes
      include_tag_key true
      tag_key @log_name
      flush_interval 5s
    </match>
```

Эти примеры сложных задач в Kubernetes для Senior DevOps Engineers позволяют продемонстрировать опыт работы с расширенными функциями и возможностями платформы.

## 9. Расскажи подробно работу деплоя в k8s кластер при помощи Арго и гитлаба. (k8s)

**Деплой в Kubernetes кластер при помощи Argo и GitLab:**

**Шаги для настройки:**

1. **Установка Argo CD:**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2. **Создание GitLab CI/CD pipeline:**

Создайте файл `.gitlab-ci.yml` в корне вашего репозитория `portal-ui`:

```yaml
stages:
  - deploy

deploy:
  stage: deploy
  image: argoproj/argocd-cli:v2.1.2
  script:
    - argocd login <argo-cd-server-url> --username admin --password <argo-cd-initial-password> --insecure
    - argocd app sync portal-ui --sync-option Prune=true
```

3. **Создание Argo CD приложения:**

Создайте файл `argo-application.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: portal-ui
spec:
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: default
  project: default
  source:
    repoURL: 'https://gitlab.com/your-repo/portal-ui'
    path: .
    targetRevision: HEAD
```

4. **Изменение настроек GitLab:**

Настройте переменные окружения в GitLab для хранения данных для доступа к Argo CD.

**Что делает Argo и пример деплоя в Kubernetes кластер без Argo:**

Argo - это инструмент для управления непрерывной поставкой и развертыванием приложений в Kubernetes. Он позволяет автоматизировать процессы CI/CD и управлять развертыванием приложений в кластере.

Пример деплоя в Kubernetes кластер без Argo:
- Ручное создание манифестов Kubernetes (Deployment, Service, Ingress и т. д.).
- Применение манифестов с помощью `kubectl apply -f`.

Отличия при использовании Argo:
- Автоматизация процесса деплоя приложений в Kubernetes.
- Возможность управления развертыванием приложений из Git-репозитория.
- Визуализация состояния и истории развертываний.
- Встроенные инструменты для управления версиями приложений.

Использование Argo упрощает и автоматизирует процесс развертывания приложений в Kubernetes, делая его более надежным и эффективным.

## 10. Где запускаются джобы lint/prettier? (k8s)

Для запуска джобов lint/prettier в Kubernetes с использованием GitLab Runner и выполнения проверок кода в контейнерах в Kubernetes, вам нужно настроить GitLab Runner в Kubernetes и определить задачи в `.gitlab-ci.yml` для запуска контейнеров с инструментами для проверки кода.

Вот пример шагов и команд для поднятия GitLab Runner в Kubernetes и выполнения джобов в контейнерах:

1. **Шаги:**

   - **Шаг 1: Установка GitLab Runner в Kubernetes:**
     - Установите GitLab Runner в Kubernetes с помощью Helm Chart или манифестов Kubernetes.
     - Настройте GitLab Runner для регистрации в вашем GitLab проекте.

   - **Шаг 2: Определение задач в `.gitlab-ci.yml`:**
     - В вашем `.gitlab-ci.yml` определите задачи для проверки кода, например, lint и prettier.
     - Для каждой задачи определите образ контейнера с необходимыми инструментами для проверки кода.

2. **Пример `.gitlab-ci.yml`:**

```yaml
lint:
  stage: test
  image: node:14
  script:
    - npm install eslint --save-dev
    - npm run lint

prettier:
  stage: test
  image: node:14
  script:
    - npm install prettier --save-dev
    - npm run prettier
```

3. **Пример команд для установки GitLab Runner в Kubernetes:**

```bash
# Добавление репозитория Helm Chart GitLab Runner
helm repo add gitlab https://charts.gitlab.io

# Установка GitLab Runner с помощью Helm Chart
helm install gitlab-runner gitlab/gitlab-runner -n gitlab --set gitlabUrl=<YOUR_GITLAB_URL> --set runnerRegistrationToken=<YOUR_RUNNER_TOKEN>
```

После установки GitLab Runner в Kubernetes и определения задач в `.gitlab-ci.yml`, GitLab Runner будет запускать контейнеры с инструментами lint и prettier для проверки кода в рамках CI/CD pipeline в Kubernetes кластере.

## 11. Может ли на сервере выполняться несколько джобов сразу? (k8s)

1) Да, на сервере может выполняться несколько джобов одновременно при одном поднятом GitLab Runner, если это настроено в конфигурации GitLab Runner. GitLab Runner может выполнять параллельно несколько джобов в зависимости от настроек concurrency в конфигурации GitLab Runner.

2) Утилизация контейнеров на сервере, где поднят GitLab Runner, зависит от настроек самого GitLab Runner и конфигурации джобов в `.gitlab-ci.yml`. Когда GitLab Runner выполняет джобы, он создает контейнеры для выполнения задач из определенных образов. После завершения выполнения джобы контейнеры могут быть остановлены или удалены в зависимости от настроек.

3) Отличия от запуска джобов на GitLab Runner, поднятом на сервере, и на GitLab Runner, поднятом в Kubernetes кластере, включают следующее:
   - **Масштабируемость:** В Kubernetes можно легко масштабировать количество GitLab Runner экземпляров в зависимости от нагрузки, что обеспечивает более высокую параллельность выполнения джобов.
   - **Изоляция:** В Kubernetes контейнеры с джобами могут быть запущены в изолированных подах, обеспечивая лучшую изоляцию и безопасность выполнения задач.
   - **Управление ресурсами:** В Kubernetes можно лучше управлять ресурсами, выделенными для выполнения джобов, такими как CPU и память, благодаря возможностям Kubernetes по управлению ресурсами контейнеров.
   - **Управление жизненным циклом:** Kubernetes обеспечивает удобное управление жизненным циклом контейнеров, их масштабированием и обновлением, что может быть удобнее для развертывания и управления GitLab Runner.

## 12. 



## 13. 



## 14. 



## 15. 



## Продолжить (Тех собес с аналогом TikTok) с 00:19:25