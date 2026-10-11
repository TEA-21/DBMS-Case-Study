-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Core Schema DDL Tables & Integrity Constraints
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- ============================================================================

-- Clean Teardown
DROP TABLE IF EXISTS Sensor_Log CASCADE;
DROP TABLE IF EXISTS Signal_Phase CASCADE;
DROP TABLE IF EXISTS Lane CASCADE;
DROP TABLE IF EXISTS Intersection CASCADE;

-- ----------------------------------------------------------------------------
-- Table 1: Intersection
-- ----------------------------------------------------------------------------
CREATE TABLE Intersection (
    Intersection_ID INTEGER       PRIMARY KEY,
    Location_Name   VARCHAR(100)  NOT NULL UNIQUE,
    Grid_Zone       VARCHAR(50)   NOT NULL
);

-- ----------------------------------------------------------------------------
-- Table 2: Lane
-- ----------------------------------------------------------------------------
CREATE TABLE Lane (
    Lane_ID               INTEGER     PRIMARY KEY,
    Intersection_ID       INTEGER     NOT NULL,
    Direction             VARCHAR(20) NOT NULL,
    Capacity_Limit        INTEGER     NOT NULL,
    Is_Emergency_Corridor SMALLINT    DEFAULT 0 NOT NULL,
    CONSTRAINT fk_lane_intersection FOREIGN KEY (Intersection_ID)
        REFERENCES Intersection (Intersection_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_lane_direction CHECK (Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')),
    CONSTRAINT chk_lane_capacity CHECK (Capacity_Limit > 0),
    CONSTRAINT chk_lane_emergency CHECK (Is_Emergency_Corridor IN (0, 1))
);

-- ----------------------------------------------------------------------------
-- Table 3: Signal_Phase
-- ----------------------------------------------------------------------------
CREATE TABLE Signal_Phase (
    Phase_ID         INTEGER     PRIMARY KEY,
    Lane_ID          INTEGER     NOT NULL UNIQUE,
    Intersection_ID  INTEGER     NOT NULL,
    Current_State    VARCHAR(10) NOT NULL,
    Duration_Seconds INTEGER     NOT NULL,
    Last_Updated     TIMESTAMP   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_phase_lane FOREIGN KEY (Lane_ID)
        REFERENCES Lane (Lane_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_phase_intersection FOREIGN KEY (Intersection_ID)
        REFERENCES Intersection (Intersection_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_phase_state CHECK (Current_State IN ('RED', 'YELLOW', 'GREEN')),
    CONSTRAINT chk_phase_duration CHECK (Duration_Seconds > 0)
);

-- ----------------------------------------------------------------------------
-- Table 4: Sensor_Log
-- ----------------------------------------------------------------------------
CREATE TABLE Sensor_Log (
    Log_ID      BIGINT    PRIMARY KEY,
    Lane_ID     INTEGER   NOT NULL,
    Car_Count   INTEGER   DEFAULT 0 NOT NULL,
    Recorded_At TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT fk_sensor_lane FOREIGN KEY (Lane_ID)
        REFERENCES Lane (Lane_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_sensor_car_count CHECK (Car_Count >= 0)
);

CREATE INDEX idx_lane_intersection ON Lane (Intersection_ID);
CREATE INDEX idx_phase_intersection ON Signal_Phase (Intersection_ID);
CREATE INDEX idx_sensor_lane_time ON Sensor_Log (Lane_ID, Recorded_At);
