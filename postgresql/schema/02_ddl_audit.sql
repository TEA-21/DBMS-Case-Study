-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Shadow Audit Log Schema DDL
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- ============================================================================

DROP TABLE IF EXISTS Audit_Traffic_Log CASCADE;

-- ----------------------------------------------------------------------------
-- Table 5: Audit_Traffic_Log
-- ----------------------------------------------------------------------------
CREATE TABLE Audit_Traffic_Log (
    Audit_ID       BIGSERIAL    PRIMARY KEY,
    Phase_ID       INTEGER      NOT NULL,
    Old_State      VARCHAR(10),
    New_State      VARCHAR(10)  NOT NULL,
    Changed_At     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP NOT NULL,
    Trigger_Source VARCHAR(50)  DEFAULT 'AUTO_TRIGGER' NOT NULL,
    CONSTRAINT fk_audit_phase FOREIGN KEY (Phase_ID)
        REFERENCES Signal_Phase (Phase_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_audit_new_state CHECK (New_State IN ('RED', 'YELLOW', 'GREEN'))
);

CREATE INDEX idx_audit_phase ON Audit_Traffic_Log (Phase_ID);
CREATE INDEX idx_audit_time ON Audit_Traffic_Log (Changed_At);
