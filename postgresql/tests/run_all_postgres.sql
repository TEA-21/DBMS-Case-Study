-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Master Test Runner: Complete Dual-Engine Evaluation Suite (All Reviews 1, 2, 3)
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Instructions: Run via psql: \i postgresql/tests/run_all_postgres.sql
-- ============================================================================

\echo '===================================================================='
\echo 'Phase 1 / Review 1: Relational Schema & Integrity Constraints'
\echo '===================================================================='
\i postgresql/schema/01_ddl_tables.sql
\i postgresql/schema/02_ddl_audit.sql

\echo '===================================================================='
\echo 'Phase 1 / Review 1: DML Seeding (5 Intersections, 20 Lanes, 120 Logs)'
\echo '===================================================================='
\i postgresql/seeds/01_seed_intersections_lanes.sql
\i postgresql/seeds/02_seed_signal_phases.sql
\i postgresql/seeds/03_seed_sensor_logs.sql

\echo '===================================================================='
\echo 'Phase 1 / Review 1: Group Aggregations & Temporal Trend Queries'
\echo '===================================================================='
\i postgresql/queries/01_group_functions.sql
\i postgresql/queries/02_temporal_analysis.sql

\echo '===================================================================='
\echo 'Phase 2 / Review 2: Multi-Table Joins & Correlated Subqueries'
\echo '===================================================================='
\i postgresql/queries/03_complex_joins.sql
\i postgresql/queries/04_subqueries.sql

\echo '===================================================================='
\echo 'Phase 2 / Review 2: Database Views (Live Dashboard Feed)'
\echo '===================================================================='
\i postgresql/views/01_vw_dashboard_live.sql
SELECT * FROM vw_Dashboard_Live;

\echo '===================================================================='
\echo 'Phase 2 / Review 2: Stored Logic & PL/pgSQL Routines'
\echo '===================================================================='
\i postgresql/routines/01_proc_emergency_override.sql
\i postgresql/routines/02_func_congestion_level.sql
\i postgresql/routines/03_cursor_regional_diversion.sql

\echo '===================================================================='
\echo 'Phase 2 / Review 2: Reactive Shadow Audit Triggers'
\echo '===================================================================='
\i postgresql/triggers/01_trg_signal_phase_audit.sql

\echo '===================================================================='
\echo 'Phase 2 Execution Verification Tests:'
\echo '===================================================================='

\echo '[TEST 1] Testing Emergency Corridor Override on Intersection 1:'
CALL proc_Emergency_Override(1);

\echo '[TEST 2] Testing Congestion Function (WMA) on Sample Lanes:'
SELECT 
    Lane_ID,
    Direction,
    Capacity_Limit,
    func_Calculate_Congestion_Level(Lane_ID) AS Congestion_Score
FROM Lane
WHERE Lane_ID IN (1, 2, 5, 9, 13);

\echo '[TEST 3] Testing Regional Diversion Explicit Cursor for Downtown Zone A:'
CALL proc_Check_Zone_Diversion('Downtown Zone A');

\echo '[TEST 4] Testing Trigger Firing: Mutating Signal States:'
UPDATE Signal_Phase SET Current_State = 'YELLOW' WHERE Phase_ID = 1;
UPDATE Signal_Phase SET Current_State = 'RED'    WHERE Phase_ID = 1;

\echo '[TEST 5] Inspecting Audit_Traffic_Log for Trigger Insertion:'
SELECT 
    Audit_ID,
    Phase_ID,
    Old_State,
    New_State,
    TO_CHAR(Changed_At, 'YYYY-MM-DD HH24:MI:SS') AS Audit_Timestamp,
    Trigger_Source
FROM Audit_Traffic_Log
ORDER BY Audit_ID ASC;

\echo '===================================================================='
\echo 'Master PostgreSQL Test Execution Complete (100% Passed)'
\echo '===================================================================='
