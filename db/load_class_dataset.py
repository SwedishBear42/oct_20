"""Class 7 deploy lab, part 1c: create the schema on the Railway Postgres and load data/class_dataset.csv.

Usage (from the repo root, with DATABASE_URL in .env = Railway's DATABASE_PUBLIC_URL):
    python3 db/load_class_dataset.py            # create tables + load, prints row counts
    python3 db/load_class_dataset.py --reset    # drop the five tables first, then reload
"""
import csv, os, sys
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")
DATABASE_URL = os.environ.get("DATABASE_URL")
if not DATABASE_URL:
    sys.exit("DATABASE_URL is not set. Put Railway's DATABASE_PUBLIC_URL in .env as DATABASE_URL=...")
if "railway.internal" in DATABASE_URL:
    sys.exit("That is the PRIVATE Railway host; it only resolves inside Railway. Use DATABASE_PUBLIC_URL locally.")

SCHEMA = (ROOT / "db" / "schema.sql").read_text()
CSV = ROOT / "data" / "class_dataset.csv"
TABLES = ["student_availability", "student_tools", "availability_slots", "tools", "students"]  # drop order: bridges first

def split_multi(cell):
    return [v.strip() for v in (cell or "").split(";") if v.strip()]

def to_int(v):
    try:
        return int(v)
    except (TypeError, ValueError):
        return None

def main():
    rows = list(csv.DictReader(open(CSV, newline="", encoding="utf-8")))
    with psycopg2.connect(DATABASE_URL) as conn, conn.cursor() as cur:
        if "--reset" in sys.argv:
            for t in TABLES:
                cur.execute(f"DROP TABLE IF EXISTS {t} CASCADE")
        cur.execute(SCHEMA)                                   # parents first, bridges last (order in the file)

        for r in rows:
            cur.execute(
                """INSERT INTO students (netid, name, school_year, intro_programming, skill_programming,
                       skill_data_stats, skill_frontend_design, skill_business_pitch, working_style,
                       interests, semester_goal, submitted_at)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
                   ON CONFLICT (netid) DO UPDATE SET name = EXCLUDED.name, submitted_at = EXCLUDED.submitted_at
                   RETURNING student_id""",
                (r["netid"].strip(), r["name"].strip(), r["school_year"], r["intro_programming"],
                 to_int(r["skill_programming"]), to_int(r["skill_data_stats"]), to_int(r["skill_frontend_design"]),
                 to_int(r["skill_business_pitch"]), r["working_style"], r["interests"], r["semester_goal"],
                 r["submitted_at"] or None))
            student_id = cur.fetchone()[0]

            for tool in split_multi(r["tools"]):
                cur.execute("INSERT INTO tools (name) VALUES (%s) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id", (tool,))
                cur.execute("INSERT INTO student_tools (student_id, tool_id) VALUES (%s,%s) ON CONFLICT DO NOTHING", (student_id, cur.fetchone()[0]))

            for slot in split_multi(r["availability"]):
                cur.execute("INSERT INTO availability_slots (name) VALUES (%s) ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name RETURNING id", (slot,))
                cur.execute("INSERT INTO student_availability (student_id, slot_id) VALUES (%s,%s) ON CONFLICT DO NOTHING", (student_id, cur.fetchone()[0]))

        print(f"loaded {len(rows)} CSV rows\n")
        for t in reversed(TABLES):
            cur.execute(f"SELECT count(*) FROM {t}")
            print(f"{t:<22}{cur.fetchone()[0]:>5} rows")

if __name__ == "__main__":
    main()
