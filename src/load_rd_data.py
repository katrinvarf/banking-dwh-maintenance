import os

import psycopg2
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine


load_dotenv()


RD_TABLES = {
    "deal_info": "deal_info.csv",
    "product": "product_info.csv"
}


def get_engine():
    return create_engine(
        f"postgresql+psycopg2://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
        f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
    )


def get_connection():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT"),
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD")
    )


def execute_sql_file(conn, file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        sql = file.read()
    with conn.cursor() as cur:
        cur.execute(sql)
        return cur.rowcount


def create_stage_schema(conn):
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS stage;")
    conn.commit()


def load_to_stage(table_name):
    try:
        df = pd.read_csv(f"data/raw/loan_holiday_info/{RD_TABLES[table_name]}", delimiter=",", encoding="windows-1251")
        engine = get_engine()
        df.to_sql(table_name, engine, schema="stage", if_exists="replace", index=False)

        return len(df)

    except Exception as error:
        print(error)
        raise


def load_to_rd(conn, table_name):
    try:
        inserted_rows = execute_sql_file(conn, f"sql/rd/dml/sync_{table_name}.sql")
        conn.commit()

        return inserted_rows

    except Exception as error:
        print(error)
        conn.rollback()
        raise


def main():
    with get_connection() as conn:
        create_stage_schema(conn)

        for table_name in RD_TABLES:
            stage_rows = load_to_stage(table_name)
            rd_rows = load_to_rd(conn, table_name)

            print(f"{table_name}: stage={stage_rows}, inserted_to_rd={rd_rows}")


if __name__ == "__main__":
    main()
