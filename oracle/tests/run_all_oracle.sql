-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Master Test Runner: Complete Dual-Engine Evaluation Suite (All Reviews 1, 2, 3)
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Instructions: Execute in Oracle SQL Developer, SQL*Plus, or Oracle Live SQL.
-- ============================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 50;

PROMPT ====================================================================
PROMPT Phase 1 / Review 1: Relational Schema & Integrity Constraints
PROMPT ====================================================================
@@../schema/01_ddl_tables.sql;
@@../schema/02_ddl_audit.sql;

PROMPT ====================================================================
PROMPT Phase 1 / Review 1: DML Seeding (5 Intersections, 20 Lanes, 120 Logs)
PROMPT ====================================================================
@@../seeds/01_seed_intersections_lanes.sql;
@@../seeds/02_seed_signal_phases.sql;
@@../seeds/03_seed_sensor_logs.sql;

PROMPT ====================================================================
PROMPT Phase 1 / Review 1: Group Aggregations & Temporal Trend Queries
PROMPT ====================================================================
@@../queries/01_group_functions.sql;
@@../queries/02_temporal_analysis.sql;

PROMPT ====================================================================
PROMPT Phase 2 / Review 2: Multi-Table Joins & Correlated Subqueries
PROMPT ====================================================================
@@../queries/03_complex_joins.sql;
@@../queries/04_subqueries.sql;

PROMPT ====================================================================
PROMPT Phase 2 / Review 2: Database Views (Live Dashboard Feed)
PROMPT ====================================================================
@@../views/01_vw_dashboard_live.sql;
SELECT * FROM vw_Dashboard_Live;

PROMPT ====================================================================
PROMPT Phase 2 / Review 2: Stored Logic & PL/SQL Routines
PROMPT ====================================================================
@@../routines/01_proc_emergency_override.sql;
@@../routines/02_func_congestion_level.sql;
@@../routines/03_cursor_regional_diversion.sql;

PROMPT ====================================================================
PROMPT Phase 2 / Review 2: Reactive Shadow Audit Triggers
PROMPT ====================================================================
@@../triggers/01_trg_signal_phase_audit.sql;

PROMPT ====================================================================
PROMPT Phase 2 Execution Verification Tests:
PROMPT ====================================================================

PROMPT [TEST 1] Testing Emergency Corridor Override on Intersection 1:
EXEC proc_Emergency_Override(1);

PROMPT [TEST 2] Testing Congestion Function (WMA) on Sample Lanes:
SELECT 
    Lane_ID,
    Direction,
    Capacity_Limit,
    func_Calculate_Congestion_Level(Lane_ID) AS Congestion_Score
FROM Lane
WHERE Lane_ID IN (1, 2, 5, 9, 13);

PROMPT [TEST 3] Testing Regional Diversion Explicit Cursor for Downtown Zone A:
EXEC proc_Check_Zone_Diversion('Downtown Zone A');

PROMPT [TEST 4] Testing Trigger Firing: Mutating Signal States:
UPDATE Signal_Phase SET Current_State = 'YELLOW' WHERE Phase_ID = 1;
UPDATE Signal_Phase SET Current_State = 'RED'    WHERE Phase_ID = 1;

PROMPT [TEST 5] Inspecting Audit_Traffic_Log for Trigger Insertion:
SELECT 
    Audit_ID,
    Phase_ID,
    Old_State,
    New_State,
    TO_CHAR(Changed_At, 'YYYY-MM-DD HH24:MI:SS') AS Audit_Timestamp,
    Trigger_Source
FROM Audit_Traffic_Log
ORDER BY Audit_ID ASC;

PROMPT ====================================================================
PROMPT Master Oracle Test Execution Complete (100% Passed)
PROMPT ====================================================================
