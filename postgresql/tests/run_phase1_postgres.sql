-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Master Test Runner: Phase 1 (Review 1 Evaluation)
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Instructions: Run via psql: \i postgresql/tests/run_phase1_postgres.sql
-- ============================================================================

\echo '===================================================================='
\echo 'Step 1: Executing Schema DDL and Integrity Constraints'
\echo '===================================================================='
\i postgresql/schema/01_ddl_tables.sql
\i postgresql/schema/02_ddl_audit.sql

\echo '===================================================================='
\echo 'Step 2: Executing DML Seed Scripts (5 Intersections, 20 Lanes, 120 Logs)'
\echo '===================================================================='
\i postgresql/seeds/01_seed_intersections_lanes.sql
\i postgresql/seeds/02_seed_signal_phases.sql
\i postgresql/seeds/03_seed_sensor_logs.sql

\echo '===================================================================='
\echo 'Step 3: Executing Group Function Analytics (Volume per Intersection)'
\echo '===================================================================='
\i postgresql/queries/01_group_functions.sql

\echo '===================================================================='
\echo 'Step 4: Executing Temporal Analytics (Time of Day Date Extractions)'
\echo '===================================================================='
\i postgresql/queries/02_temporal_analysis.sql

\echo '===================================================================='
\echo 'Phase 1 Execution Complete.'
\echo '===================================================================='
