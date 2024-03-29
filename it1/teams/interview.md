# Список вопросов:

## Собеседование с командой:

-----------------------

# Вопросы из записи в iCloud (IT1. Знакомство с командой 1/1):

# k8s:

## 1. Используются ли БД в k8s для имеющихся сервисов? Коннектятся ли БД к каким-то сервисам внутри k8s? (k8s)

1) В Kubernetes (k8s) часто используются базы данных для хранения данных, которые обрабатываются сервисами. БД могут быть запущены внутри кластера Kubernetes для обеспечения отказоустойчивости, масштабируемости и управления данными.

2) Да, базы данных могут подключаться к сервисам внутри кластера Kubernetes. Например, приложения внутри кластера могут использовать DNS имена для обращения к базе данных, которая также запущена в кластере.

Пример поднятия базы данных в Kubernetes с использованием волюма в одном поде и бэкэнд сервиса в другом поде в рамках одного Namespace:

### Шаги для развертывания:

1. **Создание манифестов для базы данных и бэкэнд сервиса**:

   - Создайте манифест для запуска базы данных (например, PostgreSQL) с использованием PersistentVolume и PersistentVolumeClaim для хранения данных.
   - Создайте манифест для запуска бэкэнд-сервиса, который будет подключаться к базе данных.

2. **Применение манифестов**:

   ```bash
   $ kubectl apply -f database-pod.yaml
   $ kubectl apply -f backend-service-pod.yaml
   ```

3. **Обеспечение связи между подами**:
   - В манифесте бэкэнд-сервиса укажите имя базы данных как хост для подключения.
   - Можно использовать DNS имена для обращения к другим сервисам внутри кластера Kubernetes.

Пример манифестов для базы данных и бэкэнд сервиса можно найти ниже:

### Пример манифеста для базы данных (database-pod.yaml):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: database-pod
spec:
  containers:
  - name: database
    image: postgres
    volumeMounts:
    - mountPath: /var/lib/postgresql/data
      name: database-storage
  volumes:
  - name: database-storage
    persistentVolumeClaim:
      claimName: database-pvc
```

### Пример манифеста для бэкэнд-сервиса (backend-service-pod.yaml):
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: backend-service-pod
spec:
  containers:
  - name: backend-service
    image: backend-service-image
    env:
    - name: DATABASE_HOST
      value: database-pod
```

После применения этих манифестов, база данных и бэкэнд-сервис будут запущены в кластере Kubernetes и смогут общаться друг с другом.

## 2. Как вносите изменения в БД когда релизите новую версию приложения и для неё нужно изменить табличку? (k8s)

Для внесения изменений в базу данных при релизе новой версии приложения в Kubernetes и изменения структуры таблицы, можно использовать подходы, такие как использование миграций баз данных или управляемых решений для управления схемой базы данных.

### Миграции баз данных:
1. **Создание миграций**: Создайте скрипты миграций баз данных, которые будут выполнять необходимые изменения в структуре таблицы (например, добавление новых столбцов, изменение типов данных и т. д.).
2. **Применение миграций**: Включите выполнение этих скриптов миграций в процесс деплоя новой версии вашего бэкэнд-приложения. Например, вы можете использовать инструменты для миграции баз данных, такие как Flyway или Liquibase, которые могут автоматически применять миграции при запуске новой версии приложения.

### Пример использования миграций баз данных:
1. Создайте новый скрипт миграции, который содержит SQL-запросы для изменения структуры вашей таблицы.
2. Обновите манифест вашего бэкэнд-сервиса в Kubernetes, чтобы включить применение этого скрипта миграции при деплое новой версии приложения.
3. После успешного деплоя новой версии приложения, скрипт миграции будет выполнен, и изменения в структуре таблицы будут применены.

### Важно:
- При использовании миграций баз данных, убедитесь в тщательном тестировании скриптов миграций перед их применением в производственной среде.
- Резервируйте резервные копии базы данных перед внесением изменений, чтобы в случае неудачного применения миграции можно было быстро восстановить данные.

