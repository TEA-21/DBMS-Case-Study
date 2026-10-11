-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Operators & Group Functions (Aggregation Analytics)
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Use group functions (SUM, AVG, GROUP BY) to calculate average traffic
--         volume per intersection and zone.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 1.1: Average, Total, and Peak Traffic Volume per Intersection
-- Evaluates overall load per junction node across all historical logs.
-- ----------------------------------------------------------------------------
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    i.Grid_Zone,
    COUNT(s.Log_ID)             AS Total_Sensor_Readings,
    SUM(s.Car_Count)            AS Cumulative_Vehicle_Count,
    ROUND(AVG(s.Car_Count), 2)  AS Avg_Vehicles_Per_Interval,
    MAX(s.Car_Count)            AS Peak_Recorded_Vehicles,
    MIN(s.Car_Count)            AS Minimum_Recorded_Vehicles
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
GROUP BY 
    i.Intersection_ID, 
    i.Location_Name, 
    i.Grid_Zone
ORDER BY 
    Avg_Vehicles_Per_Interval DESC;

-- ----------------------------------------------------------------------------
-- Query 1.2: Regional Grid Zone Density Summary
-- Aggregates vehicular load grouped by metropolitan surveillance zone.
-- ----------------------------------------------------------------------------
SELECT 
    i.Grid_Zone,
    COUNT(DISTINCT i.Intersection_ID) AS Active_Intersections,
    COUNT(DISTINCT l.Lane_ID)         AS Monitored_Lanes,
    SUM(s.Car_Count)                  AS Regional_Volume_Sum,
    ROUND(AVG(s.Car_Count), 2)        AS Regional_Avg_Lane_Load,
    MAX(s.Car_Count)                  AS Highest_Observed_Spike
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
GROUP BY 
    i.Grid_Zone
ORDER BY 
    Regional_Volume_Sum DESC;

-- ----------------------------------------------------------------------------
-- Query 1.3: High-Congestion Nodes (HAVING Clause Filtering)
-- Identifies intersections where average vehicular interval count exceeds 35 cars.
-- ----------------------------------------------------------------------------
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    COUNT(s.Log_ID)             AS Reading_Count,
    ROUND(AVG(s.Car_Count), 2)  AS High_Average_Load
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
GROUP BY 
    i.Intersection_ID, 
    i.Location_Name
HAVING 
    AVG(s.Car_Count) > 35.0
ORDER BY 
    High_Average_Load DESC;
