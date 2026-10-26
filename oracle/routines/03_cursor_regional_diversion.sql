-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Explicit Cursors — Regional Traffic Surveillance & Diversion
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Implement an explicit cursor within an anonymous block or procedure
--         that iterates through all lanes in a specific 'Grid Zone', aggregating
--         total vehicle load to determine if regional traffic diversion is necessary.
-- ============================================================================

CREATE OR REPLACE PROCEDURE proc_Check_Zone_Diversion (
    p_Grid_Zone IN VARCHAR2
)
IS
    -- Explicit Cursor Declaration: Iterates through each lane within the specified zone
    CURSOR cur_zone_lanes IS
        SELECT 
            i.Intersection_ID,
            i.Location_Name,
            l.Lane_ID,
            l.Direction,
            l.Capacity_Limit,
            NVL((
                SELECT s.Car_Count
                FROM Sensor_Log s
                WHERE s.Lane_ID = l.Lane_ID
                  AND s.Recorded_At = (
                      SELECT MAX(s2.Recorded_At)
                      FROM Sensor_Log s2
                      WHERE s2.Lane_ID = l.Lane_ID
                  )
            ), 0) AS Current_Load
        FROM Intersection i
        JOIN Lane l 
            ON i.Intersection_ID = l.Intersection_ID
        WHERE UPPER(i.Grid_Zone) = UPPER(p_Grid_Zone)
        ORDER BY i.Intersection_ID, l.Lane_ID;

    -- Record structure matching cursor signature
    r_lane                 cur_zone_lanes%ROWTYPE;

    -- Regional Accumulators & Metrics
    v_Total_Zone_Volume    NUMBER := 0;
    v_Total_Zone_Capacity  NUMBER := 0;
    v_Lane_Count           NUMBER := 0;
    v_Zone_Saturation_Pct  NUMBER := 0;
    v_Critical_Lanes_Count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('============================================================');
    DBMS_OUTPUT.PUT_LINE('  SMARTFLOW REGIONAL DIVERSION MONITOR: ZONE ' || UPPER(p_Grid_Zone));
    DBMS_OUTPUT.PUT_LINE('============================================================');

    -- Open Explicit Cursor
    OPEN cur_zone_lanes;

    LOOP
        FETCH cur_zone_lanes INTO r_lane;
        EXIT WHEN cur_zone_lanes%NOTFOUND;

        -- Accumulate totals
        v_Lane_Count          := cur_zone_lanes%ROWCOUNT;
        v_Total_Zone_Volume   := v_Total_Zone_Volume + r_lane.Current_Load;
        v_Total_Zone_Capacity := v_Total_Zone_Capacity + r_lane.Capacity_Limit;

        -- Check individual lane saturation
        IF (r_lane.Current_Load / r_lane.Capacity_Limit) >= 0.85 THEN
            v_Critical_Lanes_Count := v_Critical_Lanes_Count + 1;
            DBMS_OUTPUT.PUT_LINE('  [ALERT: BOTTLENECK] Lane ' || r_lane.Lane_ID || 
                                 ' (' || r_lane.Direction || ') at ' || r_lane.Location_Name || 
                                 ' -> Volume: ' || r_lane.Current_Load || '/' || r_lane.Capacity_Limit || 
                                 ' (' || ROUND((r_lane.Current_Load / r_lane.Capacity_Limit) * 100, 1) || '%)');
        END IF;
    END LOOP;

    -- Verify cursor evaluated records
    IF cur_zone_lanes%ISOPEN THEN
        CLOSE cur_zone_lanes;
    END IF;

    IF v_Lane_Count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  [INFO] No active lanes found in Grid Zone: ' || p_Grid_Zone);
        RETURN;
    END IF;

    v_Zone_Saturation_Pct := ROUND((v_Total_Zone_Volume / v_Total_Zone_Capacity) * 100, 2);

    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('  Total Monitored Lanes Evaluated : ' || v_Lane_Count);
    DBMS_OUTPUT.PUT_LINE('  Cumulative Regional Vehicle Load: ' || v_Total_Zone_Volume || ' vehicles');
    DBMS_OUTPUT.PUT_LINE('  Total Regional Network Capacity : ' || v_Total_Zone_Capacity || ' vehicles');
    DBMS_OUTPUT.PUT_LINE('  Regional Saturation Percentage  : ' || v_Zone_Saturation_Pct || '%');
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    -- Diversion Decision Logic:
    IF v_Zone_Saturation_Pct >= 80.0 OR v_Critical_Lanes_Count >= 2 THEN
        DBMS_OUTPUT.PUT_LINE('  *** ACTION REQUIRED: REGIONAL TRAFFIC DIVERSION MANDATED ***');
        DBMS_OUTPUT.PUT_LINE('  Rerouting ingress perimeter traffic away from Zone ' || UPPER(p_Grid_Zone));
        DBMS_OUTPUT.PUT_LINE('  Advisory signs activated. Dynamic routing protocols engaged.');
    ELSIF v_Zone_Saturation_Pct >= 60.0 THEN
        DBMS_OUTPUT.PUT_LINE('  *** ADVISORY: MODERATE CONGESTION DETECTED ***');
        DBMS_OUTPUT.PUT_LINE('  Recommend staggered green cycle extension for arterial corridors.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  [STATUS: NORMAL] Zone operating within safe capacity limits.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('============================================================');
EXCEPTION
    WHEN OTHERS THEN
        IF cur_zone_lanes%ISOPEN THEN
            CLOSE cur_zone_lanes;
        END IF;
        DBMS_OUTPUT.PUT_LINE('[ERROR] proc_Check_Zone_Diversion encountered error: ' || SQLERRM);
        RAISE;
END proc_Check_Zone_Diversion;
/

-- ----------------------------------------------------------------------------
-- Standalone Anonymous PL/SQL Block for Direct Script Testing:
-- ----------------------------------------------------------------------------
SET SERVEROUTPUT ON;
DECLARE
    v_Target_Zone VARCHAR2(50) := 'Downtown Zone A';
BEGIN
    proc_Check_Zone_Diversion(v_Target_Zone);
    proc_Check_Zone_Diversion('Uptown Zone B');
END;
/
