# Class dataset: entity relationship design

Source file: `data/class_dataset.csv`, one intake-survey response per student (34 rows, 14 columns).
Deployed as five tables on Railway Postgres by `db/schema.sql`; loaded by `db/load_class_dataset.py`.

## Entities and attributes

| Entity | Table | Attributes (type) | Primary key |
|---|---|---|---|
| Student | `students` | netid (text, unique), name (text), school_year (text), intro_programming (text), skill_programming / skill_data_stats / skill_frontend_design / skill_business_pitch (smallint 1–5), working_style, interests, semester_goal (text), submitted_at (timestamptz) | `student_id`, generated |
| Tool | `tools` | name (text, unique) | `id`, generated |
| Availability slot | `availability_slots` | name (text, unique) | `id`, generated |

## Relationships

| Relationship | Cardinality | Implemented as |
|---|---|---|
| Student **uses** Tool | many-to-many | bridge table `student_tools (student_id, tool_id)` |
| Student **is free in** Availability slot | many-to-many | bridge table `student_availability (student_id, slot_id)` |

```
students 1 ──< student_tools >── 1 tools
students 1 ──< student_availability >── 1 availability_slots
```

## Decisions and why

- **Generated ids, not names, as keys.** The file has two different students named Dawid Litwiniec (netids dj2415 and dsl9927). A name key would merge them.
- **netid is unique but not the key.** A student who resubmits the form updates their row instead of creating a duplicate.
- **`tools` and `availability` are not columns.** In the CSV they hold several semicolon-joined values per cell, which is the signature of a many-to-many relationship, so each gets its own entity table plus a bridge table.
- **Skill ratings stay on `students`** as small integers with a 1–5 check: one value per student, so they are plain attributes.
- **`submitted_at` is a timestamp with time zone**, not text; the form writes ISO-8601 with an offset.
- **`interests` stays free text.** It has line breaks, not a delimiter, so it is not a list to split.
- **`intro_programming` stays text**, not boolean: it has three values (took_it, equivalent, neither).

## Loaded counts (2026-10-20)

students 34 · tools 6 · availability_slots 6 · student_tools 105 · student_availability 100
