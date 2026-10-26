-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Stored Functions — Weighted Moving Average Congestion Classifier
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Create a PL/SQL function func_Calculate_Congestion_Level(p_Lane_ID)
--         that returns a VARCHAR ('Low', 'Medium', 'High') based on mathematical
--         evaluation of recent sensor logs.
-- ============================================================================

CREATE OR REPLACE FUNCTION func_Calculate_Congestion_Level (
    p_Lane_ID IN NUMBER
) 
RETURN VARCHAR2 
IS
    v_Capacity_Limit    NUMBER(6);
    v_Weighted_Sum      NUMBER := 0;
    v_Weight_Sum        NUMBER := 0;
    v_WMA               NUMBER := 0;
    v_Ratio             NUMBER := 0;
    v_Result            VARCHAR2(10);
    v_Reading_Index     NUMBER := 0;
    
    -- Array of weights for the last 5 readings: most recent gets weight 5, oldest gets weight 1
    TYPE t_weights IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_Weights           t_weights;

    -- Cursor retrieving up to 5 most recent sensor readings for the specified lane
    CURSOR cur_recent_logs IS
        SELECT Car_Count
        FROM (
            SELECT Car_Count, Recorded_At
            FROM Sensor_Log
            WHERE Lane_ID = p_Lane_ID
            ORDER BY Recorded_At DESC
        )
        WHERE ROWNUM <= 5;
BEGIN
    -- Define weights for 5 intervals (weights: 5, 4, 3, 2, 1)
    v_Weights(1) := 5;
    v_Weights(2) := 4;
    v_Weights(3) := 3;
    v_Weights(4) := 2;
    v_Weights(5) := 1;

    -- Step 1: Retrieve Lane Capacity
    SELECT Capacity_Limit
    INTO v_Capacity_Limit
    FROM Lane
    WHERE Lane_ID = p_Lane_ID;

    IF v_Capacity_Limit IS NULL OR v_Capacity_Limit <= 0 THEN
        RETURN 'Unknown';
    END IF;

    -- Step 2: Compute Weighted Moving Average (WMA)
    FOR r IN cur_recent_logs LOOP
        v_Reading_Index := v_Reading_Index + 1;
        v_Weighted_Sum  := v_Weighted_Sum + (r.Car_Count * v_Weights(v_Reading_Index));
        v_Weight_Sum    := v_Weight_Sum + v_Weights(v_Reading_Index);
    END LOOP;

    -- Handle case where no sensor readings exist for this lane
    IF v_Weight_Sum = 0 THEN
        RETURN 'Low';
    END IF;

    v_WMA := v_Weighted_Sum / v_Weight_Sum;
    v_Ratio := v_WMA / v_Capacity_Limit;

    -- Step 3: Categorize based on Saturation Ratio rho
    -- rho < 0.40 -> Low
    -- 0.40 <= rho <= 0.75 -> Medium
    -- rho > 0.75 -> High
    IF v_Ratio > 0.75 THEN
        v_Result := 'High';
    ELSIF v_Ratio >= 0.40 THEN
        v_Result := 'Medium';
    ELSE
        v_Result := 'Low';
    END IF;

    RETURN v_Result;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Invalid';
    WHEN OTHERS THEN
        RETURN 'Error';
END func_Calculate_Congestion_Level;
/

-- ----------------------------------------------------------------------------
-- Verification Harness:
-- ----------------------------------------------------------------------------
-- SELECT 
--     Lane_ID, 
--     Direction, 
--     Capacity_Limit, 
--     func_Calculate_Congestion_Level(Lane_ID) AS Calculated_Congestion
-- FROM Lane;
