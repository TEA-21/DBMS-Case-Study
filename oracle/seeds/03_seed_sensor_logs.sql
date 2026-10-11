-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: DML Seed Data - Sensor Telemetry Logs (120 Rows)
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Time Windows:
--   - Morning Peak:   07:30 to 09:00
--   - Midday Baseline: 12:00 to 13:30
--   - Evening Peak:   17:30 to 19:00
--   - Night Lull:     22:00 to 23:00
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Window 1: Morning Rush Hour (07:30 - 09:00) - Heavy Inbound Traffic
-- ----------------------------------------------------------------------------
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1001, 101, 48, TO_TIMESTAMP('2026-10-11 07:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1002, 102, 52, TO_TIMESTAMP('2026-10-11 07:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1003, 103, 38, TO_TIMESTAMP('2026-10-11 07:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1004, 104, 35, TO_TIMESTAMP('2026-10-11 07:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1005, 201, 44, TO_TIMESTAMP('2026-10-11 07:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1006, 202, 49, TO_TIMESTAMP('2026-10-11 07:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1007, 203, 29, TO_TIMESTAMP('2026-10-11 07:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1008, 204, 31, TO_TIMESTAMP('2026-10-11 07:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1009, 301, 42, TO_TIMESTAMP('2026-10-11 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1010, 302, 39, TO_TIMESTAMP('2026-10-11 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1011, 303, 62, TO_TIMESTAMP('2026-10-11 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1012, 304, 58, TO_TIMESTAMP('2026-10-11 08:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1013, 401, 32, TO_TIMESTAMP('2026-10-11 08:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1014, 402, 35, TO_TIMESTAMP('2026-10-11 08:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1015, 403, 55, TO_TIMESTAMP('2026-10-11 08:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1016, 404, 50, TO_TIMESTAMP('2026-10-11 08:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1017, 501, 68, TO_TIMESTAMP('2026-10-11 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1018, 502, 72, TO_TIMESTAMP('2026-10-11 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1019, 503, 61, TO_TIMESTAMP('2026-10-11 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1020, 504, 59, TO_TIMESTAMP('2026-10-11 08:30:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Second morning sweep (Peak 08:45)
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1021, 101, 55, TO_TIMESTAMP('2026-10-11 08:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1022, 102, 58, TO_TIMESTAMP('2026-10-11 08:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1023, 103, 46, TO_TIMESTAMP('2026-10-11 08:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1024, 104, 44, TO_TIMESTAMP('2026-10-11 08:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1025, 201, 51, TO_TIMESTAMP('2026-10-11 08:50:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1026, 202, 53, TO_TIMESTAMP('2026-10-11 08:50:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1027, 203, 38, TO_TIMESTAMP('2026-10-11 08:50:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1028, 204, 37, TO_TIMESTAMP('2026-10-11 08:50:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1029, 301, 47, TO_TIMESTAMP('2026-10-11 08:55:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1030, 302, 45, TO_TIMESTAMP('2026-10-11 08:55:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1031, 303, 66, TO_TIMESTAMP('2026-10-11 08:55:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1032, 304, 64, TO_TIMESTAMP('2026-10-11 08:55:00', 'YYYY-MM-DD HH24:MI:SS'));

-- ----------------------------------------------------------------------------
-- Window 2: Midday Baseline (12:00 - 13:30) - Moderate Steady Flow
-- ----------------------------------------------------------------------------
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1033, 101, 24, TO_TIMESTAMP('2026-10-11 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1034, 102, 22, TO_TIMESTAMP('2026-10-11 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1035, 103, 20, TO_TIMESTAMP('2026-10-11 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1036, 104, 19, TO_TIMESTAMP('2026-10-11 12:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1037, 201, 25, TO_TIMESTAMP('2026-10-11 12:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1038, 202, 23, TO_TIMESTAMP('2026-10-11 12:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1039, 203, 18, TO_TIMESTAMP('2026-10-11 12:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1040, 204, 17, TO_TIMESTAMP('2026-10-11 12:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1041, 301, 21, TO_TIMESTAMP('2026-10-11 12:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1042, 302, 20, TO_TIMESTAMP('2026-10-11 12:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1043, 303, 32, TO_TIMESTAMP('2026-10-11 12:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1044, 304, 30, TO_TIMESTAMP('2026-10-11 12:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1045, 401, 15, TO_TIMESTAMP('2026-10-11 12:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1046, 402, 16, TO_TIMESTAMP('2026-10-11 12:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1047, 403, 28, TO_TIMESTAMP('2026-10-11 12:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1048, 404, 27, TO_TIMESTAMP('2026-10-11 12:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1049, 501, 35, TO_TIMESTAMP('2026-10-11 13:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1050, 502, 38, TO_TIMESTAMP('2026-10-11 13:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1051, 503, 31, TO_TIMESTAMP('2026-10-11 13:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1052, 504, 30, TO_TIMESTAMP('2026-10-11 13:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1053, 101, 26, TO_TIMESTAMP('2026-10-11 13:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1054, 102, 25, TO_TIMESTAMP('2026-10-11 13:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1055, 103, 22, TO_TIMESTAMP('2026-10-11 13:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1056, 104, 21, TO_TIMESTAMP('2026-10-11 13:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1057, 201, 27, TO_TIMESTAMP('2026-10-11 13:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1058, 202, 28, TO_TIMESTAMP('2026-10-11 13:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1059, 203, 20, TO_TIMESTAMP('2026-10-11 13:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1060, 204, 19, TO_TIMESTAMP('2026-10-11 13:30:00', 'YYYY-MM-DD HH24:MI:SS'));

-- ----------------------------------------------------------------------------
-- Window 3: Evening Rush Hour (17:30 - 19:15) - Heavy Outbound Surge
-- ----------------------------------------------------------------------------
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1061, 101, 56, TO_TIMESTAMP('2026-10-11 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1062, 102, 59, TO_TIMESTAMP('2026-10-11 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1063, 103, 47, TO_TIMESTAMP('2026-10-11 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1064, 104, 49, TO_TIMESTAMP('2026-10-11 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1065, 201, 50, TO_TIMESTAMP('2026-10-11 17:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1066, 202, 54, TO_TIMESTAMP('2026-10-11 17:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1067, 203, 43, TO_TIMESTAMP('2026-10-11 17:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1068, 204, 42, TO_TIMESTAMP('2026-10-11 17:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1069, 301, 48, TO_TIMESTAMP('2026-10-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1070, 302, 46, TO_TIMESTAMP('2026-10-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1071, 303, 68, TO_TIMESTAMP('2026-10-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1072, 304, 67, TO_TIMESTAMP('2026-10-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1073, 401, 38, TO_TIMESTAMP('2026-10-11 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1074, 402, 39, TO_TIMESTAMP('2026-10-11 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1075, 403, 63, TO_TIMESTAMP('2026-10-11 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1076, 404, 61, TO_TIMESTAMP('2026-10-11 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1077, 501, 76, TO_TIMESTAMP('2026-10-11 18:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1078, 502, 79, TO_TIMESTAMP('2026-10-11 18:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1079, 503, 71, TO_TIMESTAMP('2026-10-11 18:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1080, 504, 70, TO_TIMESTAMP('2026-10-11 18:30:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Evening Peak Continuous (18:45)
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1081, 101, 57, TO_TIMESTAMP('2026-10-11 18:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1082, 102, 59, TO_TIMESTAMP('2026-10-11 18:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1083, 103, 48, TO_TIMESTAMP('2026-10-11 18:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1084, 104, 47, TO_TIMESTAMP('2026-10-11 18:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1085, 201, 52, TO_TIMESTAMP('2026-10-11 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1086, 202, 53, TO_TIMESTAMP('2026-10-11 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1087, 203, 41, TO_TIMESTAMP('2026-10-11 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1088, 204, 40, TO_TIMESTAMP('2026-10-11 19:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1089, 301, 49, TO_TIMESTAMP('2026-10-11 19:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1090, 302, 47, TO_TIMESTAMP('2026-10-11 19:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1091, 303, 67, TO_TIMESTAMP('2026-10-11 19:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1092, 304, 66, TO_TIMESTAMP('2026-10-11 19:15:00', 'YYYY-MM-DD HH24:MI:SS'));

-- ----------------------------------------------------------------------------
-- Window 4: Night Lull (22:00 - 23:00) - Sparse Residual Load
-- ----------------------------------------------------------------------------
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1093, 101, 6, TO_TIMESTAMP('2026-10-11 22:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1094, 102, 5, TO_TIMESTAMP('2026-10-11 22:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1095, 103, 4, TO_TIMESTAMP('2026-10-11 22:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1096, 104, 3, TO_TIMESTAMP('2026-10-11 22:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1097, 201, 7, TO_TIMESTAMP('2026-10-11 22:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1098, 202, 6, TO_TIMESTAMP('2026-10-11 22:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1099, 203, 3, TO_TIMESTAMP('2026-10-11 22:15:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1100, 204, 2, TO_TIMESTAMP('2026-10-11 22:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1101, 301, 5, TO_TIMESTAMP('2026-10-11 22:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1102, 302, 4, TO_TIMESTAMP('2026-10-11 22:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1103, 303, 8, TO_TIMESTAMP('2026-10-11 22:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1104, 304, 7, TO_TIMESTAMP('2026-10-11 22:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1105, 401, 3, TO_TIMESTAMP('2026-10-11 22:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1106, 402, 2, TO_TIMESTAMP('2026-10-11 22:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1107, 403, 5, TO_TIMESTAMP('2026-10-11 22:45:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1108, 404, 4, TO_TIMESTAMP('2026-10-11 22:45:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1109, 501, 12, TO_TIMESTAMP('2026-10-11 23:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1110, 502, 11, TO_TIMESTAMP('2026-10-11 23:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1111, 503, 9, TO_TIMESTAMP('2026-10-11 23:00:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1112, 504, 8, TO_TIMESTAMP('2026-10-11 23:00:00', 'YYYY-MM-DD HH24:MI:SS'));

-- Additional readings ensuring exact recent window for WMA function tests
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1113, 101, 54, TO_TIMESTAMP('2026-10-11 19:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1114, 101, 57, TO_TIMESTAMP('2026-10-11 19:35:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1115, 101, 58, TO_TIMESTAMP('2026-10-11 19:40:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1116, 202, 50, TO_TIMESTAMP('2026-10-11 19:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1117, 202, 52, TO_TIMESTAMP('2026-10-11 19:35:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1118, 202, 54, TO_TIMESTAMP('2026-10-11 19:40:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1119, 401, 12, TO_TIMESTAMP('2026-10-11 19:30:00', 'YYYY-MM-DD HH24:MI:SS'));
INSERT INTO Sensor_Log (Log_ID, Lane_ID, Car_Count, Recorded_At)
VALUES (1120, 401, 10, TO_TIMESTAMP('2026-10-11 19:35:00', 'YYYY-MM-DD HH24:MI:SS'));

COMMIT;
