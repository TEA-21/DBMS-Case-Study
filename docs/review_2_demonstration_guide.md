# SmartFlow Grid: Review 2 Demonstration & Evaluation Guide

This document is specifically tailored for **Review 2 Presentation & Evaluation (10 Marks)**. It provides a structured agenda, step-by-step demonstration walkthrough, and direct answers to anticipated evaluator questions.

---

## 1. Review 2 Agenda & Presentation Flow (8-12 Minutes)

| Time | Agenda Item | Key Talking Points | Reference Artifacts |
| :--- | :--- | :--- | :--- |
| **0:00 - 2:00** | Architectural Progression from Review 1 | Progression from static DDL/DML to server-side automation, transactional integrity, and PL/SQL extensions. | [`PLAN.md`](file:///d:/Projects/DBMS%20Case%20Study/PLAN.md) |
| **2:00 - 4:00** | Multi-Table Density Joins & Subqueries | 3-way/4-way joins calculating node saturation; correlated subqueries isolating volume spikes exceeding historical baselines. | [`oracle/queries/03_complex_joins.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/queries/03_complex_joins.sql)<br>[`oracle/queries/04_subqueries.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/queries/04_subqueries.sql) |
| **4:00 - 6:00** | Operational Dashboard View (`vw_Dashboard_Live`) | Abstraction of complex joins for hypothetical React UI; real-time projection of active green lights and live queue volume. | [`oracle/views/01_vw_dashboard_live.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/views/01_vw_dashboard_live.sql) |
| **6:00 - 8:00** | Stored Procedure & Emergency Clearance | `proc_Emergency_Override`: automated corridor detection, locking non-emergency phases to RED, clearing emergency lane to GREEN. | [`oracle/routines/01_proc_emergency_override.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/routines/01_proc_emergency_override.sql) |
| **8:00 - 10:00** | WMA Congestion Function & Regional Cursor | `func_Calculate_Congestion_Level`: 5-reading weighted moving average ($5, 4, 3, 2, 1$); `proc_Check_Zone_Diversion`: explicit cursor (%FOUND, %NOTFOUND). | [`oracle/routines/02_func_congestion_level.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/routines/02_func_congestion_level.sql)<br>[`oracle/routines/03_cursor_regional_diversion.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/routines/03_cursor_regional_diversion.sql) |
| **10:00 - 12:00** | Shadow Audit Trigger & Verification | `trg_Signal_Phase_Audit`: autonomous AFTER UPDATE trigger populating `Audit_Traffic_Log`. Live inspection of audit records. | [`oracle/triggers/01_trg_signal_phase_audit.sql`](file:///d:/Projects/DBMS%20Case%20Study/oracle/triggers/01_trg_signal_phase_audit.sql) |

---

## 2. Step-by-Step Live Demonstration Script

### Method A: One-Click Desktop Evaluation Showcase (Recommended)
1. Double-click [`run_gui.bat`](file:///d:/Projects/DBMS%20Case%20Study/run_gui.bat) or execute:
   ```bash
   python scripts/review_1_showcase.py
   ```
2. **Tab 1: Live Execution Stream:**
   - Click **"Run Automated Evaluation Suite"**.
   - Watch all 10 automated test gates execute with soft green `[PASS]` badges and detailed performance metrics.
3. **Tab 2: Interactive SQL & PL/SQL Explorer:**
   - Click **"3-Way Density Joins"** to inspect node saturation.
   - Click **"Live Dashboard View"** to verify green light filtering.
   - Click **"Trigger Emergency Override"** to watch conflicting phases lock to RED while Lane 4 clears to GREEN.
   - Click **"Calculate Congestion (WMA)"** to see mathematical classification across lanes.
   - Click **"Run Zone Diversion Cursor"** to observe explicit cursor logging.
   - Click **"Simulate Light Mutation & Inspect Audit Log"** to prove the trigger fires and writes into `Audit_Traffic_Log`.
4. **Tab 3: Academic ER Diagram:**
   - Zoom and inspect the full Chen diagram with cardinalities.
5. **Tab 4: Academic Report & BCNF Proofs:**
   - Review the complete 6-chapter report and formal 1NF $\rightarrow$ BCNF mathematical proofs.

### Method B: Database CLI Execution
- **In Oracle SQL Developer / SQL\*Plus:**
  ```sql
  @oracle/tests/run_all_oracle.sql
  ```
- **In PostgreSQL `psql`:**
  ```sql
  \i postgresql/tests/run_all_postgres.sql
  ```

---

## 3. Anticipated Viva/Evaluation Questions & Ready Answers

### Q1: "Why compute congestion level via Weighted Moving Average (WMA) instead of a simple arithmetic mean?"
> **Answer:** "A simple arithmetic mean treats a reading from 30 minutes ago with the same importance as a reading taken 30 seconds ago. In real-time IoT traffic management, recent telemetry reflects immediate queue formation. Using descending weights ($w = [5, 4, 3, 2, 1]$), the function biases heavily toward current flow while damping transient single-car anomalies."

### Q2: "How does `proc_Emergency_Override` guarantee collision safety at the intersection?"
> **Answer:** "The procedure executes within an atomic transaction. Before clearing the designated emergency corridor to `'GREEN'`, it updates all conflicting directional approach phases at that intersection to `'RED'` with an extended hold duration (90 seconds). Because both updates occur within the same transaction block, no intermediate invalid state can be visible."

### Q3: "Why is the shadow audit implemented as a database trigger rather than inside application code?"
> **Answer:** "Application-level logging is vulnerable: if an external application crashes, or if an administrator runs manual SQL updates in SQL Developer, application logs miss the change. An `AFTER UPDATE` database-level trigger is guaranteed to fire regardless of the connection source, creating a legally defensible, tamper-resistant audit trail."

### Q4: "Why use an explicit cursor in `proc_Check_Zone_Diversion` instead of a simple `SELECT SUM(...)`?"
> **Answer:** "An explicit cursor allows row-by-row procedural evaluation using attributes like `%OPEN`, `%FOUND`, `%NOTFOUND`, and `%ROWCOUNT`. This enables the procedure to detect not just the cumulative zone volume, but also pinpoint localized bottlenecks on individual lanes during iteration and emit targeted `DBMS_OUTPUT` alerts."
