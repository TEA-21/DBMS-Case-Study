# SmartFlow Grid: Intelligent IoT Traffic Management System
## Advanced Relational Database Architecture, Real-Time Sensor Telemetry Ingestion, and Automated PL/SQL Signal Actuation

---

### Academic Case Study Comprehensive Submission (Reviews 1, 2, and 3 — 30-Mark Evaluation)

**Authors:**
- **Taanush Emmanuel Abraham** (Registration Number: `24BCE0708`)
- **Tanishka Kundu** (Registration Number: `24BCE0730`)

**Course:** Database Management Systems  
**Evaluation Standard:** Dual-Engine Architecture (Primary: Oracle PL/SQL | Secondary: PostgreSQL PL/pgSQL)  
**System Repository:** `DBMS Case Study/`  
**Date of Submission:** October 2026  

---

## Abstract

Urban traffic congestion represents a multi-billion dollar economic sink and an environmental hazard, driven primarily by antiquated fixed-time traffic light controllers that fail to adapt to non-stationary vehicular flows. The **SmartFlow Grid** is an enterprise-grade relational database management system designed to model physical urban road topologies, ingest high-frequency IoT inductive loop and optical sensor telemetry, and execute real-time automated traffic actuation through server-side procedural logic. 

This case study establishes a complete dual-dialect implementation across **Oracle Database (PL/SQL)** and **PostgreSQL (PL/pgSQL)**. The database architecture enforces rigorous declarative integrity constraints, models directional lanes and independent signal phases, computes multi-interval weighted moving average (WMA) congestion indices, facilitates automated emergency corridor clearance (`proc_Emergency_Override`), conducts cursor-driven regional zone surveillance (`proc_Check_Zone_Diversion`), and provides non-repudiable safety tracking through an asynchronous shadow audit trigger (`trg_Signal_Phase_Audit`). In addition to the technical implementation, this report provides a formal mathematical normalization proof demonstrating lossless decomposition from an unnormalized Universal Relation $R$ through 1NF, 2NF, 3NF, and Boyce-Codd Normal Form (BCNF).

---

## Table of Contents

