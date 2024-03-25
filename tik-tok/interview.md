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

## 12. Какой executor используется для запуска джобов? Какие бывают? Почему выбран именно docker? (Gitlab Runner)

GitLab Runner поддерживает несколько различных типов executor'ов для запуска джобов. Некоторые из них:

1. **Shell executor:** Использует оболочку командной строки для запуска джобов. Этот executor прост в настройке, но не обеспечивает изоляцию и безопасность контейнеров.

2. **Docker executor:** Запускает каждую джобу в отдельном контейнере Docker. Этот executor обеспечивает изоляцию среды выполнения, легко масштабируется и позволяет использовать готовые образы Docker для выполнения задач.

3. **Kubernetes executor:** Запускает джобы в Kubernetes подах. Этот executor обеспечивает масштабируемость, изоляцию и управление ресурсами в Kubernetes кластере.

4. **SSH executor:** Позволяет запускать джобы на удаленных серверах по SSH. Этот executor полезен для интеграции с legacy системами или для запуска задач на удаленных серверах.

Выбор Docker executor для GitLab Runner часто обусловлен следующими причинами:

- **Изоляция:** Docker обеспечивает изоляцию среды выполнения каждой джобы, что повышает безопасность и предотвращает конфликты между задачами.
- **Портативность:** Docker образы легко переносимы и могут быть использованы на разных платформах, что облегчает развертывание и управление GitLab Runner.
- **Удобство:** Docker позволяет использовать готовые образы с необходимыми инструментами и зависимостями, упрощая настройку и выполнение джобов.

Таким образом, выбор Docker executor для GitLab Runner обычно обусловлен его удобством, изоляцией и портативностью, что делает его популярным выбором для запуска джобов в CI/CD pipeline.

## 13. Какие объекты создаёт terraform? Где лучше всего хранить terraform? Как лучше всего делить созданные объекты в terraform? Единый стейт или Terragrunt в каких случаях используется? (Terraform)

1. **Определение инфраструктуры:** На языке конфигурации Terraform (HCL) описывается желаемое состояние инфраструктуры, включая виртуальные машины, сети, хранилища и другие ресурсы.

2. **Инициализация:** Terraform инициализируется для загрузки необходимых провайдеров и модулей, указанных в конфигурации.

3. **Планирование:** Terraform генерирует план изменений, которые будут применены к текущей инфраструктуре для достижения желаемого состояния.

4. **Применение:** После проверки плана изменений, Terraform применяет их, создавая, изменяя или удаляя ресурсы в облаке или локальной инфраструктуре.

При работе с `Terraform` обычно используются модули, переменные и state файлы для организации и управления конфигурацией. Модули позволяют организовать конфигурацию на более мелкие и переиспользуемые блоки, переменные используются для передачи значений в конфигурацию, а **state файл хранит текущее состояние инфраструктуры**.

`Terragrunt` - это дополнительный инструмент, который облегчает управление конфигурациями Terraform, особенно при работе с крупными проектами. Terragrunt предоставляет дополнительные функции, такие как управление переменными, блокировка состояния и использование модулей Terraform.

Terraform создает различные объекты в облаке или локальной инфраструктуре в соответствии с описанными в конфигурации ресурсами. Некоторые из типичных объектов, которые Terraform может создать, включают виртуальные машины, сетевые ресурсы (например, сети, подсети, балансировщики нагрузки), хранилища данных (например, базы данных, объектные хранилища), и многое другое.

### Что касается хранения Terraform конфигурации и состояния, рекомендуется использовать следующие подходы:

1. **Хранение конфигурации:** Terraform конфигурационные файлы лучше всего хранить в системе контроля версий, таком как Git. Это обеспечивает версионирование, аудит и совместную работу над конфигурацией.

2. **Хранение состояния:** Состояние Terraform, которое отслеживает текущее состояние инфраструктуры, должно быть храниться в безопасном и надежном месте. Рекомендуется использовать удаленное хранилище состояния, такое как Terraform Cloud, AWS S3, Azure Blob Storage и т. д.

Что касается деления созданных объектов в Terraform, хорошей практикой является использование модулей для организации и переиспользования конфигурации. Модули позволяют разделить инфраструктурные ресурсы на логические блоки, что упрощает управление и поддержку конфигурации.

### Относительно использования единого состояния Terraform против Terragrunt, обычно Terragrunt используется в следующих случаях:

- Когда требуется управление переменными и конфигурациями на разных уровнях (например, на уровне окружений).
- Когда необходима более гибкая организация конфигураций и модулей Terraform.
- При работе с крупными проектами, где требуется более сложное управление состоянием и конфигурациями.

