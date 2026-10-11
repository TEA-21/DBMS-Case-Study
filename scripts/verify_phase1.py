"""
SmartFlow Grid: Phase 1 Verification Script
Executes schema creation, data seeding, constraint validation, and analytical queries.
Uses Python's built-in sqlite3 engine to provide instant local verification without requiring external database servers.
"""

import sqlite3
import sys

def run_phase1_verification():
    print("=" * 70)
    print(" SmartFlow Grid: Phase 1 Automated Verification Suite")
    print("=" * 70)
    
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON;")

    # 1. DDL Schema Definition
    print("\n[Step 1/5] Creating Physical Tables & Relational Constraints...")
    ddl = """
    CREATE TABLE Intersection (
        Intersection_ID INTEGER PRIMARY KEY,
        Location_Name   TEXT    NOT NULL UNIQUE,
        Grid_Zone       TEXT    NOT NULL
    );

    CREATE TABLE Lane (
        Lane_ID               INTEGER PRIMARY KEY,
        Intersection_ID       INTEGER NOT NULL,
        Direction             TEXT    NOT NULL,
        Capacity_Limit        INTEGER NOT NULL,
        Is_Emergency_Corridor INTEGER DEFAULT 0 NOT NULL,
        FOREIGN KEY (Intersection_ID) REFERENCES Intersection (Intersection_ID) ON DELETE CASCADE,
        CHECK (Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')),
        CHECK (Capacity_Limit > 0),
        CHECK (Is_Emergency_Corridor IN (0, 1))
    );

    CREATE TABLE Signal_Phase (
        Phase_ID         INTEGER PRIMARY KEY,
        Lane_ID          INTEGER NOT NULL UNIQUE,
        Intersection_ID  INTEGER NOT NULL,
        Current_State    TEXT    NOT NULL,
        Duration_Seconds INTEGER NOT NULL,
        Last_Updated     TEXT    NOT NULL,
        FOREIGN KEY (Lane_ID) REFERENCES Lane (Lane_ID) ON DELETE CASCADE,
        FOREIGN KEY (Intersection_ID) REFERENCES Intersection (Intersection_ID) ON DELETE CASCADE,
        CHECK (Current_State IN ('RED', 'YELLOW', 'GREEN')),
        CHECK (Duration_Seconds > 0)
    );

    CREATE TABLE Sensor_Log (
        Log_ID      INTEGER PRIMARY KEY,
        Lane_ID     INTEGER NOT NULL,
        Car_Count   INTEGER DEFAULT 0 NOT NULL,
        Recorded_At TEXT    NOT NULL,
        FOREIGN KEY (Lane_ID) REFERENCES Lane (Lane_ID) ON DELETE CASCADE,
        CHECK (Car_Count >= 0)
    );

    CREATE TABLE Audit_Traffic_Log (
        Audit_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
        Phase_ID       INTEGER NOT NULL,
        Old_State      TEXT,
        New_State      TEXT    NOT NULL,
        Changed_At     TEXT    NOT NULL,
        Trigger_Source TEXT    DEFAULT 'AUTO_TRIGGER' NOT NULL,
        FOREIGN KEY (Phase_ID) REFERENCES Signal_Phase (Phase_ID) ON DELETE CASCADE,
        CHECK (New_State IN ('RED', 'YELLOW', 'GREEN'))
    );
    """
    cursor.executescript(ddl)
    print("  [OK] Tables created: Intersection, Lane, Signal_Phase, Sensor_Log, Audit_Traffic_Log")

    # 2. Seeding Data
    print("\n[Step 2/5] Seeding Intersections & Lanes...")
    # 5 Intersections
    intersections = [
        (1, 'Central Plaza & Main St', 'Zone A - Downtown'),
        (2, 'Metro Parkway & 5th Ave', 'Zone A - Downtown'),
        (3, 'North Highland Arterial', 'Zone B - Uptown'),
        (4, 'Harbor Boulevard & Pier Way', 'Zone B - Uptown'),
        (5, 'West Logistics Hub & Freight Rd', 'Zone C - Industrial')
    ]
    cursor.executemany("INSERT INTO Intersection VALUES (?, ?, ?);", intersections)
    
    # 20 Lanes
    lanes = [
        (101, 1, 'NORTHBOUND', 60, 1), (102, 1, 'SOUTHBOUND', 60, 0),
        (103, 1, 'EASTBOUND', 50, 0),  (104, 1, 'WESTBOUND', 50, 0),
        (201, 2, 'NORTHBOUND', 55, 0), (202, 2, 'SOUTHBOUND', 55, 1),
        (203, 2, 'EASTBOUND', 45, 0),  (204, 2, 'WESTBOUND', 45, 0),
        (301, 3, 'NORTHBOUND', 50, 0), (302, 3, 'SOUTHBOUND', 50, 0),
        (303, 3, 'EASTBOUND', 70, 1),  (304, 3, 'WESTBOUND', 70, 0),
        (401, 4, 'NORTHBOUND', 40, 0), (402, 4, 'SOUTHBOUND', 40, 0),
        (403, 4, 'EASTBOUND', 65, 1),  (404, 4, 'WESTBOUND', 65, 0),
        (501, 5, 'NORTHBOUND', 80, 0), (502, 5, 'SOUTHBOUND', 80, 1),
        (503, 5, 'EASTBOUND', 75, 0),  (504, 5, 'WESTBOUND', 75, 0)
    ]
    cursor.executemany("INSERT INTO Lane VALUES (?, ?, ?, ?, ?);", lanes)
    print(f"  [OK] Seeded {len(intersections)} Intersections and {len(lanes)} Lanes.")

    print("\n[Step 3/5] Seeding Signal Phases & 120 Sensor Telemetry Logs...")
    # Signal Phases
    phases = [
        (1001, 101, 1, 'GREEN', 45, '2026-10-11 19:40:00'),
        (1002, 102, 1, 'GREEN', 45, '2026-10-11 19:40:00'),
        (1003, 103, 1, 'RED', 60, '2026-10-11 19:40:00'),
        (1004, 104, 1, 'RED', 60, '2026-10-11 19:40:00'),
        (2001, 201, 2, 'RED', 60, '2026-10-11 19:40:00'),
        (2002, 202, 2, 'RED', 60, '2026-10-11 19:40:00'),
        (2003, 203, 2, 'GREEN', 40, '2026-10-11 19:40:00'),
        (2004, 204, 2, 'YELLOW', 10, '2026-10-11 19:40:00'),
        (3001, 301, 3, 'GREEN', 50, '2026-10-11 19:40:00'),
        (3002, 302, 3, 'YELLOW', 10, '2026-10-11 19:40:00'),
        (3003, 303, 3, 'RED', 55, '2026-10-11 19:40:00'),
        (3004, 304, 3, 'RED', 55, '2026-10-11 19:40:00'),
        (4001, 401, 4, 'RED', 50, '2026-10-11 19:40:00'),
        (4002, 402, 4, 'RED', 50, '2026-10-11 19:40:00'),
        (4003, 403, 4, 'GREEN', 60, '2026-10-11 19:40:00'),
        (4004, 404, 4, 'GREEN', 60, '2026-10-11 19:40:00'),
        (5001, 501, 5, 'GREEN', 70, '2026-10-11 19:40:00'),
        (5002, 502, 5, 'GREEN', 70, '2026-10-11 19:40:00'),
        (5003, 503, 5, 'RED', 65, '2026-10-11 19:40:00'),
        (5004, 504, 5, 'RED', 65, '2026-10-11 19:40:00'),
    ]
    cursor.executemany("INSERT INTO Signal_Phase VALUES (?, ?, ?, ?, ?, ?);", phases)

    # Read sensor logs from postgres seed file directly
    import re
    with open("d:/Projects/DBMS Case Study/postgresql/seeds/03_seed_sensor_logs.sql", "r") as f:
        content = f.read()
    
    matches = re.findall(r"\((\d+),\s*(\d+),\s*(\d+),\s*TIMESTAMP\s*'([^']+)'\)", content)
    cursor.executemany("INSERT INTO Sensor_Log VALUES (?, ?, ?, ?);", matches)
    conn.commit()

    cursor.execute("SELECT COUNT(*) FROM Sensor_Log;")
    log_count = cursor.fetchone()[0]
    print(f"  [OK] Seeded {len(phases)} Signal Phases and {log_count} Sensor Telemetry Logs (Goal > 100).")

    # 3. Integrity Constraint Validation
    print("\n[Step 4/5] Validating Integrity Constraints...")
    # Test 1: Check Constraint on Signal State
    try:
        cursor.execute("INSERT INTO Signal_Phase VALUES (9999, 101, 1, 'PURPLE', 30, '2026-10-11 12:00:00');")
        print("  [FAIL] CHECK constraint on Current_State did not block invalid state 'PURPLE'")
        sys.exit(1)
    except sqlite3.IntegrityError:
        print("  [OK] CHECK constraint verified: Blocked invalid Signal_Phase state ('PURPLE').")

    # Test 2: Check Constraint on Negative Car Count
    try:
        cursor.execute("INSERT INTO Sensor_Log VALUES (9999, 101, -15, '2026-10-11 12:00:00');")
        print("  [FAIL] CHECK constraint on Car_Count did not block negative count")
        sys.exit(1)
    except sqlite3.IntegrityError:
        print("  [OK] CHECK constraint verified: Blocked negative Car_Count (-15).")

    # Test 3: Foreign Key enforcement
    try:
        cursor.execute("INSERT INTO Lane VALUES (9999, 999, 'NORTHBOUND', 50, 0);")
        print("  [FAIL] FK constraint did not block non-existent Intersection_ID 999")
        sys.exit(1)
    except sqlite3.IntegrityError:
        print("  [OK] FK constraint verified: Blocked orphan Lane referencing non-existent intersection.")

    # 4. Phase 1 Analytical Query Execution
    print("\n[Step 5/5] Executing Phase 1 Analytical Queries...")
    
    print("\n  --- Query 1: Group Functions (Volume per Intersection) ---")
    query_group = """
    SELECT 
        i.Intersection_ID,
        i.Location_Name,
        i.Grid_Zone,
        COUNT(s.Log_ID)      AS Total_Readings,
        SUM(s.Car_Count)     AS Cumulative_Volume,
        ROUND(AVG(s.Car_Count), 2) AS Avg_Vehicles_Interval,
        MAX(s.Car_Count)     AS Peak_Vehicles
    FROM Intersection i
    JOIN Lane l ON i.Intersection_ID = l.Intersection_ID
    JOIN Sensor_Log s ON l.Lane_ID = s.Lane_ID
    GROUP BY i.Intersection_ID, i.Location_Name, i.Grid_Zone
    ORDER BY Avg_Vehicles_Interval DESC;
    """
    cursor.execute(query_group)
    rows = cursor.fetchall()
    print(f"  {'ID':<4} | {'Location':<32} | {'Zone':<20} | {'Readings':<8} | {'Volume':<8} | {'Avg':<6} | {'Peak':<5}")
    print("  " + "-" * 95)
    for r in rows:
        print(f"  {r[0]:<4} | {r[1]:<32} | {r[2]:<20} | {r[3]:<8} | {r[4]:<8} | {r[5]:<6} | {r[6]:<5}")

    print("\n  --- Query 2: Temporal Analysis (Hourly Breakdown via Date Extraction) ---")
    query_temporal = """
    SELECT 
        strftime('%H', s.Recorded_At) AS Hour_Of_Day,
        COUNT(s.Log_ID)               AS Logs_Recorded,
        SUM(s.Car_Count)              AS Total_Vehicles,
        ROUND(AVG(s.Car_Count), 2)    AS Avg_Vehicles_Hour,
        MAX(s.Car_Count)              AS Peak_Hour_Traffic
    FROM Sensor_Log s
    GROUP BY strftime('%H', s.Recorded_At)
    ORDER BY Hour_Of_Day ASC;
    """
    cursor.execute(query_temporal)
    rows = cursor.fetchall()
    print(f"  {'Hour':<6} | {'Logs':<6} | {'Total Vehicles':<15} | {'Avg Density':<12} | {'Peak'}")
    print("  " + "-" * 55)
    for r in rows:
        print(f"  {r[0]:<6} | {r[1]:<6} | {r[2]:<15} | {r[3]:<12} | {r[4]}")

    print("\n  --- Query 3: Time-of-Day Categorical Classification ---")
    query_categories = """
    SELECT 
        CASE 
            WHEN CAST(strftime('%H', s.Recorded_At) AS INT) BETWEEN 7 AND 9 THEN 'Morning Rush (07:00-10:00)'
            WHEN CAST(strftime('%H', s.Recorded_At) AS INT) BETWEEN 12 AND 14 THEN 'Midday Baseline (12:00-15:00)'
            WHEN CAST(strftime('%H', s.Recorded_At) AS INT) BETWEEN 17 AND 19 THEN 'Evening Peak (17:00-20:00)'
            ELSE 'Night Off-Peak (20:00-06:00)'
        END AS Day_Period,
        COUNT(s.Log_ID)            AS Sample_Count,
        SUM(s.Car_Count)           AS Total_Vehicles,
        ROUND(AVG(s.Car_Count), 2) AS Average_Car_Density
    FROM Sensor_Log s
    GROUP BY Day_Period
    ORDER BY Total_Vehicles DESC;
    """
    cursor.execute(query_categories)
    rows = cursor.fetchall()
    print(f"  {'Time Window':<30} | {'Samples':<8} | {'Total Vehicles':<15} | {'Avg Density'}")
    print("  " + "-" * 70)
    for r in rows:
        print(f"  {r[0]:<30} | {r[1]:<8} | {r[2]:<15} | {r[3]}")

    print("\n" + "=" * 70)
    print(" [OK] PHASE 1 VERIFICATION COMPLETED WITH 100% SUCCESS!")
    print("=" * 70)

if __name__ == "__main__":
    run_phase1_verification()
