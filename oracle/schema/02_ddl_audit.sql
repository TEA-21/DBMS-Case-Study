-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Shadow Audit Log Schema DDL
-- Dialect: Oracle Database (PL/SQL Compatible)
-- ============================================================================

-- Clean Teardown
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Audit_Traffic_Log CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE seq_audit_traffic_log';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Sequence for automated primary key generation
CREATE SEQUENCE seq_audit_traffic_log
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ----------------------------------------------------------------------------
-- Table 5: Audit_Traffic_Log
-- Captures state transitions executed on Signal_Phase for safety compliance
-- ----------------------------------------------------------------------------
CREATE TABLE Audit_Traffic_Log (
    Audit_ID       NUMBER(12)   NOT NULL,
    Phase_ID       NUMBER(10)   NOT NULL,
    Old_State      VARCHAR2(10),
    New_State      VARCHAR2(10) NOT NULL,
    Changed_At     TIMESTAMP    DEFAULT SYSTIMESTAMP NOT NULL,
    Trigger_Source VARCHAR2(50) DEFAULT 'AUTO_TRIGGER' NOT NULL,
    CONSTRAINT pk_audit_traffic_log PRIMARY KEY (Audit_ID),
    CONSTRAINT fk_audit_phase FOREIGN KEY (Phase_ID)
        REFERENCES Signal_Phase (Phase_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_audit_new_state CHECK (New_State IN ('RED', 'YELLOW', 'GREEN'))
);

CREATE INDEX idx_audit_phase ON Audit_Traffic_Log (Phase_ID);
CREATE INDEX idx_audit_time ON Audit_Traffic_Log (Changed_At);
