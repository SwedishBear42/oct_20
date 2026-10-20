-- =====================================================================
--  CLASS DATASET SCHEMA  (data/class_dataset.csv -> Postgres on Railway)
--  Source: one intake-survey response per student, 34 rows, 14 columns.
-- =====================================================================
--
--  ENTITY RELATIONSHIP SUMMARY
--  ---------------------------
--  Entities (nouns we keep information about):
--    student            one person in the class
--    tool               one programming / analysis tool (Python, SQL, ...)
--    availability_slot  one time window a student can meet (Weekday mornings, ...)
--
--  Relationships:
--    student  USES         tool               many-to-many  -> bridge table student_tools
--    student  IS FREE IN   availability_slot  many-to-many  -> bridge table student_availability
--
--  Cardinality:
--    a student uses 0..many tools; a tool is used by 0..many students
--    a student is free in 0..many slots; a slot has 0..many students
--
--  Keys:
--    every table has a generated integer primary key (never a name: the file
--    contains two different students called Dawid Litwiniec)
--    netid is unique on students but is not the key, so a re-submitted row
--    updates the same student instead of creating a second one
--
--  Rules applied: entity -> table, 1:N -> foreign key, M:N -> bridge table.
--  Tables are declared parents first so the file can run top to bottom.
-- =====================================================================


-- ---------------------------------------------------------------------
--  1. students  (entity)
--     The 12 plain attributes of a response stay here. The two multi-value
--     columns in the CSV (tools, availability) are NOT here: see 2 and 3.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS students (
    student_id            SERIAL      PRIMARY KEY,
    netid                 TEXT        NOT NULL UNIQUE,                -- NYU NetID, e.g. mis9424
    name                  TEXT        NOT NULL,
    school_year           TEXT,                                       -- Sophomore / Junior / Senior
    intro_programming     TEXT,                                       -- took_it / equivalent / neither
    skill_programming     SMALLINT    CHECK (skill_programming     BETWEEN 1 AND 5),
    skill_data_stats      SMALLINT    CHECK (skill_data_stats      BETWEEN 1 AND 5),
    skill_frontend_design SMALLINT    CHECK (skill_frontend_design BETWEEN 1 AND 5),
    skill_business_pitch  SMALLINT    CHECK (skill_business_pitch  BETWEEN 1 AND 5),
    working_style         TEXT,                                       -- free text
    interests             TEXT,                                       -- free text, may contain line breaks
    semester_goal         TEXT,                                       -- free text
    submitted_at          TIMESTAMPTZ                                 -- form timestamp, stored timezone-aware
);


-- ---------------------------------------------------------------------
--  2. tools  (entity)  +  student_tools  (bridge, M:N)
--     CSV column `tools` holds values like "Python; SQL; Excel".
--     Each distinct value becomes one row in tools; each (student, tool)
--     pair becomes one row in student_tools.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS tools (
    id    SERIAL PRIMARY KEY,
    name  TEXT   NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS student_tools (
    student_id  INTEGER NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    tool_id     INTEGER NOT NULL REFERENCES tools(id)            ON DELETE CASCADE,
    PRIMARY KEY (student_id, tool_id)
);


-- ---------------------------------------------------------------------
--  3. availability_slots  (entity)  +  student_availability  (bridge, M:N)
--     CSV column `availability` holds values like
--     "Weekday afternoons; Weekend mornings". Same pattern as tools.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS availability_slots (
    id    SERIAL PRIMARY KEY,
    name  TEXT   NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS student_availability (
    student_id  INTEGER NOT NULL REFERENCES students(student_id)   ON DELETE CASCADE,
    slot_id     INTEGER NOT NULL REFERENCES availability_slots(id) ON DELETE CASCADE,
    PRIMARY KEY (student_id, slot_id)
);


-- ---------------------------------------------------------------------
--  Indexes for the joins the app will run most (bridge -> parent lookups)
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_student_tools_tool        ON student_tools(tool_id);
CREATE INDEX IF NOT EXISTS idx_student_availability_slot ON student_availability(slot_id);
