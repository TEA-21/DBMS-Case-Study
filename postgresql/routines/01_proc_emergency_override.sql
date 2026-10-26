-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Stored Procedures — Automated Emergency Corridor Override
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Stored procedure proc_Emergency_Override(p_Intersection_ID).
--         When called, updates all signal phases at target intersection to 'RED'
--         except for the designated emergency lane, simulating automated routing.
-- ============================================================================

CREATE OR REPLACE PROCEDURE proc_Emergency_Override (
    p_Intersection_ID   INTEGER,
    p_Emergency_Lane_ID INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Target_Lane_ID    INTEGER;
    v_Intersection_Name VARCHAR(100);
    v_Direction         VARCHAR(20);
    v_Red_Phases_Count  INTEGER := 0;
    v_Node_Exists       INTEGER;
BEGIN
    -- Step 1: Validate Intersection Existence
    SELECT COUNT(*) 
    INTO v_Node_Exists 
    FROM Intersection 
    WHERE Intersection_ID = p_Intersection_ID;

    IF v_Node_Exists = 0 THEN
        RAISE EXCEPTION 'Invalid Intersection ID %: Node not found in database.', p_Intersection_ID;
    END IF;

    SELECT Location_Name 
    INTO v_Intersection_Name 
    FROM Intersection 
    WHERE Intersection_ID = p_Intersection_ID;

    -- Step 2: Resolve Emergency Lane ID
    IF p_Emergency_Lane_ID IS NOT NULL THEN
        SELECT Lane_ID, Direction
        INTO v_Target_Lane_ID, v_Direction
        FROM Lane
        WHERE Lane_ID = p_Emergency_Lane_ID 
          AND Intersection_ID = p_Intersection_ID;
    ELSE
        -- Fallback: Select designated emergency corridor
        SELECT Lane_ID, Direction
        INTO v_Target_Lane_ID, v_Direction
        FROM Lane
        WHERE Intersection_ID = p_Intersection_ID 
          AND Is_Emergency_Corridor = 1
        ORDER BY Lane_ID ASC
        LIMIT 1;

        IF v_Target_Lane_ID IS NULL THEN
            SELECT Lane_ID, Direction
            INTO v_Target_Lane_ID, v_Direction
            FROM Lane
            WHERE Intersection_ID = p_Intersection_ID
            ORDER BY Lane_ID ASC
            LIMIT 1;
        END IF;
    END IF;

    -- Step 3: Lock conflicting phases to 'RED'
    UPDATE Signal_Phase
    SET Current_State    = 'RED',
        Duration_Seconds = 90,
        Last_Updated     = CURRENT_TIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID
      AND Lane_ID        <> v_Target_Lane_ID;

    GET DIAGNOSTICS v_Red_Phases_Count = ROW_COUNT;

    -- Step 4: Open designated emergency corridor to 'GREEN'
    UPDATE Signal_Phase
    SET Current_State    = 'GREEN',
        Duration_Seconds = 60,
        Last_Updated     = CURRENT_TIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID
      AND Lane_ID         = v_Target_Lane_ID;

    -- Step 5: Output Execution Notice
    RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE '[EMERGENCY OVERRIDE ACTIVATED]';
    RAISE NOTICE 'Intersection : % (ID: %)', v_Intersection_Name, p_Intersection_ID;
    RAISE NOTICE 'Emergency Lane Cleared: Lane % (%) -> STATE: GREEN', v_Target_Lane_ID, v_Direction;
    RAISE NOTICE 'Conflicting Phases Locked to RED: % lanes', v_Red_Phases_Count;
    RAISE NOTICE 'Timestamp: %', CURRENT_TIMESTAMP;
    RAISE NOTICE '------------------------------------------------------------';
END;
$$;