После внесения изменений в базу данных с помощью миграций, ваше приложение с новой версией сможет корректно работать с обновленной структурой таблицы.

### Пример миграции:

В качестве примера применения скриптов миграций для изменения структуры таблицы в базе данных MySQL при деплое новой версии приложения в Kubernetes, рассмотрим следующий сценарий:

1. **Создание скрипта миграции**:
   - Создайте новый SQL-скрипт, например, `001_alter_table.sql`, который содержит запросы для изменения структуры таблицы. Например, добавим новый столбец `new_column` в таблицу `example_table`:
     ```sql
     ALTER TABLE example_table
     ADD COLUMN new_column VARCHAR(50);
     ```

2. **Применение миграции при деплое новой версии приложения**:
   - Включите выполнение этого скрипта миграции в процесс деплоя новой версии вашего бэкэнд-приложения в Kubernetes. Для этого в манифесте вашего приложения (например, Deployment) добавьте инициализацию контейнера для выполнения скрипта миграции перед запуском приложения.
   - Пример манифеста Deployment с инициализацией контейнера для выполнения скрипта миграции:
     ```yaml
     apiVersion: apps/v1
     kind: Deployment
     metadata:
       name: backend-app
     spec:
       replicas: 3
       template:
         spec:
           containers:
           - name: backend
             image: your-backend-image:latest
           initContainers:
           - name: migrate
             image: mysql:latest
             command: ["mysql", "-h", "your-mysql-host", "-u", "your-username", "-pYourPassword", "your-database", "-e", "source /path/to/001_alter_table.sql"]
     ```

3. **Применение изменений**:
   - После успешного деплоя новой версии приложения в Kubernetes, скрипт миграции `001_alter_table.sql` будет выполнен, и изменения в структуре таблицы будут применены к базе данных.

### Примечания:
- Убедитесь, что у вас есть доступ к базе данных MySQL и правильно указаны параметры подключения в команде MySQL в манифесте.
- Перед применением миграции в производственной среде, убедитесь в тщательном тестировании скрипта миграции на тестовой базе данных.

Это пример использования скриптов миграций для изменения структуры таблицы при деплое новой версии приложения в Kubernetes. Помните о важности тестирования и резервирования данных перед внесением изменений в базу данных.

## 3. Для всех типов БД требуется миграция в таком случае или какие-то БД могут самостоятельно изменить табличку и не потерять текущие данные? Если нужно задеплоить новую версию бэкэнда и внести изменения в бд (БД)

Некоторые базы данных, такие как MongoDB, могут автоматически обновлять схему коллекций при добавлении новых полей или индексов без необходимости явного использования скриптов миграции. Однако, для других типов баз данных, таких как SQL базы данных (например, MySQL, PostgreSQL, SQL Server), часто требуется явное использование скриптов миграции для изменения структуры таблиц.

В любом случае, при деплое новой версии бэкенд-приложения с изменениями в базе данных, рекомендуется использовать механизмы контроля версий и миграций баз данных для обеспечения безопасного и надежного обновления структуры базы данных. Такой подход позволяет контролировать изменения, проводить откат в случае неудачного обновления и обеспечивать согласованность данных.

Если ваша база данных поддерживает автоматическое обновление структуры без необходимости миграции, убедитесь, что это поведение соответствует вашим требованиям по безопасности и целостности данных. В любом случае, рекомендуется тщательно тестировать процесс обновления базы данных перед его применением в производственной среде.

Помните, что хорошо спланированное и протестированное обновление базы данных вместе с новой версией приложения поможет избежать потери данных и обеспечит стабильную работу системы.

## 4. 

## 5.

## 6. 

## 7. 

## 8. 

## 9. 

## 10. 

## 11. 

## 12. 

## 13. 

## 14. 

## 15. 

## 16. 

## 17. 

## 18. 

## 19. 

## 20. 