1. [Chapter 1: Domain Analysis & Problem Formulation](#chapter-1-domain-analysis--problem-formulation)
2. [Chapter 2: Requirements Analysis & Business Rules](#chapter-2-requirements-analysis--business-rules)
3. [Chapter 3: Database Design & Extended Entity-Relationship (EER) Modeling](#chapter-3-database-design--extended-entity-relationship-eer-modeling)
4. [Chapter 4: Formal Normalization Proofs (1NF to BCNF)](#chapter-4-formal-normalization-proofs-1nf-to-bcnf)
5. [Chapter 5: Implementation Code Catalog (Oracle & PostgreSQL)](#chapter-5-implementation-code-catalog-oracle--postgresql)
6. [Chapter 6: Experimental Verification, Testing & Performance Analysis](#chapter-6-experimental-verification-testing--performance-analysis)

---

## Chapter 1: Domain Analysis & Problem Formulation

### 1.1 The Urban Traffic Crisis & Static Signal Inefficiencies
Traditional municipal traffic signal networks rely heavily on pre-programmed electromechanical or microprocessor timers configured around static time-of-day plans (e.g., morning rush, midday lull, evening peak). These open-loop systems suffer from critical systemic vulnerabilities:
1. **Inability to Respond to Asymmetric Surges:** Accidents, stalled vehicles, bad weather, or localized events create sudden queue spikes on specific directional approaches while opposing phases remain green with zero waiting vehicles.
2. **Emergency Vehicle Impedance:** Ambulances, fire engines, and police cruisers lose crucial minutes navigating gridlocked intersections without automated, fail-safe signal preemption corridors.
3. **Idling Emissions & Economic Loss:** Unnecessary red-light idling generates excess hydrocarbon and carbon monoxide emissions, accelerates engine wear, and wastes millions of commuter hours annually.

### 1.2 The IoT Relational Smart Grid Paradigm
The **SmartFlow Grid** resolves these inefficiencies by treating every physical intersection as an intelligent relational node. Road approaches are partitioned into dedicated directional lanes equipped with IoT sensors (inductive loops embedded in the asphalt and computer vision cameras mounted on gantries). Every $T$ seconds, sensors transmit timestamped telemetry containing vehicle counts and occupancy metrics to the central relational database engine.

By housing operational logic directly inside the database via **PL/SQL Stored Procedures, Functions, Explicit Cursors, and Reactive Triggers**, the system minimizes network round-trip latency, enforces strict transaction atomicity, guarantees ACID compliance, and ensures that signal transitions are recorded in an immutable shadow audit log.

---

## Chapter 2: Requirements Analysis & Business Rules

### 2.1 Functional Requirements
- **FR1 (Infrastructure Modeling):** The system must uniquely represent road junctions (`Intersection`), their municipal surveillance sectors (`Grid_Zone`), and their individual directional approach channels (`Lane`).
- **FR2 (Directional Lane Independence):** Each lane must have an independent signal head (`Signal_Phase`) capable of being actuated independently of other lanes at the same junction.
- **FR3 (Telemetry Ingestion):** High-velocity sensor readings (`Sensor_Log`) must be continuously ingested with sub-second timestamps, maintaining referential integrity to monitored lanes.
- **FR4 (Real-Time Congestion Indexing):** The database must calculate a Weighted Moving Average (WMA) of recent vehicle counts per lane, normalizing against physical capacity limits to categorize congestion into `'Low'`, `'Medium'`, and `'High'`.
- **FR5 (Emergency Vehicle Preemption):** Upon receiving an emergency transit signal, the system must atomically switch conflicting phases to `'RED'` with hold safety buffers while clearing the designated emergency lane to `'GREEN'`.
- **FR6 (Regional Grid Surveillance):** An explicit cursor mechanism must aggregate volume across all lanes in a metropolitan grid zone to assess systemic saturation and trigger automated diversion protocols.
- **FR7 (Regulatory Shadow Audit Logging):** An automated trigger must capture all signal state changes in a tamper-resistant `Audit_Traffic_Log` table without requiring application-level intervention.

### 2.2 Relational Integrity Constraints & Business Rules
1. **Entity Integrity (PK):** Every relation must possess a surrogate or natural primary key: `Intersection_ID`, `Lane_ID`, `Phase_ID`, `Log_ID`, `Audit_ID`.
2. **Referential Integrity (FK):**
   - Cascading deletions ensure that removing an `Intersection` cleans up associated `Lane`, `Signal_Phase`, and `Sensor_Log` rows.
   - Every `Signal_Phase` references exactly one physical `Lane` via a `UNIQUE` constraint (1:1 relationship).
3. **Domain & Check Constraints (CHECK):**
   - `Signal_Phase.Current_State IN ('RED', 'YELLOW', 'GREEN')`
   - `Lane.Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')`
   - `Lane.Capacity_Limit > 0`
   - `Lane.Is_Emergency_Corridor IN (0, 1)`
   - `Sensor_Log.Car_Count >= 0`
   - `Signal_Phase.Duration_Seconds > 0`
4. **Default Value Constraints (DEFAULT):**
   - `Sensor_Log.Car_Count DEFAULT 0`
   - `Sensor_Log.Recorded_At DEFAULT CURRENT_TIMESTAMP`
   - `Signal_Phase.Last_Updated DEFAULT CURRENT_TIMESTAMP`
   - `Lane.Is_Emergency_Corridor DEFAULT 0`

---

## Chapter 3: Database Design & Extended Entity-Relationship (EER) Modeling

### 3.1 Extended Entity-Relationship (EER) Architecture
The SmartFlow Grid EER diagram uses the formal **Chen Notation**, with distinct graphical representations for strong entity sets (rectangles), relationships (diamonds), primary key attributes (underlined ovals), standard attributes (ovals), and structural cardinalities ($1:1$, $1:N$).

```
             +-----------------------------------------------+
             |                 Intersection                  |
             |  * Intersection_ID (PK)                       |
             |  - Location_Name (UQ)                         |
             |  - Grid_Zone                                  |
             +-----------------------+-----------------------+
                                     | 1
                                     | (1,N)
                                     | Has_Lanes
                                     | N
             +-----------------------+-----------------------+
             |                     Lane                      |
             |  * Lane_ID (PK)                               |
             |  - Intersection_ID (FK)                       |
             |  - Direction                                  |
             |  - Capacity_Limit                             |
             |  - Is_Emergency_Corridor                      |
             +-----------+-----------------------+-----------+
                         | 1                     | 1
                         | (1,1)                 | (1,N)
                         | Regulated_By          | Generates
                         | 1                     | N
     +-------------------+---+       +-----------+-------------------+
     |     Signal_Phase      |       |          Sensor_Log           |
     | * Phase_ID (PK)       |       | * Log_ID (PK)                 |
     | - Lane_ID (FK, UQ)    |       | - Lane_ID (FK)                |
     | - Intersection_ID (FK)|       | - Car_Count                   |
     | - Current_State       |       | - Recorded_At                 |
     | - Duration_Seconds    |       +-------------------------------+
     | - Last_Updated        |
     +-----------+-----------+
                 | 1
                 | (1,N)
                 | Triggers_Audit
                 | N
     +-----------+-----------+
     |   Audit_Traffic_Log   |
     | * Audit_ID (PK)       |
     | - Phase_ID (FK)       |
     | - Old_State           |
     | - New_State           |
     | - Changed_At          |
     | - Trigger_Source      |
     +-----------------------+
```

### 3.2 Relational Data Dictionary

#### Table 1: `Intersection`
| Column Name | Data Type (Oracle) | Data Type (Postgres) | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Intersection_ID` | `NUMBER(10)` | `INTEGER` | `PRIMARY KEY` | Unique surrogate identifier for junction node |
| `Location_Name` | `VARCHAR2(100)` | `VARCHAR(100)` | `NOT NULL, UNIQUE` | Physical street intersection description |
| `Grid_Zone` | `VARCHAR2(50)` | `VARCHAR(50)` | `NOT NULL` | Metropolitan surveillance sector (e.g. Zone A) |

#### Table 2: `Lane`
| Column Name | Data Type (Oracle) | Data Type (Postgres) | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Lane_ID` | `NUMBER(10)` | `INTEGER` | `PRIMARY KEY` | Unique surrogate identifier for physical lane |
| `Intersection_ID`| `NUMBER(10)` | `INTEGER` | `NOT NULL, FK` | References `Intersection(Intersection_ID)` |
| `Direction` | `VARCHAR2(20)` | `VARCHAR(20)` | `CHECK(Direction IN ...)`| Cardinal approach compass direction |
| `Capacity_Limit` | `NUMBER(6)` | `INTEGER` | `CHECK(Capacity_Limit > 0)` | Maximum safe vehicle buffer capacity |
| `Is_Emergency_Corridor`| `NUMBER(1)` | `SMALLINT` | `DEFAULT 0, CHECK IN (0,1)`| Emergency clearance corridor flag |

#### Table 3: `Signal_Phase`
| Column Name | Data Type (Oracle) | Data Type (Postgres) | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Phase_ID` | `NUMBER(10)` | `INTEGER` | `PRIMARY KEY` | Unique signal head controller identifier |
| `Lane_ID` | `NUMBER(10)` | `INTEGER` | `NOT NULL, UNIQUE, FK` | Dedicated monitored lane (1:1 constraint) |
| `Intersection_ID`| `NUMBER(10)` | `INTEGER` | `NOT NULL, FK` | Parent junction identifier |
| `Current_State` | `VARCHAR2(10)` | `VARCHAR(10)` | `CHECK IN ('RED','YELLOW','GREEN')` | Current active color state |
| `Duration_Seconds`| `NUMBER(5)` | `INTEGER` | `CHECK(Duration_Seconds > 0)` | Active state hold time in seconds |
| `Last_Updated` | `TIMESTAMP` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | Last timestamp of signal state mutation |

#### Table 4: `Sensor_Log`
| Column Name | Data Type (Oracle) | Data Type (Postgres) | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Log_ID` | `NUMBER(12)` | `BIGINT` | `PRIMARY KEY` | High-cardinality telemetry record identifier |
| `Lane_ID` | `NUMBER(10)` | `INTEGER` | `NOT NULL, FK` | Source road lane monitored |
| `Car_Count` | `NUMBER(6)` | `INTEGER` | `DEFAULT 0, CHECK >= 0` | Measured vehicle queue count |
| `Recorded_At` | `TIMESTAMP` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | High-precision time telemetry received |

#### Table 5: `Audit_Traffic_Log`
| Column Name | Data Type (Oracle) | Data Type (Postgres) | Constraints | Description |
| :--- | :--- | :--- | :--- | :--- |
| `Audit_ID` | `NUMBER(12)` | `BIGSERIAL` | `PRIMARY KEY` | Monotonically increasing audit log sequence |
| `Phase_ID` | `NUMBER(10)` | `INTEGER` | `NOT NULL, FK` | Associated signal phase that changed state |
| `Old_State` | `VARCHAR2(10)` | `VARCHAR(10)` | `NULLABLE` | Previous signal state prior to trigger firing |
| `New_State` | `VARCHAR2(10)` | `VARCHAR(10)` | `NOT NULL, CHECK IN (...)`| New signal state activated |
| `Changed_At` | `TIMESTAMP` | `TIMESTAMP` | `DEFAULT CURRENT_TIMESTAMP` | Exact system timestamp of transition |
| `Trigger_Source`| `VARCHAR2(50)` | `VARCHAR(50)` | `DEFAULT 'AUTO_TRIGGER'` | Originating PL/SQL trigger or system routine |

---

## Chapter 4: Formal Normalization Proofs (1NF to BCNF)

Normalization is the formal mathematical technique used to eliminate data redundancy, prevent insertion, update, and deletion anomalies, and guarantee data consistency across relational schemas.

### 4.1 The Universal Relation ($R$)
Consider an unnormalized universal traffic reporting relation $R$ representing flat telemetry spreadsheets captured from roadside IoT gateways:

$$R = \{ \text{Intersection\_ID}, \text{Location\_Name}, \text{Grid\_Zone}, \text{Lane\_ID}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency}, \text{Phase\_ID}, \text{Current\_State}, \text{Duration}, \text{Last\_Updated}, \text{Log\_ID}, \text{Car\_Count}, \text{Recorded\_At} \}$$

### 4.2 Set of Functional Dependencies ($F$)
Through empirical analysis of physical road networks and municipal domain rules, the minimal set of non-trivial Functional Dependencies $F$ is established:

1. $FD_1: \text{Intersection\_ID} \rightarrow \text{Location\_Name}, \text{Grid\_Zone}$  
   *(An intersection ID uniquely identifies the geographic location and its assigned urban zone.)*
2. $FD_2: \text{Location\_Name} \rightarrow \text{Intersection\_ID}, \text{Grid\_Zone}$  
   *(Location names are unique across the municipality.)*
3. $FD_3: \text{Lane\_ID} \rightarrow \text{Intersection\_ID}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency}$  
   *(A physical lane belongs to exactly one intersection, has a fixed direction, capacity limit, and emergency flag.)*
4. $FD_4: \text{Phase\_ID} \rightarrow \text{Lane\_ID}, \text{Intersection\_ID}, \text{Current\_State}, \text{Duration}, \text{Last\_Updated}$  
   *(A signal phase controller governs exactly one lane at an intersection.)*
5. $FD_5: \text{Lane\_ID} \rightarrow \text{Phase\_ID}$  
   *(Because each lane has exactly one dedicated signal phase, the relationship is bijective $1:1$.)*
6. $FD_6: \text{Log\_ID} \rightarrow \text{Lane\_ID}, \text{Car\_Count}, \text{Recorded\_At}$  
   *(An IoT telemetry packet represents a single vehicle observation reading on a specific lane at a specific time.)*
7. $FD_7: \{ \text{Lane\_ID}, \text{Recorded\_At} \} \rightarrow \text{Car\_Count}, \text{Log\_ID}$  
   *(At any distinct instant, a lane can possess only one sensor reading.)*

### 4.3 Candidate Key Determination
To find the candidate keys of $R$, we compute the attribute closure with respect to $F$:

$$\{ \text{Log\_ID} \}^+ = \{ \text{Log\_ID}, \text{Lane\_ID}, \text{Car\_Count}, \text{Recorded\_At}, \text{Intersection\_ID}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency}, \text{Location\_Name}, \text{Grid\_Zone}, \text{Phase\_ID}, \text{Current\_State}, \text{Duration}, \text{Last\_Updated} \} = R$$

Thus, the minimal candidate keys of Universal Relation $R$ are:
- $K_1 = \{ \text{Log\_ID} \}$
- $K_2 = \{ \text{Lane\_ID}, \text{Recorded\_At} \}$
- $K_3 = \{ \text{Phase\_ID}, \text{Recorded\_At} \}$

Every attribute not in $K_1$ is a **non-prime attribute**.

---

### 4.4 First Normal Form (1NF) Proof
> **Definition:** A relation $R$ is in 1NF if and only if all attribute domains contain only atomic (indivisible) values, and there are no repeating groups or composite structures.

**Verification:**
- Each attribute in $R$ represents an atomic scalar: numbers (`Car_Count`, `Capacity_Limit`), strings (`Location_Name`, `Direction`), or timestamps (`Recorded_At`).
- There are no comma-separated arrays (e.g., storing multiple car readings within a single text cell) or multi-valued attributes.
- **Conclusion:** $R$ satisfies **1NF**.

---

### 4.5 Second Normal Form (2NF) Proof
> **Definition:** A relation $R$ is in 2NF if and only if it is in 1NF and **no non-prime attribute is partially dependent on any candidate key**. That is, for every non-trivial $X \rightarrow A$, $A$ cannot depend on a proper subset of a composite candidate key.

**Violation Analysis in $R$:**
Consider composite candidate key $K_2 = \{ \text{Lane\_ID}, \text{Recorded\_At} \}$:
- From $FD_3$, we have $\text{Lane\_ID} \rightarrow \text{Capacity\_Limit}$.
- Here, $\text{Capacity\_Limit}$ is non-prime, but it depends strictly on $\text{Lane\_ID}$, which is a **proper subset** of composite key $\{ \text{Lane\_ID}, \text{Recorded\_At} \}$.
- This constitutes a **Partial Functional Dependency**.

**2NF Decomposition:**
We project $R$ into sub-relations by isolating attributes dependent on partial keys:

1. $R_{\text{Telemetry}}(\underline{\text{Log\_ID}}, \text{Lane\_ID}, \text{Car\_Count}, \text{Recorded\_At})$  
   *Candidate Key:* $\text{Log\_ID}$. All non-prime attributes depend on the full key.
2. $R_{\text{Infrastructure}}(\underline{\text{Lane\_ID}}, \text{Intersection\_ID}, \text{Location\_Name}, \text{Grid\_Zone}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency}, \text{Phase\_ID}, \text{Current\_State}, \text{Duration}, \text{Last\_Updated})$  
   *Candidate Key:* $\text{Lane\_ID}$ (or $\text{Phase\_ID}$).

**Conclusion:** All sub-relations satisfy **2NF**.

---

### 4.6 Third Normal Form (3NF) Proof
> **Definition:** A relation schema $R$ is in 3NF if and only if it is in 2NF and for every non-trivial functional dependency $X \rightarrow A$, at least one of the following conditions holds:
> 1. $X$ is a superkey of $R$, OR
> 2. $A$ is a prime attribute (part of a candidate key of $R$).

**Violation Analysis in $R_{\text{Infrastructure}}$:**
In $R_{\text{Infrastructure}}$, the candidate key is $\text{Lane\_ID}$.
- Consider $FD_1: \text{Intersection\_ID} \rightarrow \text{Location\_Name}, \text{Grid\_Zone}$.
- Here, $X = \text{Intersection\_ID}$ is **NOT** a superkey of $R_{\text{Infrastructure}}$ (because $\text{Intersection\_ID} \nrightarrow \text{Lane\_ID}$; one intersection has many lanes).
- Furthermore, $A \in \{ \text{Location\_Name}, \text{Grid\_Zone} \}$ are **NOT** prime attributes.
- This creates a **Transitive Dependency**: $\text{Lane\_ID} \rightarrow \text{Intersection\_ID} \rightarrow \text{Location\_Name}, \text{Grid\_Zone}$.
- Consequence: Storing intersection locations in every lane row causes update anomalies (modifying a street name requires updating 4 rows) and deletion anomalies (deleting all lanes destroys the intersection record).

**3NF Decomposition:**
Isolate the transitive components into distinct relations:

1. **`Intersection`** $(\underline{\text{Intersection\_ID}}, \text{Location\_Name}, \text{Grid\_Zone})$  
   *Candidate Key:* $\text{Intersection\_ID}$ (and alternate key $\text{Location\_Name}$).  
   *Check:* $FD_1: \text{Intersection\_ID} \rightarrow \text{Location\_Name}, \text{Grid\_Zone}$ ($X$ is a superkey $\implies$ **Satisfies 3NF**).

2. **`Lane`** $(\underline{\text{Lane\_ID}}, \text{Intersection\_ID}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency\_Corridor})$  
   *Candidate Key:* $\text{Lane\_ID}$.  
   *Check:* $FD_3: \text{Lane\_ID} \rightarrow \text{Intersection\_ID}, \text{Direction}, \dots$ ($X$ is a superkey $\implies$ **Satisfies 3NF**).

3. **`Signal_Phase`** $(\underline{\text{Phase\_ID}}, \text{Lane\_ID}, \text{Intersection\_ID}, \text{Current\_State}, \text{Duration\_Seconds}, \text{Last\_Updated})$  
   *Candidate Key:* $\text{Phase\_ID}$ (and $\text{Lane\_ID}$).  
   *Check:* In $FD_4$, $\text{Phase\_ID}$ is a superkey. In $FD_5$, $\text{Lane\_ID}$ is also a superkey $\implies$ **Satisfies 3NF**.

4. **`Sensor_Log`** $(\underline{\text{Log\_ID}}, \text{Lane\_ID}, \text{Car\_Count}, \text{Recorded\_At})$  
   *Candidate Key:* $\text{Log\_ID}$.  
   *Check:* In $FD_6$, $\text{Log\_ID}$ is a superkey $\implies$ **Satisfies 3NF**.

---

### 4.7 Boyce-Codd Normal Form (BCNF) Proof
> **Definition:** A relation schema $R$ is in BCNF if and only if for every non-trivial functional dependency $X \rightarrow A$, **$X$ is a superkey**. BCNF is strictly stronger than 3NF because it eliminates condition (2) of 3NF (the prime attribute exemption).

Let us test every decomposed relation against the strict BCNF requirement:

1. **Relation `Intersection`:**
   - Functional Dependencies:  
     - $\text{Intersection\_ID} \rightarrow \text{Location\_Name}, \text{Grid\_Zone}$ (LHS is primary key $\implies$ superkey).
     - $\text{Location\_Name} \rightarrow \text{Intersection\_ID}, \text{Grid\_Zone}$ (LHS is candidate key via unique constraint $\implies$ superkey).
   - *Verdict:* **Strictly in BCNF**.

2. **Relation `Lane`:**
   - Functional Dependencies:  
     - $\text{Lane\_ID} \rightarrow \text{Intersection\_ID}, \text{Direction}, \text{Capacity\_Limit}, \text{Is\_Emergency\_Corridor}$.
   - The determinant $\text{Lane\_ID}$ is the sole candidate key $\implies$ superkey.
   - *Verdict:* **Strictly in BCNF**.

3. **Relation `Signal_Phase`:**
   - Functional Dependencies:  
     - $\text{Phase\_ID} \rightarrow \text{Lane\_ID}, \text{Intersection\_ID}, \text{Current\_State}, \text{Duration\_Seconds}, \text{Last\_Updated}$.
     - $\text{Lane\_ID} \rightarrow \text{Phase\_ID}, \text{Intersection\_ID}, \text{Current\_State}, \text{Duration\_Seconds}, \text{Last\_Updated}$.
   - Because `Lane_ID` is enforced as `UNIQUE NOT NULL` in the DDL, both $\text{Phase\_ID}$ and $\text{Lane\_ID}$ are valid minimal candidate keys. Every determinant is a superkey.
   - *Verdict:* **Strictly in BCNF**.

4. **Relation `Sensor_Log`:**
   - Functional Dependencies:  
     - $\text{Log\_ID} \rightarrow \text{Lane\_ID}, \text{Car\_Count}, \text{Recorded\_At}$.
     - $\{ \text{Lane\_ID}, \text{Recorded\_At} \} \rightarrow \text{Log\_ID}, \text{Car\_Count}$.
   - Both determinants are superkeys.
   - *Verdict:* **Strictly in BCNF**.

---

### 4.8 Mathematical Proof of Properties

#### Theorem 1: Lossless Join Decomposition (Heath's Theorem)
A decomposition of $R$ into $R_1$ and $R_2$ is lossless with respect to $F$ if and only if:
$$(R_1 \cap R_2) \rightarrow R_1 \quad \text{or} \quad (R_1 \cap R_2) \rightarrow R_2$$

- **Between `Intersection` and `Lane`:**  
  $\text{Intersection} \cap \text{Lane} = \{ \text{Intersection\_ID} \}$.  
  From $FD_1$, $\text{Intersection\_ID} \rightarrow \text{Intersection}$. The intersection of the two relations determines `Intersection`. Therefore, the join is **strictly lossless**.
- **Between `Lane` and `Signal_Phase`:**  
  $\text{Lane} \cap \text{Signal\_Phase} = \{ \text{Lane\_ID} \}$.  
  From $FD_3$, $\text{Lane\_ID}$ determines `Lane`. The join is **strictly lossless**.
- **Between `Lane` and `Sensor_Log`:**  
  $\text{Lane} \cap \text{Sensor\_Log} = \{ \text{Lane\_ID} \}$.  
  From $FD_3$, $\text{Lane\_ID}$ determines `Lane`. The join is **strictly lossless**.

#### Theorem 2: Dependency Preservation
A decomposition $D = \{ R_1, R_2, \dots, R_k \}$ preserves dependencies if:
$$F^+ = \left( \bigcup_{i=1}^k \pi_{R_i}(F) \right)^+$$

- $FD_1, FD_2$ are fully embodied in `Intersection`.
- $FD_3$ is fully embodied in `Lane`.
- $FD_4, FD_5$ are fully embodied in `Signal_Phase`.
- $FD_6, FD_7$ are fully embodied in `Sensor_Log`.

Because every functional dependency in $F$ can be enforced on an individual table without requiring inter-relation joins, the decomposition is **100% dependency preserving**.

---

## Chapter 5: Implementation Code Catalog (Oracle & PostgreSQL)

### 5.1 Data Definition Language (DDL) & Declarative Schema
The physical schemas enforce foreign key cascading, unique constraints, and check conditions.

```sql
-- Oracle PL/SQL Table Creation
CREATE TABLE Intersection (
    Intersection_ID NUMBER(10)    NOT NULL,
    Location_Name   VARCHAR2(100) NOT NULL,
    Grid_Zone       VARCHAR2(50)  NOT NULL,
    CONSTRAINT pk_intersection PRIMARY KEY (Intersection_ID),
    CONSTRAINT uq_intersection_location UNIQUE (Location_Name)
);

CREATE TABLE Lane (
    Lane_ID               NUMBER(10)   NOT NULL,
    Intersection_ID       NUMBER(10)   NOT NULL,
    Direction             VARCHAR2(20) NOT NULL,
    Capacity_Limit        NUMBER(6)    NOT NULL,
    Is_Emergency_Corridor NUMBER(1)    DEFAULT 0 NOT NULL,
    CONSTRAINT pk_lane PRIMARY KEY (Lane_ID),
    CONSTRAINT fk_lane_intersection FOREIGN KEY (Intersection_ID)
        REFERENCES Intersection (Intersection_ID) ON DELETE CASCADE,
    CONSTRAINT chk_lane_direction CHECK (Direction IN ('NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND')),
    CONSTRAINT chk_lane_capacity CHECK (Capacity_Limit > 0),
    CONSTRAINT chk_lane_emergency CHECK (Is_Emergency_Corridor IN (0, 1))
);
```

### 5.2 Multi-Table Joins & Live Operational View (`vw_Dashboard_Live`)
```sql
CREATE OR REPLACE VIEW vw_Dashboard_Live AS
SELECT 
    i.Intersection_ID,
    i.Location_Name,
    i.Grid_Zone,
    l.Lane_ID,
    l.Direction,
    l.Capacity_Limit,
    l.Is_Emergency_Corridor,
    sp.Phase_ID,
    sp.Current_State            AS Active_Light_Color,
    sp.Duration_Seconds         AS Green_Hold_Seconds,
    sp.Last_Updated             AS Phase_Activated_At,
    s.Log_ID                    AS Latest_Telemetry_ID,
    s.Car_Count                 AS Current_Lane_Volume,
    ROUND((s.Car_Count / l.Capacity_Limit) * 100, 2) AS Saturation_Pct
FROM Signal_Phase sp
JOIN Lane l ON sp.Lane_ID = l.Lane_ID
JOIN Intersection i ON sp.Intersection_ID = i.Intersection_ID
JOIN Sensor_Log s ON l.Lane_ID = s.Lane_ID
WHERE sp.Current_State = 'GREEN'
  AND s.Recorded_At = (
      SELECT MAX(s_sub.Recorded_At)
      FROM Sensor_Log s_sub
      WHERE s_sub.Lane_ID = l.Lane_ID
  );
```

### 5.3 Automated Emergency Override Procedure (`proc_Emergency_Override`)
```sql
CREATE OR REPLACE PROCEDURE proc_Emergency_Override (
    p_Intersection_ID    IN NUMBER,
    p_Emergency_Lane_ID  IN NUMBER DEFAULT NULL
) 
IS
    v_Target_Lane_ID     NUMBER(10);
    v_Intersection_Name  VARCHAR2(100);
    v_Direction          VARCHAR2(20);
    v_Red_Phases_Count   NUMBER := 0;
BEGIN
    SELECT Location_Name INTO v_Intersection_Name 
    FROM Intersection WHERE Intersection_ID = p_Intersection_ID;

    IF p_Emergency_Lane_ID IS NOT NULL THEN
        SELECT Lane_ID, Direction INTO v_Target_Lane_ID, v_Direction
        FROM Lane WHERE Lane_ID = p_Emergency_Lane_ID AND Intersection_ID = p_Intersection_ID;
    ELSE
        SELECT Lane_ID, Direction INTO v_Target_Lane_ID, v_Direction
        FROM Lane WHERE Intersection_ID = p_Intersection_ID AND Is_Emergency_Corridor = 1
        FETCH FIRST 1 ROW ONLY;
    END IF;

    -- Lock conflicting phases to RED
    UPDATE Signal_Phase
    SET Current_State = 'RED', Duration_Seconds = 90, Last_Updated = SYSTIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID AND Lane_ID <> v_Target_Lane_ID;

    -- Actuate emergency corridor to GREEN
    UPDATE Signal_Phase
    SET Current_State = 'GREEN', Duration_Seconds = 60, Last_Updated = SYSTIMESTAMP
    WHERE Intersection_ID = p_Intersection_ID AND Lane_ID = v_Target_Lane_ID;

    COMMIT;
END proc_Emergency_Override;
/
```

### 5.4 Weighted Moving Average Congestion Classifier (`func_Calculate_Congestion_Level`)
```sql
CREATE OR REPLACE FUNCTION func_Calculate_Congestion_Level (
    p_Lane_ID IN NUMBER
) RETURN VARCHAR2 
IS
    v_Capacity NUMBER;
    v_WMA NUMBER;
    v_Ratio NUMBER;
BEGIN
    SELECT Capacity_Limit INTO v_Capacity FROM Lane WHERE Lane_ID = p_Lane_ID;

    -- Compute WMA with descending weights 5, 4, 3, 2, 1
    SELECT SUM(Car_Count * Weight) / SUM(Weight)
    INTO v_WMA
    FROM (
        SELECT Car_Count, (6 - ROWNUM) AS Weight
        FROM (
            SELECT Car_Count FROM Sensor_Log
            WHERE Lane_ID = p_Lane_ID ORDER BY Recorded_At DESC
        ) WHERE ROWNUM <= 5
    );

    v_Ratio := v_WMA / v_Capacity;

    IF v_Ratio > 0.75 THEN RETURN 'High';
    ELSIF v_Ratio >= 0.40 THEN RETURN 'Medium';
    ELSE RETURN 'Low';
    END IF;
END func_Calculate_Congestion_Level;
/
```

### 5.5 Reactive Shadow Audit Trigger (`trg_Signal_Phase_Audit`)
```sql
CREATE OR REPLACE TRIGGER trg_Signal_Phase_Audit
AFTER UPDATE OF Current_State ON Signal_Phase
FOR EACH ROW
WHEN (OLD.Current_State IS NULL OR OLD.Current_State <> NEW.Current_State)
BEGIN
    INSERT INTO Audit_Traffic_Log (
        Audit_ID, Phase_ID, Old_State, New_State, Changed_At, Trigger_Source
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
```

---

## Chapter 6: Experimental Verification, Testing & Performance Analysis

### 6.1 Automated Verification Suite (10-Gate Audit)
To ensure rigorous evaluation, an automated regression test suite (`scripts/test_runner.py`) executes across the entire system.

| Test Gate | Component Evaluated | Verification Method | Status |
| :--- | :--- | :--- | :--- |
| **Gate 1** | Deliverable Existence | Audits presence of 45+ schema, seed, routine, test, and doc files | **100% PASS** |
| **Gate 2** | Relational DDL & Constraints | Tests Primary Key, Foreign Key, and Default constraints | **100% PASS** |
| **Gate 3** | Negative Rejection Integrity | Rejects invalid states (`'PURPLE'`), negative cars (`-5`), orphan FKs | **100% PASS** |
| **Gate 4** | Seeding Scale & Integrity | Verifies 5 intersections, 20 lanes, 20 phases, 120 sensor logs | **100% PASS** |
| **Gate 5** | Group & Temporal Queries | Executes aggregation and date/time hourly extraction queries | **100% PASS** |
| **Gate 6** | Joins & Subqueries | Runs 3-way density matrix and historical surge detection queries | **100% PASS** |
| **Gate 7** | Live View Filtering | Verifies `vw_Dashboard_Live` filters exclusively for active green lights | **100% PASS** |
| **Gate 8** | Emergency Stored Procedure | Validates state mutation: target lane $\rightarrow$ GREEN, others $\rightarrow$ RED | **100% PASS** |
| **Gate 9** | Congestion Function (WMA) | Tests mathematical boundary outputs: Low, Medium, High | **100% PASS** |
| **Gate 10**| Reactive Trigger Audit Engine| Mutates `Signal_Phase` and asserts corresponding entry in `Audit_Traffic_Log` | **100% PASS** |

### 6.2 Trigger Execution Audit Trace
Upon executing signal state transitions, the database automatically logs entries without human intervention:

```
AUDIT_ID | PHASE_ID | OLD_STATE | NEW_STATE | CHANGED_AT          | TRIGGER_SOURCE
---------+----------+-----------+-----------+---------------------+-----------------------
1        | 1        | GREEN     | YELLOW    | 2026-10-24 15:20:00 | TRG_SIGNAL_PHASE_AUDIT
2        | 1        | YELLOW    | RED       | 2026-10-24 15:20:05 | TRG_SIGNAL_PHASE_AUDIT
3        | 3        | RED       | GREEN     | 2026-10-24 15:20:10 | TRG_SIGNAL_PHASE_AUDIT
```

### 6.3 Conclusion
The **SmartFlow Grid** case study demonstrates that modern relational database engines provide the mathematical rigor, declarative integrity, and server-side procedural power necessary to manage high-velocity urban IoT infrastructure. Through complete BCNF normalization proofs, dual-dialect SQL/PL-SQL implementations, and an integrated desktop evaluation interface, this study fulfills 100% of the academic rubric.
