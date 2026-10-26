-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Explicit Cursors — Regional Traffic Surveillance & Diversion
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Implement an explicit cursor within an anonymous block or procedure
--         that iterates through all lanes in a specific 'Grid Zone', aggregating
--         total vehicle load to determine if regional traffic diversion is necessary.
-- ============================================================================

CREATE OR REPLACE PROCEDURE proc_Check_Zone_Diversion (
    p_Grid_Zone VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    -- Explicit Cursor Declaration
    cur_zone_lanes CURSOR FOR
        SELECT 
            i.Intersection_ID,
            i.Location_Name,
            l.Lane_ID,
            l.Direction,
            l.Capacity_Limit,
            COALESCE((
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

    r_lane                 RECORD;
    v_Total_Zone_Volume    INTEGER := 0;
    v_Total_Zone_Capacity  INTEGER := 0;
    v_Lane_Count           INTEGER := 0;
    v_Zone_Saturation_Pct  NUMERIC := 0;
    v_Critical_Lanes_Count INTEGER := 0;
BEGIN
    RAISE NOTICE '============================================================';
    RAISE NOTICE '  SMARTFLOW REGIONAL DIVERSION MONITOR: ZONE %', UPPER(p_Grid_Zone);
    RAISE NOTICE '============================================================';

    -- Open Explicit Cursor
    OPEN cur_zone_lanes;

    LOOP
        FETCH cur_zone_lanes INTO r_lane;
        EXIT WHEN NOT FOUND;

        v_Lane_Count          := v_Lane_Count + 1;
        v_Total_Zone_Volume   := v_Total_Zone_Volume + r_lane.Current_Load;
        v_Total_Zone_Capacity := v_Total_Zone_Capacity + r_lane.Capacity_Limit;

        IF (r_lane.Current_Load::numeric / r_lane.Capacity_Limit) >= 0.85 THEN
            v_Critical_Lanes_Count := v_Critical_Lanes_Count + 1;
            RAISE NOTICE '  [ALERT: BOTTLENECK] Lane % (%) at % -> Volume: %/% (%%)',
                r_lane.Lane_ID, r_lane.Direction, r_lane.Location_Name,
                r_lane.Current_Load, r_lane.Capacity_Limit,
                ROUND((r_lane.Current_Load::numeric / r_lane.Capacity_Limit) * 100, 1);
        END IF;
    END LOOP;

    CLOSE cur_zone_lanes;

    IF v_Lane_Count = 0 THEN
        RAISE NOTICE '  [INFO] No active lanes found in Grid Zone: %', p_Grid_Zone;
        RETURN;
    END IF;

    v_Zone_Saturation_Pct := ROUND((v_Total_Zone_Volume::numeric / v_Total_Zone_Capacity) * 100, 2);

    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE '  Total Monitored Lanes Evaluated : %', v_Lane_Count;
    RAISE NOTICE '  Cumulative Regional Vehicle Load: % vehicles', v_Total_Zone_Volume;
    RAISE NOTICE '  Total Regional Network Capacity : % vehicles', v_Total_Zone_Capacity;
    RAISE NOTICE '  Regional Saturation Percentage  : % %%', v_Zone_Saturation_Pct;
    RAISE NOTICE '------------------------------------------------------------';

    IF v_Zone_Saturation_Pct >= 80.0 OR v_Critical_Lanes_Count >= 2 THEN
        RAISE NOTICE '  *** ACTION REQUIRED: REGIONAL TRAFFIC DIVERSION MANDATED ***';
        RAISE NOTICE '  Rerouting ingress perimeter traffic away from Zone %', UPPER(p_Grid_Zone);
        RAISE NOTICE '  Advisory signs activated. Dynamic routing protocols engaged.';
    ELSIF v_Zone_Saturation_Pct >= 60.0 THEN
        RAISE NOTICE '  *** ADVISORY: MODERATE CONGESTION DETECTED ***';
        RAISE NOTICE '  Recommend staggered green cycle extension for arterial corridors.';
    ELSE
        RAISE NOTICE '  [STATUS: NORMAL] Zone operating within safe capacity limits.';
    END IF;
    RAISE NOTICE '============================================================';
END;
$$;

-- ----------------------------------------------------------------------------
-- Standalone Anonymous DO Block for Direct Verification:
-- ----------------------------------------------------------------------------
DO $$
BEGIN
    CALL proc_Check_Zone_Diversion('Downtown Zone A');
END;
$$;
