# Banking DWH Maintenance

ETL-проект для загрузки и исправления банковских данных в PostgreSQL, а также перезагрузки витрин DM.

В проекте реализованы:
- загрузка CSV-файлов в stage, RD и DM слои
- поиск и удаление дублей
- обновление данных в RD и DM слоях
- SQL-скрипты для поиска и исправления проблем в данных
- процедуры перезагрузки витрин

## Стек

- Python 3.7+
- PostgreSQL 13+
- pandas
- SQLAlchemy
- psycopg2

## Структура проекта

```text
.
├── data
│   └── raw
│       ├── dict_currency
│       │   └── dict_currency.csv
│       └── loan_holiday_info
│           ├── deal_info.csv
│           └── product_info.csv
├── docs
│   └── video_links.txt
├── dumps
│   ├── DATABASE_DUMP_linux.sql
│   └── DATABASE_DUMP.sql
├── README.md
├── requirements.txt
├── sql
│   ├── dm
│   │   ├── dml
│   │   │   └── sync_dict_currency.sql
│   │   ├── procedures
│   │   │   ├── reload_account_balance_turnover.sql
│   │   │   └── reload_loan_holiday_info.sql
│   │   └── prototypes
│   │       ├── account_balance_turnover_prototype.sql
│   │       └── loan_holiday_info_prototype.sql
│   ├── maintenance
│   │   ├── check_correct_account_in_sum.sql
│   │   ├── check_correct_account_out_sum.sql
│   │   ├── cleanup_duplicates.sql
│   │   └── fix_account_balance_in_sum.sql
│   └── rd
│       └── dml
│           ├── sync_deal_info.sql
│           └── sync_product.sql
└── src
    ├── build_dm_account_balance_turnover.py
    ├── build_dm_loan_holiday_info.py
    ├── load_dm_data.py
    └── load_rd_data.py
```

## Инициализация базы данных

Для восстановления базы данных из дампа выполните команду:

```bash
psql -h <host> -U <user> -f dumps/<dump_file>.sql
```

Где:
- `<host>` — адрес PostgreSQL (например, `localhost`)
- `<user>` — пользователь PostgreSQL
- `<dump_file>` — файл дампа базы данных

Пример:

```bash
psql -h localhost -U postgres -f dumps/DATABASE_DUMP_linux.sql
```

В проекте представлены два дампа:
- `DATABASE_DUMP.sql` — для Windows
- `DATABASE_DUMP_linux.sql` — для Linux

## Настройка

1. Создать виртуальное окружение
2. Установить зависимости:

```bash
pip install -r requirements.txt
```

3. Создать `.env` на основе `.env.example`
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_db
DB_USER=your_user
DB_PASSWORD=your_password
```

## Запуск процессов

### Загрузка данных в RD

```bash
python src/load_rd_data.py
```

Загружает:
- `deal_info.csv`
- `product_info.csv`

в:
- `stage.*`
- `rd.*`

---

### Загрузка справочника валют

```bash
python src/load_dm_data.py
```

Загружает:
- `dict_currency.csv`

в:
- `stage.dict_currency`
- `dm.dict_currency`

---

### Перезагрузка витрины loan_holiday_info

```bash
python src/build_dm_loan_holiday_info.py
```

Создаёт/обновляет процедуру:
- `dm.reload_loan_holiday_info`

и выполняет перезагрузку витрины:
- `dm.loan_holiday_info`

---

### Перезагрузка витрины account_balance_turnover

```bash
python src/build_dm_account_balance_turnover.py
```

Создаёт/обновляет процедуру:
- `dm.reload_account_balance_turnover`

и выполняет перезагрузку витрины:
- `dm.account_balance_turnover`

## Видео демонстрации

Ссылки на видео находятся в файле `docs/video_links.txt`.