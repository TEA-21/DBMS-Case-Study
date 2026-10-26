-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Advanced Subqueries (Capacity & Outlier Analytics)
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Identify the specific intersections where the current Car_Count
--         exceeds the historical average capacity.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 4.1: Intersections Exceeding Historical Network-Wide Average Volume
-- ----------------------------------------------------------------------------
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    i.Grid_Zone,
    SUM(s.Car_Count) AS Current_Intersection_Volume
FROM Intersection i
JOIN Lane l 
    ON i.Intersection_ID = l.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
WHERE s.Recorded_At = (
    SELECT MAX(s_latest.Recorded_At)
    FROM Sensor_Log s_latest
    WHERE s_latest.Lane_ID = l.Lane_ID
)
GROUP BY 
    i.Intersection_ID, 
    i.Location_Name, 
    i.Grid_Zone
HAVING SUM(s.Car_Count) > (
    SELECT AVG(Node_Total)
    FROM (
        SELECT 
            l_sub.Intersection_ID,
            SUM(s_sub.Car_Count) AS Node_Total
        FROM Lane l_sub
        JOIN Sensor_Log s_sub 
            ON l_sub.Lane_ID = s_sub.Lane_ID
        GROUP BY 
            l_sub.Intersection_ID, 
            s_sub.Recorded_At
    ) hist
)
ORDER BY 
    Current_Intersection_Volume DESC;

-- ----------------------------------------------------------------------------
-- Query 4.2: Correlated Subquery — Lanes Exceeding Own Historical Average
-- ----------------------------------------------------------------------------
SELECT 
    l.Lane_ID,
    l.Intersection_ID,
    i.Location_Name,
    l.Direction,
    l.Capacity_Limit,
    s_curr.Car_Count AS Current_Volume,
    ROUND((
        SELECT AVG(s_hist.Car_Count)
        FROM Sensor_Log s_hist
        WHERE s_hist.Lane_ID = l.Lane_ID
    ), 2) AS Historical_Avg_Volume,
    ROUND(s_curr.Car_Count - (
        SELECT AVG(s_hist.Car_Count)
        FROM Sensor_Log s_hist
        WHERE s_hist.Lane_ID = l.Lane_ID
    ), 2) AS Excess_Surge_Count
FROM Lane l
JOIN Intersection i 
    ON l.Intersection_ID = i.Intersection_ID
JOIN Sensor_Log s_curr 
    ON l.Lane_ID = s_curr.Lane_ID
WHERE s_curr.Recorded_At = (
    SELECT MAX(s_rec.Recorded_At)
    FROM Sensor_Log s_rec
    WHERE s_rec.Lane_ID = l.Lane_ID
)
AND s_curr.Car_Count > (
    SELECT AVG(s_avg.Car_Count)
    FROM Sensor_Log s_avg
    WHERE s_avg.Lane_ID = l.Lane_ID
)
ORDER BY 
    Excess_Surge_Count DESC;

-- ----------------------------------------------------------------------------
-- Query 4.3: High-Priority Emergency Corridors Operating Near Saturation
-- ----------------------------------------------------------------------------
SELECT 
    l.Lane_ID,
    i.Location_Name,
    l.Direction,
    s.Car_Count AS Active_Volume,
    l.Capacity_Limit,
    ROUND((s.Car_Count::numeric / l.Capacity_Limit) * 100, 2) AS Saturation_Pct
FROM Lane l
JOIN Intersection i 
    ON l.Intersection_ID = i.Intersection_ID
JOIN Sensor_Log s 
    ON l.Lane_ID = s.Lane_ID
WHERE l.Is_Emergency_Corridor = 1
  AND s.Recorded_At = (
      SELECT MAX(s2.Recorded_At)
      FROM Sensor_Log s2
      WHERE s2.Lane_ID = l.Lane_ID
  )
  AND (s.Car_Count::numeric / l.Capacity_Limit) > 0.50
ORDER BY 
    Saturation_Pct DESC;
