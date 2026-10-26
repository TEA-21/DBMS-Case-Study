-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Database Triggers — Reactive Shadow Audit Logging
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- Rubric: Create an AFTER UPDATE trigger on the Signal_Phase table. Any time
--         a light changes state (e.g., Green to Yellow), the trigger automatically
--         inserts a record into an Audit_Traffic_Log table to maintain a secure shadow-log.
-- ============================================================================

CREATE OR REPLACE FUNCTION fn_Signal_Phase_Audit()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Audit_Traffic_Log (
        Phase_ID,
        Old_State,
        New_State,
        Changed_At,
        Trigger_Source
    ) VALUES (
        NEW.Phase_ID,
        OLD.Current_State,
        NEW.Current_State,
        CURRENT_TIMESTAMP,
        'TRG_SIGNAL_PHASE_AUDIT'
    );
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_signal_phase_audit ON Signal_Phase;

CREATE TRIGGER trg_signal_phase_audit
AFTER UPDATE OF Current_State ON Signal_Phase
FOR EACH ROW
WHEN (OLD.Current_State IS DISTINCT FROM NEW.Current_State)
EXECUTE FUNCTION fn_Signal_Phase_Audit();
