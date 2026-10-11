-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: DML Seed Data - Signal Phases
-- Dialect: Oracle Database (PL/SQL Compatible)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Seeding 20 Dedicated Signal Phases (1 per Lane)
-- States: 'GREEN', 'YELLOW', 'RED'
-- ----------------------------------------------------------------------------

-- Intersection 1: Central Plaza (Phase 1001-1004)
INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (1001, 101, 1, 'GREEN', 45, SYSTIMESTAMP - INTERVAL '2' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (1002, 102, 1, 'GREEN', 45, SYSTIMESTAMP - INTERVAL '2' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (1003, 103, 1, 'RED', 60, SYSTIMESTAMP - INTERVAL '2' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (1004, 104, 1, 'RED', 60, SYSTIMESTAMP - INTERVAL '2' MINUTE);

-- Intersection 2: Metro Parkway (Phase 2001-2004)
INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (2001, 201, 2, 'RED', 60, SYSTIMESTAMP - INTERVAL '1' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (2002, 202, 2, 'RED', 60, SYSTIMESTAMP - INTERVAL '1' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (2003, 203, 2, 'GREEN', 40, SYSTIMESTAMP - INTERVAL '1' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (2004, 204, 2, 'YELLOW', 10, SYSTIMESTAMP - INTERVAL '1' MINUTE);

-- Intersection 3: North Highland (Phase 3001-3004)
INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (3001, 301, 3, 'GREEN', 50, SYSTIMESTAMP - INTERVAL '3' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (3002, 302, 3, 'YELLOW', 10, SYSTIMESTAMP - INTERVAL '3' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (3003, 303, 3, 'RED', 55, SYSTIMESTAMP - INTERVAL '3' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (3004, 304, 3, 'RED', 55, SYSTIMESTAMP - INTERVAL '3' MINUTE);

-- Intersection 4: Harbor Boulevard (Phase 4001-4004)
INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (4001, 401, 4, 'RED', 50, SYSTIMESTAMP - INTERVAL '4' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (4002, 402, 4, 'RED', 50, SYSTIMESTAMP - INTERVAL '4' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (4003, 403, 4, 'GREEN', 60, SYSTIMESTAMP - INTERVAL '4' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (4004, 404, 4, 'GREEN', 60, SYSTIMESTAMP - INTERVAL '4' MINUTE);

-- Intersection 5: West Logistics Hub (Phase 5001-5004)
INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (5001, 501, 5, 'GREEN', 70, SYSTIMESTAMP - INTERVAL '5' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (5002, 502, 5, 'GREEN', 70, SYSTIMESTAMP - INTERVAL '5' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (5003, 503, 5, 'RED', 65, SYSTIMESTAMP - INTERVAL '5' MINUTE);

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated)
VALUES (5004, 504, 5, 'RED', 65, SYSTIMESTAMP - INTERVAL '5' MINUTE);

COMMIT;
