# SmartFlow Grid: Review 1 Demonstration & Evaluation Guide

This document is specifically tailored for **Review 1 Presentation & Evaluation (10 Marks)**. It provides a structured script, live demonstration steps, and ready answers to anticipated questions from evaluators.

---

## 1. Review 1 Agenda & Presentation Flow (5-10 Minutes)

| Time | Agenda Item | Key Talking Points | Reference Artifacts |
| :--- | :--- | :--- | :--- |
| **0:00 - 1:30** | Problem Statement & Domain Analysis | Inefficiencies of static timer cycles, urban gridlock, carbon footprint, emergency vehicle delays. Solution: IoT sensor-driven relational grid. | [`docs/01_problem_and_domain_analysis.md`](file:///d:/Projects/DBMS%20Case%20Study/docs/01_problem_and_domain_analysis.md) |
| **1:30 - 3:30** | EER Model & Schema Design | Extended ER diagram in Chen notation. Entities, primary/foreign keys, $1:N$ and $1:1$ cardinalities, constraints. | [`docs/02_entities_and_eer_specification.md`](file:///d:/Projects/DBMS%20Case%20Study/docs/02_entities_and_eer_specification.md), [`docs/SmartFlow_Grid_EER_Diagram.png`](file:///d:/Projects/DBMS%20Case%20Study/docs/SmartFlow_Grid_EER_Diagram.png) |
| **3:30 - 6:00** | Live DDL & Integrity Validation | Show table creation, PK/FK links, CHECK on Signal State ('RED','YELLOW','GREEN'), DEFAULT Car_Count = 0. Prove violation handling. | [`oracle/schema/01_ddl_tables.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/schema/01_ddl_tables.sql) |
| **6:00 - 8:30** | Live Telemetry Seeding & Queries | Ingest 5 intersections, 20 lanes, 120 sensor rows. Run group aggregations (SUM, AVG, GROUP BY) & temporal date extractions. | [`oracle/queries/01_group_functions.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/queries/01_group_functions.sql), [`oracle/queries/02_temporal_analysis.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/queries/02_temporal_analysis.sql) |
| **8:30 - 10:00** | Q&A and Transition to Review 2 | Discuss upcoming stored procedures, triggers, views, and normalization proofs. | [`PLAN.md`](file:///d:/Projects/DBMS%20Case%20Study/PLAN.md) |

---

## 2. Step-by-Step Live Demonstration Script

### Step 1: One-Click Demonstration Window Popups
Choose the demonstration format preferred by your evaluator:

1. **Desktop Showcase Window (Recommended):**
   Double-click [`run_gui.bat`](file:///d:/Projects/DBMS%20Case%20Study/run_gui.bat) or run:
   ```bash
   python scripts/review_1_showcase.py
   ```
   *A dedicated application window pops up immediately with live SQL command execution, syntax highlighting, tabular results, interactive query buttons, the full academic EER Diagram, and the 10-Mark Rubric checklist.*

2. **Terminal Demonstration Window:**
   Double-click [`run_terminal.bat`](file:///d:/Projects/DBMS%20Case%20Study/run_terminal.bat) or run:
   ```bash
   python scripts/run_review1_demo.py
   ```
   *A command-line terminal window pops up, executes all commands and tests, formats the result tables, and remains open for evaluator inspection.*

3. **Master Launcher:**
   Double-click [`run_demo.bat`](file:///d:/Projects/DBMS%20Case%20Study/run_demo.bat) to choose between the GUI showcase or the terminal showcase on launch.

### Step 2: Database Native Execution (For Evaluators using Oracle / Postgres)
- **In Oracle SQL Developer / Live SQL:**
  ```sql
  @oracle/tests/run_phase1_oracle.sql
  ```
- **In PostgreSQL `psql` / pgAdmin:**
  ```sql
  \i postgresql/tests/run_phase1_postgres.sql
  ```

---

## 3. Anticipated Viva/Evaluation Questions & Ready Answers

### Q1: "Why use Chen notation instead of standard Crow's Foot ER?"
> **Answer:** "Chen notation explicitly models relationships as first-class semantic diamonds with clear multiplicity tags ($1$, $N$), directly aligning with relational algebra theory and the formal course guidelines. It also distinguishes key attributes via underlines and isolates structural entities from multi-attribute clusters."

### Q2: "How do you enforce that a signal phase can never enter an illegal color?"
> **Answer:** "Via a declarative table-level constraint:
> `CONSTRAINT chk_phase_state CHECK (Current_State IN ('RED', 'YELLOW', 'GREEN'))`.
> We also verified this in our test suite by intentionally attempting to insert `'PURPLE'`, which was immediately rejected by the database engine with an IntegrityConstraint error."

### Q3: "How does the schema handle emergency vehicle prioritization?"
> **Answer:** "In our `Lane` entity, we included `Is_Emergency_Corridor NUMBER(1) DEFAULT 0 NOT NULL` with `CHECK (Is_Emergency_Corridor IN (0, 1))`. This allows our Review 2 stored procedure `proc_Emergency_Override` to clear green corridors dynamically."

### Q4: "How does your seed data represent realistic temporal patterns?"
> **Answer:** "Rather than uniform dummy rows, our 120 sensor telemetry entries are categorized across 4 distinct operational windows:
> 1. Morning Rush Hour (07:30 - 09:00, avg 48.8 cars/interval)
> 2. Midday Baseline (12:00 - 13:30, avg 24.2 cars/interval)
> 3. Evening Outbound Surge (17:30 - 19:15, avg 52.5 cars/interval)
> 4. Night Off-Peak (22:00 - 23:00, avg 5.7 cars/interval)."
