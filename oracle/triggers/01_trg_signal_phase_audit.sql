-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Database Triggers — Reactive Shadow Audit Logging
-- Dialect: Oracle Database (PL/SQL Compatible)
-- Rubric: Create an AFTER UPDATE trigger on the Signal_Phase table. Any time
--         a light changes state (e.g., Green to Yellow), the trigger automatically
--         inserts a record into an Audit_Traffic_Log table to maintain a secure shadow-log.
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_Signal_Phase_Audit
AFTER UPDATE OF Current_State ON Signal_Phase
FOR EACH ROW
WHEN (OLD.Current_State IS NULL OR OLD.Current_State <> NEW.Current_State)
BEGIN
    INSERT INTO Audit_Traffic_Log (
        Audit_ID,
        Phase_ID,
        Old_State,
        New_State,
        Changed_At,
        Trigger_Source
    ) VALUES (
        seq_audit_traffic_log.NEXTVAL,
        :NEW.Phase_ID,
        :OLD.Current_State,
        :NEW.Current_State,
        SYSTIMESTAMP,
        'TRG_SIGNAL_PHASE_AUDIT'
    );
END trg_Signal_Phase_Audit;
/

-- ----------------------------------------------------------------------------
-- Verification Script:
-- ----------------------------------------------------------------------------
-- UPDATE Signal_Phase SET Current_State = 'YELLOW' WHERE Phase_ID = 1;
-- UPDATE Signal_Phase SET Current_State = 'RED'    WHERE Phase_ID = 1;
-- SELECT * FROM Audit_Traffic_Log ORDER BY Changed_At DESC;
