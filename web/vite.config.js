import { defineConfig } from 'vite';
import Database from 'better-sqlite3';
import fs from 'fs';
import path from 'path';

export default defineConfig({
  server: {
    port: 3000,
    open: true
  },
  plugins: [
    {
      name: 'smartflow-db-middleware',
      configureServer(server) {
        // Initialize In-Memory Relational Database
        const db = new Database(':memory:');
        db.pragma('foreign_keys = ON');

        // Step 1: Create Relational Schema & Declarative Constraints
        db.exec(`
          CREATE TABLE Intersection (
              Intersection_ID INTEGER PRIMARY KEY,
              Location_Name   TEXT NOT NULL UNIQUE,
              Grid_Zone       TEXT NOT NULL
          );

          CREATE TABLE Lane (
              Lane_ID               INTEGER PRIMARY KEY,
              Intersection_ID       INTEGER NOT NULL REFERENCES Intersection(Intersection_ID) ON DELETE CASCADE,
              Direction             TEXT NOT NULL CHECK(Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')),
              Capacity_Limit        INTEGER NOT NULL CHECK(Capacity_Limit > 0),
              Is_Emergency_Corridor INTEGER DEFAULT 0 CHECK(Is_Emergency_Corridor IN (0, 1))
          );

          CREATE TABLE Signal_Phase (
              Phase_ID         INTEGER PRIMARY KEY,
              Lane_ID          INTEGER NOT NULL UNIQUE REFERENCES Lane(Lane_ID) ON DELETE CASCADE,
              Intersection_ID  INTEGER NOT NULL REFERENCES Intersection(Intersection_ID) ON DELETE CASCADE,
              Current_State    TEXT NOT NULL CHECK(Current_State IN ('RED', 'YELLOW', 'GREEN')),
              Duration_Seconds INTEGER NOT NULL CHECK(Duration_Seconds > 0),
              Last_Updated     TEXT DEFAULT (datetime('now')) NOT NULL
          );

          CREATE TABLE Sensor_Log (
              Log_ID      INTEGER PRIMARY KEY AUTOINCREMENT,
              Lane_ID     INTEGER NOT NULL REFERENCES Lane(Lane_ID) ON DELETE CASCADE,
              Car_Count   INTEGER DEFAULT 0 NOT NULL CHECK(Car_Count >= 0),
              Recorded_At TEXT DEFAULT (datetime('now')) NOT NULL
          );

          CREATE TABLE Audit_Traffic_Log (
              Audit_ID       INTEGER PRIMARY KEY AUTOINCREMENT,
              Phase_ID       INTEGER NOT NULL REFERENCES Signal_Phase(Phase_ID) ON DELETE CASCADE,
              Old_State      TEXT,
              New_State      TEXT NOT NULL CHECK(New_State IN ('RED', 'YELLOW', 'GREEN')),
              Changed_At     TEXT DEFAULT (datetime('now')) NOT NULL,
              Trigger_Source TEXT DEFAULT 'TRG_SIGNAL_PHASE_AUDIT' NOT NULL
          );

          -- Native Database Trigger: Real autonomous shadow audit logging
          CREATE TRIGGER trg_signal_phase_audit
          AFTER UPDATE OF Current_State ON Signal_Phase
          FOR EACH ROW
          WHEN OLD.Current_State <> NEW.Current_State
          BEGIN
              INSERT INTO Audit_Traffic_Log (Phase_ID, Old_State, New_State, Changed_At, Trigger_Source)
              VALUES (NEW.Phase_ID, OLD.Current_State, NEW.Current_State, datetime('now'), 'TRG_SIGNAL_PHASE_AUDIT');
          END;

          -- Operational View: Live Green Corridors
          CREATE VIEW vw_Dashboard_Live AS
          SELECT 
              i.Intersection_ID,
              i.Location_Name,
              i.Grid_Zone,
              l.Lane_ID,
              l.Direction,
              l.Capacity_Limit,
              l.Is_Emergency_Corridor,
              sp.Phase_ID,
              sp.Current_State AS Active_Color,
              sp.Duration_Seconds AS Green_Duration,
              sp.Last_Updated AS Phase_Activated_At,
              s.Log_ID AS Latest_Telemetry_ID,
              s.Car_Count AS Current_Volume,
              ROUND((CAST(s.Car_Count AS FLOAT) / l.Capacity_Limit) * 100, 1) AS Saturation_Pct,
              CASE 
                  WHEN (CAST(s.Car_Count AS FLOAT) / l.Capacity_Limit) >= 0.80 THEN 'HEAVY_FLOW'
                  WHEN (CAST(s.Car_Count AS FLOAT) / l.Capacity_Limit) >= 0.40 THEN 'NORMAL_FLOW'
                  ELSE 'FREE_FLOW'
              END AS Flow_Classification
          FROM Signal_Phase sp
          JOIN Lane l ON sp.Lane_ID = l.Lane_ID
          JOIN Intersection i ON sp.Intersection_ID = i.Intersection_ID
          JOIN Sensor_Log s ON l.Lane_ID = s.Lane_ID
          WHERE sp.Current_State = 'GREEN'
            AND s.Log_ID = (
                SELECT s2.Log_ID FROM Sensor_Log s2 
                WHERE s2.Lane_ID = l.Lane_ID 
                ORDER BY s2.Log_ID DESC LIMIT 1
            );
        `);

        // Step 2: Seed Initial Infrastructure
        const insertIntersection = db.prepare('INSERT INTO Intersection VALUES (?, ?, ?)');
        const intersections = [
          [1, 'Central Plaza & Main St', 'Zone A - Downtown'],
          [2, 'Metro Parkway & 5th Ave', 'Zone A - Downtown'],
          [3, 'North Highland Arterial', 'Zone B - Uptown'],
          [4, 'Harbor Boulevard & Pier Way', 'Zone B - Uptown'],
          [5, 'West Logistics Hub & Freight Rd', 'Zone C - Industrial']
        ];
        for (const it of intersections) insertIntersection.run(...it);

        const insertLane = db.prepare('INSERT INTO Lane VALUES (?, ?, ?, ?, ?)');
        const lanes = [
          [101, 1, 'NORTHBOUND', 10, 1], [102, 1, 'SOUTHBOUND', 10, 0], [103, 1, 'EASTBOUND', 12, 0], [104, 1, 'WESTBOUND', 12, 0],
          [201, 2, 'NORTHBOUND', 10, 0], [202, 2, 'SOUTHBOUND', 10, 1], [203, 2, 'EASTBOUND', 12, 0], [204, 2, 'WESTBOUND', 12, 0],
          [301, 3, 'NORTHBOUND', 10, 0], [302, 3, 'SOUTHBOUND', 10, 0], [303, 3, 'EASTBOUND', 12, 1], [304, 3, 'WESTBOUND', 12, 0],
          [401, 4, 'NORTHBOUND', 10, 0], [402, 4, 'SOUTHBOUND', 10, 0], [403, 4, 'EASTBOUND', 12, 1], [404, 4, 'WESTBOUND', 12, 0],
          [501, 5, 'NORTHBOUND', 10, 0], [502, 5, 'SOUTHBOUND', 10, 1], [503, 5, 'EASTBOUND', 12, 0], [504, 5, 'WESTBOUND', 12, 0]
        ];
        for (const ln of lanes) insertLane.run(...ln);

        const insertPhase = db.prepare('INSERT INTO Signal_Phase VALUES (?, ?, ?, ?, ?, ?)');
        const phases = [
          [1001, 101, 1, 'GREEN', 45, '2026-10-25 00:00:00'],
          [1002, 102, 1, 'GREEN', 45, '2026-10-25 00:00:00'],
          [1003, 103, 1, 'RED', 60, '2026-10-25 00:00:00'],
          [1004, 104, 1, 'RED', 60, '2026-10-25 00:00:00'],

          [2001, 201, 2, 'RED', 60, '2026-10-25 00:00:00'],
          [2002, 202, 2, 'RED', 60, '2026-10-25 00:00:00'],
          [2003, 203, 2, 'GREEN', 40, '2026-10-25 00:00:00'],
          [2004, 204, 2, 'RED', 60, '2026-10-25 00:00:00'],

          [3001, 301, 3, 'GREEN', 50, '2026-10-25 00:00:00'],
          [3002, 302, 3, 'GREEN', 50, '2026-10-25 00:00:00'],
          [3003, 303, 3, 'RED', 55, '2026-10-25 00:00:00'],
          [3004, 304, 3, 'RED', 55, '2026-10-25 00:00:00'],

          [4001, 401, 4, 'RED', 50, '2026-10-25 00:00:00'],
          [4002, 402, 4, 'RED', 50, '2026-10-25 00:00:00'],
          [4003, 403, 4, 'GREEN', 60, '2026-10-25 00:00:00'],
          [4004, 404, 4, 'GREEN', 60, '2026-10-25 00:00:00'],

          [5001, 501, 5, 'GREEN', 70, '2026-10-25 00:00:00'],
          [5002, 502, 5, 'GREEN', 70, '2026-10-25 00:00:00'],
          [5003, 503, 5, 'RED', 65, '2026-10-25 00:00:00'],
          [5004, 504, 5, 'RED', 65, '2026-10-25 00:00:00']
        ];
        for (const ph of phases) insertPhase.run(...ph);

        // Seed 5 historical telemetry entries per lane scaled to 10-12 cap
        const insertLog = db.prepare('INSERT INTO Sensor_Log (Lane_ID, Car_Count, Recorded_At) VALUES (?, ?, ?)');
        const baselineVehicles = {
          101: [4, 5, 6, 8, 7], 102: [2, 3, 4, 5, 5], 103: [1, 2, 3, 4, 3], 104: [2, 3, 3, 4, 4],
          201: [3, 4, 5, 6, 6], 202: [2, 3, 4, 4, 5], 203: [5, 6, 7, 9, 8], 204: [1, 1, 2, 2, 3],
          301: [4, 5, 6, 7, 7], 302: [3, 4, 5, 5, 6], 303: [6, 8, 9, 11, 10], 304: [2, 3, 4, 4, 5],
          401: [1, 2, 2, 3, 3], 402: [1, 1, 2, 2, 2], 403: [5, 7, 8, 10, 9], 404: [3, 4, 5, 6, 6],
          501: [6, 7, 8, 9, 9], 502: [5, 6, 7, 8, 8], 503: [3, 4, 5, 5, 6], 504: [2, 3, 4, 5, 5]
        };

        for (const [laneIdStr, counts] of Object.entries(baselineVehicles)) {
          const lId = parseInt(laneIdStr);
          counts.forEach((c, idx) => {
            const time = `2026-10-25 00:0${idx}:00`;
            insertLog.run(lId, c, time);
          });
        }

        // Project Root for loading SQL Scripts
        const projectRoot = path.resolve(__dirname, '..');

        // Middleware Router
        server.middlewares.use((req, res, next) => {
          if (!req.url.startsWith('/api')) return next();

          res.setHeader('Content-Type', 'application/json');
          const pathname = req.url.split('?')[0];

          // 1. GET /api/state: Full snapshot of grid
          if (req.method === 'GET' && pathname === '/api/state') {
            const nodes = db.prepare('SELECT * FROM Intersection').all();
            const laneList = db.prepare(`
              SELECT l.*, sp.Phase_ID, sp.Current_State, sp.Duration_Seconds, sp.Last_Updated,
                     (SELECT s.Car_Count FROM Sensor_Log s WHERE s.Lane_ID = l.Lane_ID ORDER BY s.Log_ID DESC LIMIT 1) AS Current_Car_Count
              FROM Lane l
              JOIN Signal_Phase sp ON l.Lane_ID = sp.Lane_ID
            `).all();

            return res.end(JSON.stringify({
              intersections: nodes,
              lanes: laneList
            }));
          }

          // 2. GET /api/dashboard-live: Direct query to vw_Dashboard_Live
          if (req.method === 'GET' && pathname === '/api/dashboard-live') {
            const rows = db.prepare('SELECT * FROM vw_Dashboard_Live ORDER BY Current_Volume DESC').all();
            return res.end(JSON.stringify(rows));
          }

          // 3. POST /api/telemetry-tick: Real physical database INSERT into Sensor_Log
          if (req.method === 'POST' && pathname === '/api/telemetry-tick') {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
              const payload = body ? JSON.parse(body) : {};
              const lanesWithPhases = db.prepare(`
                SELECT l.Lane_ID, l.Capacity_Limit, sp.Current_State,
                       (SELECT s.Car_Count FROM Sensor_Log s WHERE s.Lane_ID = l.Lane_ID ORDER BY s.Log_ID DESC LIMIT 1) AS Last_Count
                FROM Lane l
                JOIN Signal_Phase sp ON l.Lane_ID = sp.Lane_ID
              `).all();

              const insertSensorLog = db.prepare("INSERT INTO Sensor_Log (Lane_ID, Car_Count, Recorded_At) VALUES (?, ?, datetime('now'))");

              const transaction = db.transaction(() => {
                const updated = [];
                for (const lane of lanesWithPhases) {
                  let count = lane.Last_Count || 0;
                  if (lane.Current_State === 'GREEN') {
                    // Drains queue (1 to 2 cars per tick)
                    count = Math.max(0, count - (Math.random() < 0.65 ? 1 : 2));
                  } else if (lane.Current_State === 'RED') {
                    // Accumulates arrivals (0 to 1 car per tick)
                    count = Math.min(lane.Capacity_Limit, count + (Math.random() < 0.5 ? 1 : 0));
                  }
                  insertSensorLog.run(lane.Lane_ID, count);
                  updated.push({ lane_id: lane.Lane_ID, car_count: count });
                }
                return updated;
              });

              const result = transaction();
              return res.end(JSON.stringify({ success: true, count: result.length, sample: result.slice(0, 5) }));
            });
            return;
          }

          // 4. POST /api/cycle-signal: Advance signal phase (triggers autonomous trigger)
          if (req.method === 'POST' && pathname === '/api/cycle-signal') {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
              const data = body ? JSON.parse(body) : {};
              const targetNode = data.intersection_id || 1;

              // Find active green phases for this intersection
              const phasesForNode = db.prepare('SELECT Phase_ID, Lane_ID, Current_State FROM Signal_Phase WHERE Intersection_ID = ?').all(targetNode);
              
              const updatePhase = db.prepare("UPDATE Signal_Phase SET Current_State = ?, Duration_Seconds = ?, Last_Updated = datetime('now') WHERE Phase_ID = ?");

              const tx = db.transaction(() => {
                // Determine current pair (101/102 or 103/104 etc)
                const greenPhases = phasesForNode.filter(p => p.Current_State === 'GREEN');
                if (greenPhases.length > 0) {
                  // Switch green to red, and red to green
                  for (const p of phasesForNode) {
                    if (p.Current_State === 'GREEN') {
                      updatePhase.run('RED', 60, p.Phase_ID);
                    } else {
                      updatePhase.run('GREEN', 45, p.Phase_ID);
                    }
                  }
                } else {
                  // Reset: first 2 green, second 2 red
                  phasesForNode.forEach((p, idx) => {
                    const st = idx < 2 ? 'GREEN' : 'RED';
                    updatePhase.run(st, st === 'GREEN' ? 45 : 60, p.Phase_ID);
                  });
                }
              });

              tx();

              // Fetch latest audit trigger logs generated by database
              const recentAudits = db.prepare('SELECT * FROM Audit_Traffic_Log ORDER BY Audit_ID DESC LIMIT 4').all();
              return res.end(JSON.stringify({ success: true, audits: recentAudits }));
            });
            return;
          }

          // 5. POST /api/emergency-override: proc_Emergency_Override database execution
          if (req.method === 'POST' && pathname === '/api/emergency-override') {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
              const data = body ? JSON.parse(body) : {};
              const targetIntersection = data.intersection_id || 1;
              let emergencyLaneId = data.emergency_lane_id;

              const tx = db.transaction(() => {
                // If no lane provided, find designated corridor
                if (!emergencyLaneId) {
                  const corridor = db.prepare('SELECT Lane_ID FROM Lane WHERE Intersection_ID = ? AND Is_Emergency_Corridor = 1 LIMIT 1').get(targetIntersection);
                  emergencyLaneId = corridor ? corridor.Lane_ID : db.prepare('SELECT Lane_ID FROM Lane WHERE Intersection_ID = ? LIMIT 1').get(targetIntersection).Lane_ID;
                }

                // Atomic PL/SQL Procedure Simulation:
                // 1. Lock all conflicting phases to RED
                db.prepare(`
                  UPDATE Signal_Phase
                  SET Current_State = 'RED', Duration_Seconds = 90, Last_Updated = datetime('now')
                  WHERE Intersection_ID = ? AND Lane_ID <> ?
                `).run(targetIntersection, emergencyLaneId);

                // 2. Clear emergency corridor to GREEN
                db.prepare(`
                  UPDATE Signal_Phase
                  SET Current_State = 'GREEN', Duration_Seconds = 60, Last_Updated = datetime('now')
                  WHERE Intersection_ID = ? AND Lane_ID = ?
                `).run(targetIntersection, emergencyLaneId);

                return emergencyLaneId;
              });

              const clearedLane = tx();
              const audits = db.prepare('SELECT * FROM Audit_Traffic_Log ORDER BY Audit_ID DESC LIMIT 5').all();
              return res.end(JSON.stringify({
                success: true,
                cleared_lane_id: clearedLane,
                intersection_id: targetIntersection,
                audits
              }));
            });
            return;
          }

          // 6. POST /api/clear-emergency: Resume Normal Operations
          if (req.method === 'POST' && pathname === '/api/clear-emergency') {
            let body = '';
            req.on('data', chunk => body += chunk);
            req.on('end', () => {
              const data = body ? JSON.parse(body) : {};
              const targetIntersection = data.intersection_id || 1;

              const tx = db.transaction(() => {
                const phases = db.prepare('SELECT Phase_ID FROM Signal_Phase WHERE Intersection_ID = ? ORDER BY Phase_ID ASC').all(targetIntersection);
                // Restore standard dual green / dual red pattern
                const updatePhaseStmt = db.prepare("UPDATE Signal_Phase SET Current_State = ?, Duration_Seconds = ?, Last_Updated = datetime('now') WHERE Phase_ID = ?");
                phases.forEach((p, idx) => {
                  const state = idx < 2 ? 'GREEN' : 'RED';
                  updatePhaseStmt.run(state, state === 'GREEN' ? 45 : 60, p.Phase_ID);
                });
              });

              tx();
              const audits = db.prepare('SELECT * FROM Audit_Traffic_Log ORDER BY Audit_ID DESC LIMIT 4').all();
              return res.end(JSON.stringify({ success: true, audits }));
            });
            return;
          }

          // 7. GET /api/audit-log: Shadow audit trail
          if (req.method === 'GET' && pathname === '/api/audit-log') {
            const rows = db.prepare(`
              SELECT a.*, l.Direction, i.Location_Name
              FROM Audit_Traffic_Log a
              JOIN Signal_Phase sp ON a.Phase_ID = sp.Phase_ID
              JOIN Lane l ON sp.Lane_ID = l.Lane_ID
              JOIN Intersection i ON sp.Intersection_ID = i.Intersection_ID
              ORDER BY a.Audit_ID DESC LIMIT 30
            `).all();
            return res.end(JSON.stringify(rows));
          }

          // 8. GET /api/congestion-wma: 5-reading WMA congestion calculation
          if (req.method === 'GET' && pathname === '/api/congestion-wma') {
            const lanes = db.prepare('SELECT Lane_ID, Intersection_ID, Direction, Capacity_Limit FROM Lane').all();
            const weights = [5, 4, 3, 2, 1];
            const getLogs = db.prepare('SELECT Car_Count FROM Sensor_Log WHERE Lane_ID = ? ORDER BY Log_ID DESC LIMIT 5');

            const results = lanes.map(lane => {
              const logs = getLogs.all(lane.Lane_ID).map(r => r.Car_Count);
              const wSubset = weights.slice(0, logs.length);
              const weightedSum = logs.reduce((acc, count, i) => acc + count * wSubset[i], 0);
              const weightTotal = wSubset.reduce((a, b) => a + b, 0);
              const wma = weightTotal > 0 ? (weightedSum / weightTotal) : 0;
              const ratio = wma / lane.Capacity_Limit;
              let level = 'Low';
              if (ratio > 0.75) level = 'High';
              else if (ratio >= 0.40) level = 'Medium';

              return {
                lane_id: lane.Lane_ID,
                intersection_id: lane.Intersection_ID,
                direction: lane.Direction,
                capacity: lane.Capacity_Limit,
                latest_count: logs[0] || 0,
                wma: Math.round(wma * 10) / 10,
                ratio: Math.round(ratio * 100) / 100,
                level
              };
            });

            return res.end(JSON.stringify(results));
          }


          return next();
        });
      }
    }
  ]
});
