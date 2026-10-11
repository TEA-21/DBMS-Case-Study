-- ============================================================================
-- SmartFlow Grid: Intelligent IoT Traffic Management System
-- Module: DML Seed Data - Intersections and Lanes
-- Dialect: PostgreSQL (PL/pgSQL Compatible)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Seeding 5 Urban Intersections across 3 Surveillance Zones
-- ----------------------------------------------------------------------------
INSERT INTO Intersection (Intersection_ID, Location_Name, Grid_Zone) VALUES
(1, 'Central Plaza & Main St', 'Zone A - Downtown'),
(2, 'Metro Parkway & 5th Ave', 'Zone A - Downtown'),
(3, 'North Highland Arterial', 'Zone B - Uptown'),
(4, 'Harbor Boulevard & Pier Way', 'Zone B - Uptown'),
(5, 'West Logistics Hub & Freight Rd', 'Zone C - Industrial');

-- ----------------------------------------------------------------------------
-- Seeding 20 Lanes (4 Directional Lanes per Intersection)
-- Designating Emergency Corridors (Is_Emergency_Corridor = 1)
-- ----------------------------------------------------------------------------
-- Intersection 1: Central Plaza
INSERT INTO Lane (Lane_ID, Intersection_ID, Direction, Capacity_Limit, Is_Emergency_Corridor) VALUES
(101, 1, 'NORTHBOUND', 60, 1),
(102, 1, 'SOUTHBOUND', 60, 0),
(103, 1, 'EASTBOUND', 50, 0),
(104, 1, 'WESTBOUND', 50, 0),

-- Intersection 2: Metro Parkway & 5th Ave
(201, 2, 'NORTHBOUND', 55, 0),
(202, 2, 'SOUTHBOUND', 55, 1),
(203, 2, 'EASTBOUND', 45, 0),
(204, 2, 'WESTBOUND', 45, 0),

-- Intersection 3: North Highland Arterial
(301, 3, 'NORTHBOUND', 50, 0),
(302, 3, 'SOUTHBOUND', 50, 0),
(303, 3, 'EASTBOUND', 70, 1),
(304, 3, 'WESTBOUND', 70, 0),

-- Intersection 4: Harbor Boulevard & Pier Way
(401, 4, 'NORTHBOUND', 40, 0),
(402, 4, 'SOUTHBOUND', 40, 0),
(403, 4, 'EASTBOUND', 65, 1),
(404, 4, 'WESTBOUND', 65, 0),

-- Intersection 5: West Logistics Hub & Freight Rd
(501, 5, 'NORTHBOUND', 80, 0),
(502, 5, 'SOUTHBOUND', 80, 1),
(503, 5, 'EASTBOUND', 75, 0),
(504, 5, 'WESTBOUND', 75, 0);
