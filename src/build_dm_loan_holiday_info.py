import os

import psycopg2
from dotenv import load_dotenv


load_dotenv()


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


def reload_dm_loan_holiday_info(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM dm.loan_holiday_info;")
        before_count = cur.fetchone()[0]
        print(f"[DM]: loan_holiday_info before reload: {before_count}")

        cur.execute("CALL dm.reload_loan_holiday_info();")
        print("[DM]: loan_holiday_info reloaded")

        cur.execute("SELECT COUNT(*) FROM dm.loan_holiday_info;")
        after_count = cur.fetchone()[0]
        print(f"[DM]: loan_holiday_info after reload: {after_count}")


def main():
    with get_connection() as conn:
        execute_sql_file(conn, "sql/dm/procedures/reload_loan_holiday_info.sql")
        conn.commit()
        reload_dm_loan_holiday_info(conn)
        conn.commit()


if __name__ == "__main__":
    main()
