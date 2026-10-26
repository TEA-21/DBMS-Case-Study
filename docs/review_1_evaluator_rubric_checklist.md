# SmartFlow Grid: Review 1 Evaluator Rubric Checklist (10 Marks)

This checklist explicitly maps each rubric deliverable from **Review 1 Guidelines** in the PRD to the corresponding implementation files, line numbers, and verification proofs.

---

| Rubric Requirement | Marks Allocated | Project Implementation Details | File Location & Proof | Status |
| :--- | :---: | :--- | :--- | :---: |
| **Problem & Domain Analysis** | **2 Marks** | Comprehensive analysis of static light inefficiencies, urban delay metrics, dynamic sensor actuation, and emergency corridor routing. | [`docs/01_problem_and_domain_analysis.md`](file:///d:/Projects/DBMS%20Case%20Study/docs/01_problem_and_domain_analysis.md) | **100% Complete** |
| **Entities, Attributes & EER Diagram** | **2 Marks** | Extended ER Model in Chen notation matching institutional standards. Entities: `Intersection`, `Lane`, `Signal_Phase`, `Sensor_Log`, `Audit_Traffic_Log`. Attribute dictionary, PKs underlined, diamonds with $1:1$, $1:N$ cardinalities. | [`docs/02_entities_and_eer_specification.md`](file:///d:/Projects/DBMS%20Case%20Study/docs/02_entities_and_eer_specification.md)<br>Visual: [`docs/SmartFlow_Grid_EER_Diagram.png`](file:///d:/Projects/DBMS%20Case%20Study/docs/SmartFlow_Grid_EER_Diagram.png) | **100% Complete** |
| **DDL Implementation & Constraints** | **2 Marks** | Full SQL DDL with declarative constraints:<br>- PK/FK: Lanes to Intersections, Phases to Lanes/Intersections, Logs to Lanes.<br>- CHECK: `Signal_Phase.Current_State IN ('RED', 'YELLOW', 'GREEN')`.<br>- DEFAULT: `Car_Count = 0`, `Capacity_Limit > 0`. | Oracle: [`oracle/schema/01_ddl_tables.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/schema/01_ddl_tables.sql)<br>Postgres: [`postgresql/schema/01_ddl_tables.sql`](file:///d:/Projects/DBMS%20Case%20Study/postgresql/schema/01_ddl_tables.sql) | **100% Complete** |
| **DML Operations** | **2 Marks** | Robust seeding engine:<br>- 5 Intersections across 3 zones.<br>- 20 directional approach lanes.<br>- 20 initial lane-level signal phases.<br>- **120 sensor telemetry rows** (>100 required) spanning morning, midday, evening, and night windows. | Oracle: [`oracle/seeds/`](file:///d:/Projects/DBMS%20Case%20Study/oracle/seeds/)<br>Postgres: [`postgresql/seeds/`](file:///d:/Projects/DBMS%20Case%20Study/postgresql/seeds/) | **100% Complete** |
| **Operators & Single/Group Functions** | **2 Marks** | - Group Functions: `SUM`, `AVG`, `MAX`, `MIN`, `GROUP BY`, `HAVING` calculating average and peak traffic volume per junction.<br>- Single-Row Functions: `EXTRACT(HOUR FROM Recorded_At)`, `TO_CHAR` temporal grouping by rush-hour shifts. | Oracle: [`oracle/queries/`](file:///d:/Projects/DBMS%20Case%20Study/oracle/queries/)<br>Postgres: [`postgresql/queries/`](file:///d:/Projects/DBMS%20Case%20Study/postgresql/queries/) | **100% Complete** |

---

## Total Score Claimed: 10 / 10 Marks
All rubric requirements are implemented, cross-checked against database engines, and verifiable via automated test scripts.
