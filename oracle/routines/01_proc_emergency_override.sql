-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Stored Procedures — Automated Emergency Corridor Override
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Stored procedure proc_Emergency_Override(p_Intersection_ID).
--         When called, updates all signal phases at target intersection to 'RED'
--         except for the designated emergency lane, simulating automated routing.
-- ============================================================================

CREATE OR REPLACE PROCEDURE proc_Emergency_Override (
    p_Intersection_ID    IN NUMBER,
    p_Emergency_Lane_ID  IN NUMBER DEFAULT NULL
) 
IS
    v_Target_Lane_ID     NUMBER(10);
    v_Intersection_Name  VARCHAR2(100);
    v_Direction          VARCHAR2(20);
    v_Red_Phases_Count   NUMBER := 0;
    v_Node_Exists        NUMBER;
BEGIN
    -- Step 1: Validate Intersection Existence
    SELECT COUNT(*) 
    INTO v_Node_Exists 
    FROM Intersection 
    WHERE Intersection_ID = p_Intersection_ID;

    IF v_Node_Exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Intersection ID ' || p_Intersection_ID || ': Node not found.');
    END IF;

    SELECT Location_Name 
    INTO v_Intersection_Name 
    FROM Intersection 
    WHERE Intersection_ID = p_Intersection_ID;

    -- Step 2: Resolve Emergency Lane ID (Use explicit parameter or fallback to Is_Emergency_Corridor = 1)
    IF p_Emergency_Lane_ID IS NOT NULL THEN
        -- Verify provided lane belongs to target intersection
        SELECT Lane_ID, Direction
        INTO v_Target_Lane_ID, v_Direction
        FROM Lane
        WHERE Lane_ID = p_Emergency_Lane_ID 
          AND Intersection_ID = p_Intersection_ID;
    ELSE
        -- Fallback: Select designated emergency corridor lane
        BEGIN
            SELECT Lane_ID, Direction
            INTO v_Target_Lane_ID, v_Direction
            FROM (
                SELECT Lane_ID, Direction
                FROM Lane
                WHERE Intersection_ID = p_Intersection_ID 
                  AND Is_Emergency_Corridor = 1
                ORDER BY Lane_ID ASC
            )
            WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- If no emergency corridor flagged, take Lane 1 as emergency transit route
                SELECT Lane_ID, Direction
                INTO v_Target_Lane_ID, v_Direction
                FROM (
                    SELECT Lane_ID, Direction
                    FROM Lane
                    WHERE Intersection_ID = p_Intersection_ID
                    ORDER BY Lane_ID ASC
                )
                WHERE ROWNUM = 1;
        END;
    END IF;

    -- Step 3: Lock all conflicting phases at this intersection to 'RED'
    UPDATE Signal_Phase
    SET Current_State    = 'RED',
        Duration_Seconds = 90,
        Last_Updated     = SYSTIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID
      AND Lane_ID        <> v_Target_Lane_ID;

    v_Red_Phases_Count := SQL%ROWCOUNT;

    -- Step 4: Open designated emergency corridor to 'GREEN'
    UPDATE Signal_Phase
    SET Current_State    = 'GREEN',
        Duration_Seconds = 60,
        Last_Updated     = SYSTIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID
      AND Lane_ID         = v_Target_Lane_ID;

    -- Step 5: Emit operational telemetry log
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('[EMERGENCY OVERRIDE ACTIVATED]');
    DBMS_OUTPUT.PUT_LINE('Intersection : ' || v_Intersection_Name || ' (ID: ' || p_Intersection_ID || ')');
    DBMS_OUTPUT.PUT_LINE('Emergency Lane Cleared: Lane ' || v_Target_Lane_ID || ' (' || v_Direction || ') -> STATE: GREEN');
    DBMS_OUTPUT.PUT_LINE('Conflicting Phases Locked to RED: ' || v_Red_Phases_Count || ' lanes');
    DBMS_OUTPUT.PUT_LINE('Timestamp: ' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF2'));
    DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');

    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR] Specified Lane does not exist or does not belong to Intersection ' || p_Intersection_ID);
        ROLLBACK;
        RAISE;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('[ERROR] Emergency Override failed: ' || SQLERRM);
        ROLLBACK;
        RAISE;
END proc_Emergency_Override;
/

-- ----------------------------------------------------------------------------
-- Verification Harness (Anonymous Block):
-- ----------------------------------------------------------------------------
-- SET SERVEROUTPUT ON;
-- EXEC proc_Emergency_Override(1);
-- EXEC proc_Emergency_Override(2, 6);
