"""Class 7 deploy lab, part 1d: connect to the deployed Postgres and run the lab's check queries.

Usage (repo root, DATABASE_URL in .env):  python3 db/queries.py
"""
import os, sys
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")
DATABASE_URL = os.environ.get("DATABASE_URL") or sys.exit("DATABASE_URL missing from .env")

QUERIES = {
    "row count (must match the CSV)": "SELECT count(*) FROM students;",
    "first five students": "SELECT name, school_year FROM students LIMIT 5;",
    "students per tool (the lab's query 5, on our data)": """
        SELECT t.name, COUNT(*) AS n_students
        FROM student_tools st
        JOIN tools t ON st.tool_id = t.id
        GROUP BY t.name
        ORDER BY n_students DESC;""",
    "students per availability window": """
        SELECT a.name, COUNT(*) AS n_students
        FROM student_availability sa
        JOIN availability_slots a ON sa.slot_id = a.id
        GROUP BY a.name
        ORDER BY n_students DESC;""",
}

def main():
    with psycopg2.connect(DATABASE_URL) as conn, conn.cursor() as cur:
        for title, sql in QUERIES.items():
            cur.execute(sql)
            cols = [d[0] for d in cur.description]
            print(f"\n== {title}\n   {' | '.join(cols)}")
            for row in cur.fetchall():
                print("   " + " | ".join(str(v) for v in row))

if __name__ == "__main__":
    main()