Таким образом, Terraform создает различные объекты инфраструктуры, конфигурационные файлы лучше всего хранить в системе контроля версий, состояние - в удаленном хранилище, объекты можно лучше всего делить на модули, и Terragrunt используется в случаях, когда требуется более сложное управление конфигурациями и состоянием Terraform.

## 14. Где хранить .tfstate? (Terraform)

https://cloud.yandex.ru/ru/docs/tutorials/infrastructure-management/terraform-state-storage#bash_1 - Загрузка состояний Terraform в Yandex Object Storage

Хранение файла состояния (.tfstate) в системе контроля версий, такой как GitLab или GitHub, не является рекомендуемой практикой. Файл состояния Terraform содержит чувствительную информацию о текущем состоянии инфраструктуры, и его изменения могут быть критическими для безопасности и целостности инфраструктуры.

Рекомендуется хранить файл состояния в безопасном и надежном удаленном хранилище, таком как AWS S3, Azure Blob Storage, Google Cloud Storage или Terraform Cloud. Это обеспечивает централизованное управление состоянием, защиту от потери данных и возможность совместной работы над инфраструктурой.

Если файл состояния будет храниться в системе контроля версий, это может привести к проблемам с конкурентным доступом, возможными конфликтами при слиянии изменений и уязвимостям безопасности. Поэтому для хранения .tfstate рекомендуется использовать специализированные инструменты и сервисы, предназначенные для управления состоянием Terraform.

```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "<имя_бакета>"
    region = "ru-central1"
    key    = "<путь_к_файлу_состояния_в_бакете>/<имя_файла_состояния>.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.

  }
}

provider "yandex" {
  zone      = "<зона_доступности_по_умолчанию>"
}
```

## 15. Что делать если произошло изменение файла состояния (.tfstate) вручную? (Terraform)

Изменение файла состояния (.tfstate) вручную не рекомендуется, так как это может привести к несоответствиям между фактическим состоянием инфраструктуры и содержимым файла состояния. Это может вызвать ошибки развертывания, потерю данных или другие проблемы.

Если в файл состояния был внесен код вручную, то рекомендуется принять следующие шаги:

1. **Откат изменений:** Попробуйте откатить изменения в файле состояния до предыдущего рабочего состояния, если это возможно. Это можно сделать, например, через систему контроля версий, если у вас есть сохраненные версии файла состояния.

2. **Восстановление из резервной копии:** Если у вас есть резервные копии файла состояния, попробуйте восстановить состояние из последней рабочей резервной копии.

3. **Пересоздание ресурсов:** Если не удается восстановить файл состояния, возможно придется пересоздать ресурсы, описанные в файле состояния. Это может быть времязатратным процессом, но иногда это единственный способ восстановить целостность инфраструктуры.

Для предотвращения подобных ситуаций и обеспечения безопасной работы с файлом состояния (.tfstate) рекомендуется следовать следующим best practices:

1. **Используйте удаленное хранилище состояния:** Храните файл состояния в удаленном и безопасном хранилище, таком как AWS S3, Azure Blob Storage или Terraform Cloud. Это обеспечивает централизованное управление состоянием и защиту от потери данных.

2. **Не изменяйте файл состояния вручную:** Избегайте внесения изменений в файл состояния вручную, используйте Terraform для управления состоянием и инфраструктурой.

3. **Регулярно создавайте резервные копии:** Регулярно создавайте резервные копии файла состояния, чтобы иметь возможность восстановиться в случае необходимости.

### Если в файле состояния (.tfstate) были внесены изменения вручную, то:
Рекомендуется исправить это с помощью Terraform, а именно через использование команды `terraform import`.

Команда `terraform import` позволяет импортировать существующий ресурс в управляемый Terraform состоянием. Это позволит Terraform узнать о существующем ресурсе и начать управлять им, не изменяя его текущего состояния.

Изменение файла состояния (.tfstate) напрямую не рекомендуется, так как это может привести к несоответствиям между фактическим состоянием инфраструктуры и содержимым файла состояния, что может вызвать проблемы при развертывании и управлении инфраструктурой.

Поэтому, если были внесены изменения в файл состояния вручную, рекомендуется использовать команду `terraform import` для корректного импорта существующего ресурса в Terraform и обновления состояния.

## 16. Как была развёрнута Mongo? Это был кластер серверов или на 1ом сервере? (БД)

