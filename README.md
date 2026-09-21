# Analytical Data Warehouse: S3 → Airflow → Vertica

Учебный проект по построению загрузочного контура аналитического хранилища данных.

Проект демонстрирует полный путь обработки данных: получение CSV-файла из S3, загрузку данных в staging-слой Vertica, формирование DWH-таблиц и выполнение аналитических SQL-запросов с использованием CTE.

## Цели проекта

- автоматизировать загрузку данных из S3 с помощью Apache Airflow;
- загрузить исходные данные в staging-слой Vertica;
- сформировать связи между пользователями и группами;
- сохранить историю событий пользователей в DWH;
- получить аналитические показатели по активности пользователей в группах;
- использовать SQL-конструкции `JOIN`, `CTE`, `GROUP BY`, агрегатные функции и оконные/аналитические подходы там, где это необходимо.

## Архитектура

```text
                    ┌───────────────┐
                    │      S3       │
                    │  group_log.csv│
                    └───────┬───────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Apache Airflow      │
                 │ get_group_log_dag   │
                 └──────────┬──────────┘
                            │
                            ▼
                    /data/group_log.csv
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Apache Airflow      │
                 │ load_group_log_dag  │
                 └──────────┬──────────┘
                            │ COPY
                            ▼
                 ┌─────────────────────┐
                 │ Vertica             │
                 │ STAGING.group_log   │
                 └──────────┬──────────┘
                            │
                            │ INSERT / JOIN
                            ▼
                 ┌─────────────────────┐
                 │ Vertica DWH          │
                 │ h_users / h_groups   │
                 │ l_user_group_activity│
                 │ s_auth_history       │
                 └──────────┬──────────┘
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Аналитические SQL    │
                 │ CTE / JOIN / GROUP BY│
                 └─────────────────────┘
```

## Структура проекта

```text
analytical-data-warehouse/
├── README.md
├── .gitignore
└── src/
    ├── dags/
    │   ├── get_group_log_dag.py
    │   └── load_group_log_in_stg_dag.py
    └── sql/
        ├── ddl_group_log.sql
        ├── ddl_l_user_group_activity.sql
        ├── ddl_s_auth_history.sql
        ├── dml_l_user_group_activity.sql
        ├── dml_s_auth_history.sql
        ├── cte_user_group_log.sql
        ├── cte_user_group_message.sql
        └── analytical_answer_with_cte.sql
```

## Используемые технологии

- **Python** — реализация Airflow DAG;
- **Apache Airflow** — оркестрация загрузочного процесса;
- **Amazon S3** — источник исходного CSV-файла;
- **Vertica** — аналитическая СУБД и DWH;
- **SQL** — DDL, DML и аналитические запросы;
- **Git** — версионирование проекта.

## Основные этапы

### 1. Получение данных из S3

DAG `get_group_log_dag.py` подключается к S3 через `S3Hook`, получает файл `group_log.csv` из bucket `sprint6` и сохраняет его локально по пути `/data/group_log.csv`.

### 2. Загрузка в staging

DAG `load_group_log_in_stg_dag.py` использует `VerticaHook` и команду `COPY` для загрузки CSV-файла в таблицу `VT26052617E774__STAGING.group_log`.

### 3. Формирование DWH-слоя

SQL-скрипты создают и заполняют две основные сущности:

- `l_user_group_activity` — связь пользователя с группой;
- `s_auth_history` — история событий пользователей.

Для формирования surrogate/hash key связи пользователя и группы используется `HASH(user_id, group_id)`.

### 4. Аналитика

Запросы в `src/sql/` рассчитывают количество пользователей, добавленных в группы, количество пользователей, создавших сообщения, и коэффициент конверсии:

```text
conversion = users_with_messages / added_users
```

Для обработки отдельных этапов аналитики используются CTE, `JOIN`, `COUNT(DISTINCT ...)`, `COALESCE` и `NULLIF`.

## Запуск

Проект рассчитан на учебное окружение с предоставленным контейнером Yandex Practicum.

Запуск контейнера:

```bash
docker run \
  -d \
  -p 3000:3000 \
  -p 3002:3002 \
  -p 15432:5432 \
  --mount src=airflow_sp5,target=/opt/airflow \
  --mount src=lesson_sp5,target=/lessons \
  --mount src=db_sp5,target=/var/lib/postgresql/data \
  --name=de-project-adb-server-local \
  cr.yandex/crp1r8pht0n0gl25aug1/de-pg-cr-af:latest
```

После запуска:

- Airflow: `http://localhost:3000/airflow`
- Vertica/PostgreSQL endpoint учебного окружения: `localhost:15432`

> Конкретные Airflow connections (`s3_connection`, `vertica_conn`) и структура учебной базы должны быть настроены в окружении проекта.

## Порядок выполнения SQL

1. `ddl_group_log.sql` — создание staging-таблицы.
2. `ddl_l_user_group_activity.sql` — создание link-таблицы DWH.
3. `ddl_s_auth_history.sql` — создание satellite/history-таблицы DWH.
4. `dml_l_user_group_activity.sql` — загрузка связей пользователь–группа.
5. `dml_s_auth_history.sql` — загрузка истории событий.
6. `cte_user_group_log.sql` и `cte_user_group_message.sql` — отдельные аналитические расчёты.
7. `analytical_answer_with_cte.sql` — итоговый аналитический запрос.

## Что демонстрирует проект

Проект показывает практическое применение нескольких компонентов Data Engineering:

- ingestion из объектного хранилища;
- оркестрация через Airflow;
- staging-слой;
- DWH-моделирование с hub/link/satellite-подходом;
- DDL и DML для аналитического хранилища;
- построение аналитических запросов на SQL;
- расчёт бизнес-метрики на основе нескольких источников данных внутри DWH.

## Примечание

Проект выполнен в рамках учебного спринта «Аналитические базы данных» и оформлен как самостоятельный портфолио-проект с сохранением исходной логики решения.
