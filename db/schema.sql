-- Class 7 deploy lab: schema for data/class_dataset.csv (one intake response per student).
-- Rules applied: entity -> table, 1:N -> foreign key, M:N -> bridge table.
--   students            one row per student (generated id; netid is unique but not the PK)
--   tools               one row per distinct tool name
--   student_tools       bridge: a student uses many tools, a tool is used by many students
--   availability_slots  one row per distinct availability window
--   student_availability bridge, same shape as student_tools

CREATE TABLE IF NOT EXISTS students (
    student_id            SERIAL PRIMARY KEY,
    netid                 TEXT        NOT NULL UNIQUE,
    name                  TEXT        NOT NULL,
    school_year           TEXT,
    intro_programming     TEXT,                       -- took_it / not yet, as submitted
    skill_programming     SMALLINT CHECK (skill_programming     BETWEEN 1 AND 5),
    skill_data_stats      SMALLINT CHECK (skill_data_stats      BETWEEN 1 AND 5),
    skill_frontend_design SMALLINT CHECK (skill_frontend_design BETWEEN 1 AND 5),
    skill_business_pitch  SMALLINT CHECK (skill_business_pitch  BETWEEN 1 AND 5),
    working_style         TEXT,
    interests             TEXT,
    semester_goal         TEXT,
    submitted_at          TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS tools (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS student_tools (
    student_id INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    tool_id    INTEGER NOT NULL REFERENCES tools(id)            ON DELETE CASCADE,
    PRIMARY KEY (student_id, tool_id)
);

CREATE TABLE IF NOT EXISTS availability_slots (
    id   SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS student_availability (
    student_id INTEGER NOT NULL REFERENCES students(student_id)      ON DELETE CASCADE,
    slot_id    INTEGER NOT NULL REFERENCES availability_slots(id)    ON DELETE CASCADE,
    PRIMARY KEY (student_id, slot_id)
);
