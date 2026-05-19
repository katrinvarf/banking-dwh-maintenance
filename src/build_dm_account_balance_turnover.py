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


def reload_dm_account_balance_turnover(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT COUNT(*) FROM dm.account_balance_turnover;")
        before_count = cur.fetchone()[0]
        print(f"[DM]: account_balance_turnover before reload: {before_count}")

        cur.execute("CALL dm.reload_account_balance_turnover();")
        print("[DM]: account_balance_turnover reloaded")

        cur.execute("SELECT COUNT(*) FROM dm.account_balance_turnover;")
        after_count = cur.fetchone()[0]
        print(f"[DM]: account_balance_turnover after reload: {after_count}")


def main():
    with get_connection() as conn:
        execute_sql_file(conn, "sql/dm/procedures/reload_account_balance_turnover.sql")
        conn.commit()
        reload_dm_account_balance_turnover(conn)
        conn.commit()


if __name__ == "__main__":
    main()
