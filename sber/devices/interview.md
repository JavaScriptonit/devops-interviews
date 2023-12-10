# Список вопросов:

## Собеседование со Сбер Devices:
https://hh.ru/vacancy/83405120?hhtmFrom=employer_vacancies


# Terraform.

1. ## Что будет если 2 разработчика обновят файл .tfstate одновременно?

https://ru.hexlet.io/courses/terraform-basics/lessons/remote-state/theory_unit

`Terraform` хранит текущее состояние инфраструктуры в файле с расширением `.tfstate`. При выполнении операций `Terraform` идет в файл состояния и проверяет, какая инфраструктура уже развернута. На основе того, что есть в состоянии и что описано в проекте, `Terraform` понимает, что нужно сделать — создать инфраструктуру или изменить.

Если организовать этот процесс через `git-репозиторий`, нужно сначала обновить инфраструктуру, затем добавить коммит с новым `tfstate` и отправить его в удаленный репозиторий. Коллега должен получить из репозитория актуальный `tfstate`, внести свои изменения, и в свою очередь отправить изменения в коде `Terraform` и новый файл состояния в `Git`

### `Terraform remote backends`:

В терминологии Terraform backend — это решение, которое отвечает за хранение состояния. Если состояние хранится удаленно — это `remote backend`.

При использовании remote backend Terraform сохраняет состояние в удаленное хранилище, а локально в tfstate хранит только информацию об этом удаленном хранилище.

В качестве хранилища может выступать любое облачное объектное хранилище по типу `Amazon S3: Google Cloud Storage`, `Azure Storage`, `Yandex Cloud Storage` и другие подобные решения. Также Terraform может использовать для удаленного хранения состояния HTTP-сервер, базу данных PostgreSQL или облачную платформу Terraform Cloud.

В схеме с remote backend при выполнении любых операций над инфраструктурой Terraform будет обращаться к удаленному файлу состояния, блокировать его на время выполнения изменений, затем перезаписывать этот файл с учетом внесенных изменений

#### Как настроить хранение состояния в S3:
Подготавливаем облако для хранения состояния (Создадим в облаке S3-хранилище yc-hexlet-state объемом 10МБ. Этого хватит для хранения состояния надолго):
```
yc storage bucket create --name yc-hexlet-state --max-size 10000000
```
сделать табличку в облачной базе данных, где Terraform будет фиксировать блокировки состояния:
```
yc ydb database create terraform-state-lock --serverless

done (7s)
id: etnpkn3gs4s56qk9g7kf
folder_id: ...
created_at: ...
name: terraform-state-lock
...
document_api_endpoint: https://docapi.serverless.yandexcloud.net/ru-central1/b1gjrod3dvqni46u3paj/etnpkn3gs4s56qk9g7kf
```
Сохраним document_api_endpoint, он нам понадобится при конфигурации Terraform («Создать таблицу» и создадим документную таблицу lock с колонкой LockID типа String, которая будет являться ключом партиционирования)

через YandexCLI создадим сервисный аккаунт hexlet-remote, который будет сохранять состояние Terraform в облачное хранилище
```
yc iam service-account create --name hexlet-remote --description "SA to manage terraform state"

id: ajejk11p9ls1vvhc12mb
folder_id: ...
created_at: ...
name: hexlet-remote
description: SA to manage terraform state
```

Создадим в проекте файл backend.tf и вставим туда блок backend, описывающий хранение состояния:
```
terraform {
  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    region                      = "ru-central1"
    bucket                      = "yc-hexlet-state"
    key                         = "hexlet-remote-state"
    access_key                  = "YCABX6vQXtCjoKu_oB7QabuZO"
    secret_key                  = "YCOL4xZ1tdpduS46z_YTlvDzYUwv8xBK_UuRq18m"
    dynamodb_endpoint           = "https://docapi.serverless.yandexcloud.net/ru-central1/b1gjrod3dvqni46u3paj/etnpkn3gs4s56qk9g7kf"
    dynamodb_table              = "lock"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
```
Перенести локальный файл с состоянием в удаленное хранилище:
```
terraform init -migrate-state
```

Так мы с помощью удаленного хранения состояния в S3-хранилище и блокировки состояния в YDB добились того, что:

Состояние инфраструктуры всегда будет одинаковым и актуальным у всей команды. Локально в .tfstate проекта будет храниться только адрес удаленного бэкенда
Не возникнут конфликты одновременного обновления инфраструктуры двумя или более членами команды
Мы настроили удаленное хранение состояния. Осталось позаботиться о безопасности и о том, чтобы ключи для нашего хранилища не утекли в сеть.

2. ## Отличие Git stash от Git rebase?


