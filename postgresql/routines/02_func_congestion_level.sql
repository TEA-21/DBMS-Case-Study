-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Stored Functions — Weighted Moving Average Congestion Classifier
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Create a PL/SQL function func_Calculate_Congestion_Level(p_Lane_ID)
--         that returns a VARCHAR ('Low', 'Medium', 'High') based on mathematical
--         evaluation of recent sensor logs.
-- ============================================================================

CREATE OR REPLACE FUNCTION func_Calculate_Congestion_Level (
    p_Lane_ID INTEGER
) 
RETURNS VARCHAR 
LANGUAGE plpgsql
AS $$
DECLARE
    v_Capacity_Limit    INTEGER;
    v_Weighted_Sum      NUMERIC := 0;
    v_Weight_Sum        NUMERIC := 0;
    v_WMA               NUMERIC := 0;
    v_Ratio             NUMERIC := 0;
    v_Reading_Index     INTEGER := 0;
    v_Weights           INTEGER[] := ARRAY[5, 4, 3, 2, 1];
    r_log               RECORD;
BEGIN
    -- Retrieve Lane Capacity
    SELECT Capacity_Limit
    INTO v_Capacity_Limit
    FROM Lane
    WHERE Lane_ID = p_Lane_ID;

    IF v_Capacity_Limit IS NULL OR v_Capacity_Limit <= 0 THEN
        RETURN 'Unknown';
    END IF;

    -- Iterate through up to 5 most recent sensor readings
    FOR r_log IN (
        SELECT Car_Count
        FROM Sensor_Log
        WHERE Lane_ID = p_Lane_ID
        ORDER BY Recorded_At DESC
        LIMIT 5
    ) LOOP
        v_Reading_Index := v_Reading_Index + 1;
        v_Weighted_Sum  := v_Weighted_Sum + (r_log.Car_Count * v_Weights[v_Reading_Index]);
        v_Weight_Sum    := v_Weight_Sum + v_Weights[v_Reading_Index];
    END LOOP;

    IF v_Weight_Sum = 0 THEN
        RETURN 'Low';
    END IF;

    v_WMA   := v_Weighted_Sum / v_Weight_Sum;
    v_Ratio := v_WMA / v_Capacity_Limit;

    -- Evaluate Saturation Ratio rho
    IF v_Ratio > 0.75 THEN
        RETURN 'High';
    ELSIF v_Ratio >= 0.40 THEN
        RETURN 'Medium';
    ELSE
        RETURN 'Low';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Invalid';
    WHEN OTHERS THEN
        RETURN 'Error';
END;
$$;
