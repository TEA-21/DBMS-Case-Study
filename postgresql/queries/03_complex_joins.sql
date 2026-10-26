-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Complex Multi-Table Joins (Density & Topology Matrix)
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Query combining Intersection, Lane, and Sensor_Log to output
--         a full matrix of current traffic density per physical node.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 3.1: 3-Way Join — Full Traffic Density Matrix per Physical Node
-- ----------------------------------------------------------------------------
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    i.Grid_Zone,
    l.Lane_ID,
    l.Direction,
    l.Capacity_Limit,
    l.Is_Emergency_Corridor,
    s.Log_ID,
    s.Car_Count                     AS Current_Car_Count,
    s.Recorded_At,
    ROUND((s.Car_Count::numeric / l.Capacity_Limit) * 100, 2) AS Utilization_Percentage,
    CASE 
        WHEN (s.Car_Count::numeric / l.Capacity_Limit) >= 0.85 THEN 'CRITICAL'
        WHEN (s.Car_Count::numeric / l.Capacity_Limit) >= 0.60 THEN 'MODERATE'
        ELSE 'OPTIMAL'
    END AS Congestion_State
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
WHERE s.Recorded_At = (
    SELECT MAX(s2.Recorded_At)
    FROM Sensor_Log s2
    WHERE s2.Lane_ID = l.Lane_ID
)
ORDER BY 
    i.Intersection_ID ASC, 
    l.Lane_ID ASC;

-- ----------------------------------------------------------------------------
-- Query 3.2: 4-Way Join — Complete Operational Topology Matrix
-- ----------------------------------------------------------------------------
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    l.Lane_ID,
    l.Direction,
    l.Capacity_Limit,
    sp.Phase_ID,
    sp.Current_State                AS Active_Signal_State,
    sp.Duration_Seconds             AS Phase_Duration,
    s.Car_Count                     AS Active_Queue_Length,
    ROUND((s.Car_Count::numeric / l.Capacity_Limit) * 100, 2) AS Capacity_Saturation_Pct
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Signal_Phase sp 
    ON l.Lane_ID = sp.Lane_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
WHERE s.Recorded_At = (
    SELECT MAX(s_sub.Recorded_At)
    FROM Sensor_Log s_sub
    WHERE s_sub.Lane_ID = l.Lane_ID
)
ORDER BY 
    sp.Current_State DESC,
    Capacity_Saturation_Pct DESC;
