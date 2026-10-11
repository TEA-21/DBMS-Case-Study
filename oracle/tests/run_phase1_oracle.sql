-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Master Test Runner: Phase 1 (Review 1 Evaluation)
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Instructions: Run in Oracle SQL Developer, SQL*Plus, or Oracle Live SQL.
-- ============================================================================

SET SERVEROUTPUT ON;
SET FEEDBACK ON;

PROMPT ====================================================================
PROMPT Step 1: Executing Schema DDL and Integrity Constraints
PROMPT ====================================================================
@@../schema/01_ddl_tables.sql;
@@../schema/02_ddl_audit.sql;

PROMPT ====================================================================
PROMPT Step 2: Executing DML Seed Scripts (5 Intersections, 20 Lanes, 120 Logs)
PROMPT ====================================================================
@@../seeds/01_seed_intersections_lanes.sql;
@@../seeds/02_seed_signal_phases.sql;
@@../seeds/03_seed_sensor_logs.sql;

PROMPT ====================================================================
PROMPT Step 3: Executing Group Function Analytics (Volume per Intersection)
PROMPT ====================================================================
@@../queries/01_group_functions.sql;

PROMPT ====================================================================
PROMPT Step 4: Executing Temporal Analytics (Time of Day Date Extractions)
PROMPT ====================================================================
@@../queries/02_temporal_analysis.sql;

PROMPT ====================================================================
PROMPT Phase 1 Execution Complete.
PROMPT ====================================================================
