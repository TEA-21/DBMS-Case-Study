-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: DML Seed Data - Signal Phases
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- ============================================================================

INSERT INTO Signal_Phase (Phase_ID, Lane_ID, Intersection_ID, Current_State, Duration_Seconds, Last_Updated) VALUES
-- Intersection 1: Central Plaza
(1001, 101, 1, 'GREEN', 45, NOW() - INTERVAL '2 minute'),
(1002, 102, 1, 'GREEN', 45, NOW() - INTERVAL '2 minute'),
(1003, 103, 1, 'RED', 60, NOW() - INTERVAL '2 minute'),
(1004, 104, 1, 'RED', 60, NOW() - INTERVAL '2 minute'),

-- Intersection 2: Metro Parkway
(2001, 201, 2, 'RED', 60, NOW() - INTERVAL '1 minute'),
(2002, 202, 2, 'RED', 60, NOW() - INTERVAL '1 minute'),
(2003, 203, 2, 'GREEN', 40, NOW() - INTERVAL '1 minute'),
(2004, 204, 2, 'YELLOW', 10, NOW() - INTERVAL '1 minute'),

-- Intersection 3: North Highland
(3001, 301, 3, 'GREEN', 50, NOW() - INTERVAL '3 minute'),
(3002, 302, 3, 'YELLOW', 10, NOW() - INTERVAL '3 minute'),
(3003, 303, 3, 'RED', 55, NOW() - INTERVAL '3 minute'),
(3004, 304, 3, 'RED', 55, NOW() - INTERVAL '3 minute'),

-- Intersection 4: Harbor Boulevard
(4001, 401, 4, 'RED', 50, NOW() - INTERVAL '4 minute'),
(4002, 402, 4, 'RED', 50, NOW() - INTERVAL '4 minute'),
(4003, 403, 4, 'GREEN', 60, NOW() - INTERVAL '4 minute'),
(4004, 404, 4, 'GREEN', 60, NOW() - INTERVAL '4 minute'),

-- Intersection 5: West Logistics Hub
(5001, 501, 5, 'GREEN', 70, NOW() - INTERVAL '5 minute'),
(5002, 502, 5, 'GREEN', 70, NOW() - INTERVAL '5 minute'),
(5003, 503, 5, 'RED', 65, NOW() - INTERVAL '5 minute'),
(5004, 504, 5, 'RED', 65, NOW() - INTERVAL '5 minute');
