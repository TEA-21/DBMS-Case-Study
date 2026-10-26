-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Operational Database Views (React Dashboard Feed)
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Create a vw_Dashboard_Live view that abstracts complex joins.
--         This view acts as the data source for a hypothetical React UI,
--         showing only active green lights and their current lane volumes.
-- ============================================================================

CREATE OR REPLACE VIEW vw_Dashboard_Live AS
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    i.Grid_Zone,
    l.Lane_ID,
    l.Direction,
    l.Capacity_Limit,
    l.Is_Emergency_Corridor,
    sp.Phase_ID,
    sp.Current_State            AS Active_Light_Color,
    sp.Duration_Seconds         AS Green_Hold_Seconds,
    sp.Last_Updated             AS Phase_Activated_At,
    s.Log_ID                    AS Latest_Telemetry_ID,
    s.Car_Count                 AS Current_Lane_Volume,
    ROUND((s.Car_Count::numeric / l.Capacity_Limit) * 100, 2) AS Saturation_Pct,
    CASE 
        WHEN (s.Car_Count::numeric / l.Capacity_Limit) >= 0.80 THEN 'HEAVY_FLOW'
        WHEN (s.Car_Count::numeric / l.Capacity_Limit) >= 0.40 THEN 'NORMAL_FLOW'
        ELSE 'FREE_FLOW'
    END AS Flow_Classification
FROM Signal_Phase sp
JOIN Lane l 
    ON sp.Lane_ID = l.Lane_ID
JOIN Intersection i 
    ON sp.Intersection_ID = i.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
WHERE sp.Current_State = 'GREEN'
  AND s.Recorded_At = (
      SELECT MAX(s_sub.Recorded_At)
      FROM Sensor_Log s_sub
      WHERE s_sub.Lane_ID = l.Lane_ID
  );
