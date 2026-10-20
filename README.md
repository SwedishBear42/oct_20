# Deploy lab (Class 7, Oct 20) — class dataset on Railway Postgres

1. Railway → New Project → Deploy PostgreSQL → Postgres service → Connect → Public Network → Add Public Access → deploy.
2. Variables tab → copy `DATABASE_PUBLIC_URL` → paste into a local `.env` as `DATABASE_URL=...` (see `.env.example`). Never commit `.env`.
3. `pip install -r requirements.txt` (already installed on this Mac).
4. `python3 db/load_class_dataset.py` — creates the 5 tables from `db/schema.sql` and loads `data/class_dataset.csv` (34 students, 6 tools, 6 availability slots).
5. `python3 db/queries.py` — the lab's check queries (row count, first five, students per tool).

Schema: `students` (generated `student_id`, `netid` unique) · `tools` + `student_tools` bridge · `availability_slots` + `student_availability` bridge.
