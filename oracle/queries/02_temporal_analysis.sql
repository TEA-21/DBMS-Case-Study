-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Single-Row Functions & Temporal Analytics (Time-of-Day Traffic)
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Use single-row functions (date extraction) to analyze traffic by time of day.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 2.1: Hourly Breakdown via Date Extraction Single-Row Functions
-- Uses EXTRACT(HOUR FROM ...) to partition vehicular telemetry by hour.
-- ----------------------------------------------------------------------------
SELECT 
    EXTRACT(HOUR FROM s.Recorded_At) AS Hour_Of_Day,
    COUNT(s.Log_ID)                  AS Logs_Recorded,
    SUM(s.Car_Count)                 AS Total_Vehicles_Hour,
    ROUND(AVG(s.Car_Count), 2)       AS Avg_Vehicles_Hour,
    MAX(s.Car_Count)                 AS Max_Vehicles_Hour
FROM Sensor_Log s
GROUP BY 
    EXTRACT(HOUR FROM s.Recorded_At)
ORDER BY 
    Hour_Of_Day ASC;

-- ----------------------------------------------------------------------------
-- Query 2.2: Time-of-Day Period Classification (CASE + String/Date Formatting)
-- Uses TO_CHAR(Recorded_At, 'HH24:MI') and single-row string manipulation to
-- classify telemetry into operational shifts (Morning Peak, Midday, Evening Peak, Night).
-- ----------------------------------------------------------------------------
SELECT 
    s.Log_ID,
    s.Lane_ID,
    s.Car_Count,
    TO_CHAR(s.Recorded_At, 'YYYY-MM-DD HH24:MI:SS') AS Formatted_Timestamp,
    TO_CHAR(s.Recorded_At, 'HH24:MI')               AS Military_Time,
    CASE 
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 7 AND 9 THEN 'MORNING_RUSH'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 12 AND 14 THEN 'MIDDAY_BASELINE'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 17 AND 19 THEN 'EVENING_PEAK'
        ELSE 'NIGHT_LULL'
    END AS Time_Period_Classification
FROM Sensor_Log s
WHERE s.Log_ID BETWEEN 1001 AND 1025
ORDER BY s.Recorded_At ASC;

-- ----------------------------------------------------------------------------
-- Query 2.3: Period-Aggregated Performance Matrix
-- Summarizes overall load across the temporal classifications.
-- ----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 7 AND 9 THEN 'Morning Rush (07:00 - 10:00)'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 12 AND 14 THEN 'Midday Baseline (12:00 - 15:00)'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 17 AND 19 THEN 'Evening Peak (17:00 - 20:00)'
        ELSE 'Night Off-Peak (20:00 - 06:00)'
    END AS Day_Period,
    COUNT(s.Log_ID)            AS Sample_Count,
    SUM(s.Car_Count)           AS Total_Vehicular_Traffic,
    ROUND(AVG(s.Car_Count), 2) AS Average_Car_Density
FROM Sensor_Log s
GROUP BY 
    CASE 
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 7 AND 9 THEN 'Morning Rush (07:00 - 10:00)'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 12 AND 14 THEN 'Midday Baseline (12:00 - 15:00)'
        WHEN EXTRACT(HOUR FROM s.Recorded_At) BETWEEN 17 AND 19 THEN 'Evening Peak (17:00 - 20:00)'
        ELSE 'Night Off-Peak (20:00 - 06:00)'
    END
ORDER BY 
    Total_Vehicular_Traffic DESC;
