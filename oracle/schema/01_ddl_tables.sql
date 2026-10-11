-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: Core Schema DDL Tables & Integrity Constraints
-- Dialect: Oracle Database (PL/SQL Compatible)
-- ============================================================================

-- Clean Teardown (Drops existing child tables before parents)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Sensor_Log CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Signal_Phase CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Lane CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Intersection CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ----------------------------------------------------------------------------
-- Table 1: Intersection
-- Represents physical road junctions and geographical surveillance zones
-- ----------------------------------------------------------------------------
CREATE TABLE Intersection (
    Intersection_ID NUMBER(10)          NOT NULL,
    Location_Name   VARCHAR2(100)       NOT NULL,
    Grid_Zone       VARCHAR2(50)        NOT NULL,
    CONSTRAINT pk_intersection PRIMARY KEY (Intersection_ID),
    CONSTRAINT uq_intersection_location UNIQUE (Location_Name)
);

-- ----------------------------------------------------------------------------
-- Table 2: Lane
-- Represents directional approach lanes connected to an intersection
-- ----------------------------------------------------------------------------
CREATE TABLE Lane (
    Lane_ID               NUMBER(10)    NOT NULL,
    Intersection_ID       NUMBER(10)    NOT NULL,
    Direction             VARCHAR2(20)  NOT NULL,
    Capacity_Limit        NUMBER(6)     NOT NULL,
    Is_Emergency_Corridor NUMBER(1)     DEFAULT 0 NOT NULL,
    CONSTRAINT pk_lane PRIMARY KEY (Lane_ID),
    CONSTRAINT fk_lane_intersection FOREIGN KEY (Intersection_ID)
        REFERENCES Intersection (Intersection_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_lane_direction CHECK (Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')),
    CONSTRAINT chk_lane_capacity CHECK (Capacity_Limit > 0),
    CONSTRAINT chk_lane_emergency CHECK (Is_Emergency_Corridor IN (0, 1))
);

-- ----------------------------------------------------------------------------
-- Table 3: Signal_Phase
-- Controls traffic light states (RED, YELLOW, GREEN) per directional lane
-- ----------------------------------------------------------------------------
CREATE TABLE Signal_Phase (
    Phase_ID         NUMBER(10)    NOT NULL,
    Lane_ID          NUMBER(10)    NOT NULL,
    Intersection_ID  NUMBER(10)    NOT NULL,
    Current_State    VARCHAR2(10)  NOT NULL,
    Duration_Seconds NUMBER(5)     NOT NULL,
    Last_Updated     TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_signal_phase PRIMARY KEY (Phase_ID),
    CONSTRAINT uq_phase_lane UNIQUE (Lane_ID),
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
-- Records time-series telemetry from IoT inductive loop and camera sensors
-- ----------------------------------------------------------------------------
CREATE TABLE Sensor_Log (
    Log_ID      NUMBER(12) NOT NULL,
    Lane_ID     NUMBER(10) NOT NULL,
    Car_Count   NUMBER(6)  DEFAULT 0 NOT NULL,
    Recorded_At TIMESTAMP  DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_sensor_log PRIMARY KEY (Log_ID),
    CONSTRAINT fk_sensor_lane FOREIGN KEY (Lane_ID)
        REFERENCES Lane (Lane_ID)
        ON DELETE CASCADE,
    CONSTRAINT chk_sensor_car_count CHECK (Car_Count >= 0)
);

-- Create operational indexes for foreign keys & timestamp range queries
CREATE INDEX idx_lane_intersection ON Lane (Intersection_ID);
CREATE INDEX idx_phase_intersection ON Signal_Phase (Intersection_ID);
CREATE INDEX idx_sensor_lane_time ON Sensor_Log (Lane_ID, Recorded_At);