Для поднятия кластера базы данных MongoDB на нескольких серверах с использованием Docker и настройки репликации с монтированием директорий, вам понадобится следовать следующим шагам:

1. **Создание docker-compose.yaml:**

```yaml
version: '3'

services:
  mongodb1:
    image: mongo
    container_name: mongodb1
    ports:
      - "27017:27017"
    volumes:
      - mongodb1_data:/data/db
    networks:
      - mongo-cluster
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password

  mongodb2:
    image: mongo
    container_name: mongodb2
    ports:
      - "27018:27017"
    volumes:
      - mongodb2_data:/data/db
    networks:
      - mongo-cluster
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password

  mongodb3:
    image: mongo
    container_name: mongodb3
    ports:
      - "27019:27017"
    volumes:
      - mongodb3_data:/data/db
    networks:
      - mongo-cluster
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password

volumes:
  mongodb1_data:
  mongodb2_data:
  mongodb3_data:

networks:
  mongo-cluster:
```

2. **Репликация кластера MongoDB:**
   Да, MongoDB поддерживает кластеризацию и репликацию данных. Для настройки кластерной репликации MongoDB, вам нужно будет настроить конфигурацию репликации в каждом узле кластера и указать узлы, которые будут участвовать в репликации.

   - Вы можете настроить репликацию с помощью команды `rs.initiate()` для инициализации репликационного набора и добавления узлов в него.
   - MongoDB также предоставляет механизм автоматического обнаружения и восстановления для обеспечения высокой доступности и отказоустойчивости.

3. **Создание единого пользователя с правами администратора на каждом узле кластера:**
```
$ docker exec -it mongodb1 mongo admin --eval "db.createUser({ user: 'admin', pwd: 'password', roles: [ { role: 'root', db: 'admin' } ] })"
$ docker exec -it mongodb2 mongo admin --eval "db.createUser({ user: 'admin', pwd: 'password', roles: [ { role: 'root', db: 'admin' } ] })"
$ docker exec -it mongodb3 mongo admin --eval "db.createUser({ user: 'admin', pwd: 'password', roles: [ { role: 'root', db: 'admin' } ] })"
```

4. Для настройки репликации данных между узлами кластера MongoDB в Docker, нужно настроить репликацию между узлами. Нужно настроить каждый узел как член репликационного набора и указать основной узел (primary) для записи данных, а также вторичные узлы (secondary) для чтения данных командой `rs.initiate()`:

```bash
$ docker exec -it mongodb1 mongo
> rs.initiate()
> rs.add("mongodb2:27017")
> rs.add("mongodb3:27017")
```

Это настроит репликацию между узлами `mongodb1`, `mongodb2` и `mongodb3`, и данные будут автоматически синхронизироваться между ними.

Таким образом, после настройки репликации данные будут одинаковыми в каждой базе MongoDB, и изменения данных будут автоматически синхронизироваться между узлами кластера.

## 17. С какими системами мониторинга приходилось работать? (Monitoring)(ОПЫТ)
sber/devices/interview.md - 5. Мониторинг. Какой стек использовал?

1. Использование стека grafana + prometheus + node exporter
2. Использование Instana + Instana agents 

# 18. С какими БД менеджерами работал? (БД)

Существуют различные сервисы для управления базами данных MongoDB и PostgreSQL в облаке. Некоторые из наиболее популярных сервисов:

1. **MongoDB Atlas**:
   - MongoDB Atlas - это управляемый сервис баз данных MongoDB, предоставляемый компанией MongoDB. Он позволяет развернуть кластер MongoDB в облаке, обеспечивает автоматическое масштабирование, резервное копирование данных, мониторинг и многое другое.
   - Для использования MongoDB Atlas вам нужно зарегистрироваться на сайте MongoDB Atlas, создать проект, кластер и настроить его параметры через веб-интерфейс.

2. **Amazon RDS (Relational Database Service) для PostgreSQL**:
   - Amazon RDS - это управляемый сервис реляционных баз данных от Amazon Web Services (AWS), который включает в себя поддержку PostgreSQL, MySQL, Oracle, SQL Server и других.
   - Для использования Amazon RDS для PostgreSQL вам нужно создать экземпляр базы данных PostgreSQL через консоль управления AWS, указав параметры экземпляра, такие как тип экземпляра, размер хранилища, имя пользователя и пароль.

Для установки и использования MongoDB Atlas и Amazon RDS для PostgreSQL не требуется установка на локальной машине. Вам нужно просто зарегистрироваться на соответствующем сервисе, создать и настроить вашу базу данных через веб-интерфейс.