// ============================================================================
// SmartFlow Grid: 60 FPS HiDPI 2D Traffic Simulation Canvas Engine
// Architecture: Physics-based queueing, smooth cross-junction departure,
//               and 1-to-1 database synchronization.
// ============================================================================

let canvas = null;
let ctx = null;
let container = null;
let animFrameId = null;
let lastTimestamp = 0;

let dpr = 1;
let width = 0;
let height = 0;
let centerX = 0;
let centerY = 0;
const ROAD_WIDTH = 92;
const HALF_ROAD = ROAD_WIDTH / 2; // 46px
const LANE_OFFSET = 23;           // Center of each 46px lane
const CAR_LENGTH = 20;
const CAR_WIDTH = 10;
const SLOT_SPACING = 28;
const STOP_MARGIN = 14;

let simRunning = true;
let simSpeed = 1;
let currentNodeId = 1;
let emergencyActive = false;
let emergencyLaneId = null;

let vehicles = [];
let nextVehicleId = 1;

const CHASSIS_COLORS = [
  '#2563eb', // Cobalt Blue
  '#059669', // Emerald Green
  '#d97706', // Amber Gold
  '#7c3aed', // Royal Violet
  '#0284c7', // Sky Cyan
  '#e11d48'  // Crimson Rose
];

// ----------------------------------------------------------------------------
// Initialization & HiDPI Setup
// ----------------------------------------------------------------------------
export function initTrafficSimulator(canvasEl, containerEl) {
  canvas = canvasEl;
  container = containerEl;
  ctx = canvas.getContext('2d');

  handleResize();

  const resizeObserver = new ResizeObserver(() => {
    handleResize();
  });
  resizeObserver.observe(container);

  lastTimestamp = performance.now();
  if (animFrameId) cancelAnimationFrame(animFrameId);
  animFrameId = requestAnimationFrame(renderLoop);
}

function handleResize() {
  if (!canvas || !container) return;
  const rect = container.getBoundingClientRect();
  dpr = window.devicePixelRatio || 1;

  width = rect.width;
  height = rect.height;
  centerX = width / 2;
  centerY = height / 2;

  canvas.width = Math.round(width * dpr);
  canvas.height = Math.round(height * dpr);
  canvas.style.width = `${width}px`;
  canvas.style.height = `${height}px`;
}

export function setSimRunningState(running) {
  simRunning = running;
}

export function setSimSpeedMultiplier(speed) {
  simSpeed = Math.max(1, speed);
}

// ----------------------------------------------------------------------------
// Vehicle Factory
// ----------------------------------------------------------------------------
function createVehicle(laneKey, slotIndex, laneId, isEmergency = false, startAtEntrance = false) {
  const isAmbulance = isEmergency;
  const color = isAmbulance ? '#ffffff' : CHASSIS_COLORS[Math.floor(Math.random() * CHASSIS_COLORS.length)];

  const slotPos = getSlotPosition(laneKey, slotIndex);
  const entrancePos = getEntrancePosition(laneKey);

  const initialX = startAtEntrance ? entrancePos.x : slotPos.x;
  const initialY = startAtEntrance ? entrancePos.y : slotPos.y;

  return {
    id: nextVehicleId++,
    laneKey,
    laneId,
    slotIndex,
    state: startAtEntrance ? 'approaching' : 'queued',
    x: initialX,
    y: initialY,
    targetX: slotPos.x,
    targetY: slotPos.y,
    angle: slotPos.angle,
    speed: 0,
    maxSpeed: isAmbulance ? 160 : 90,
    isAmbulance,
    color,
    brakeLights: true,
    departTargetX: 0,
    departTargetY: 0
  };
}

// ----------------------------------------------------------------------------
// Coordinate Geometry & Lane Vectors (Geographically Aligned to Approaches)
// ----------------------------------------------------------------------------
function getSlotPosition(laneKey, slotIndex) {
  const dist = HALF_ROAD + STOP_MARGIN + (slotIndex * SLOT_SPACING);

  switch (laneKey) {
    case 'NORTHBOUND': // North Approach (from North at top, heading South)
      return {
        x: centerX - LANE_OFFSET,
        y: centerY - dist,
        angle: Math.PI / 2
      };
    case 'SOUTHBOUND': // South Approach (from South at bottom, heading North)
      return {
        x: centerX + LANE_OFFSET,
        y: centerY + dist,
        angle: -Math.PI / 2
      };
    case 'EASTBOUND': // East Approach (from East at right, heading West)
      return {
        x: centerX + dist,
        y: centerY - LANE_OFFSET,
        angle: Math.PI
      };
    case 'WESTBOUND': // West Approach (from West at left, heading East)
      return {
        x: centerX - dist,
        y: centerY + LANE_OFFSET,
        angle: 0
      };
    default:
      return { x: centerX, y: centerY, angle: 0 };
  }
}

function getEntrancePosition(laneKey) {
  switch (laneKey) {
    case 'NORTHBOUND': // Enters from top
      return { x: centerX - LANE_OFFSET, y: -30 };
    case 'SOUTHBOUND': // Enters from bottom
      return { x: centerX + LANE_OFFSET, y: height + 30 };
    case 'EASTBOUND': // Enters from right
      return { x: width + 30, y: centerY - LANE_OFFSET };
    case 'WESTBOUND': // Enters from left
      return { x: -30, y: centerY + LANE_OFFSET };
    default:
      return { x: centerX, y: centerY };
  }
}

function getExitPosition(laneKey) {
  switch (laneKey) {
    case 'NORTHBOUND': // Exits through south bottom
      return { x: centerX - LANE_OFFSET, y: height + 50 };
    case 'SOUTHBOUND': // Exits through north top
      return { x: centerX + LANE_OFFSET, y: -50 };
    case 'EASTBOUND': // Exits through west left
      return { x: -50, y: centerY - LANE_OFFSET };
    case 'WESTBOUND': // Exits through east right
      return { x: width + 50, y: centerY + LANE_OFFSET };
    default:
      return { x: centerX, y: centerY };
  }
}

// ----------------------------------------------------------------------------
// State Synchronization with Relational Database
// ----------------------------------------------------------------------------
export function syncSimulatorWithLanes(lanes, nodeId, isEmerg, emergLaneId) {
  emergencyActive = isEmerg;
  emergencyLaneId = emergLaneId;

  // Instant re-seed if node tab was changed
  if (nodeId !== currentNodeId) {
    currentNodeId = nodeId;
    reseedNode(lanes, nodeId);
    return;
  }

  const directions = ['NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND'];

  directions.forEach(dir => {
    const lane = lanes.find(l => l.Intersection_ID === nodeId && l.Direction === dir);
    if (!lane) return;

    const dbCount = lane.Current_Car_Count || 0;
    const isGreen = lane.Current_State === 'GREEN';

    // Current active non-departing cars in this lane
    const activeInLane = vehicles.filter(v => v.laneId === lane.Lane_ID && v.state !== 'departing');

    if (activeInLane.length > dbCount) {
      // Queue reduced: Front cars transition to 'departing'
      const numDepart = activeInLane.length - dbCount;
      const exitPos = getExitPosition(dir);

      for (let i = 0; i < numDepart; i++) {
        const car = activeInLane[i];
        if (car) {
          car.state = 'departing';
          car.brakeLights = false;
          car.departTargetX = exitPos.x;
          car.departTargetY = exitPos.y;
        }
      }
    } else if (activeInLane.length < dbCount) {
      // Arrivals: spawn new cars entering from road approach
      const numAdd = dbCount - activeInLane.length;
      const currentCount = activeInLane.length;

      for (let i = 0; i < numAdd; i++) {
        const slotIdx = currentCount + i;
        const isEmerg = emergencyActive && emergencyLaneId === lane.Lane_ID && (slotIdx === 0);
        const newCar = createVehicle(dir, slotIdx, lane.Lane_ID, isEmerg, true);
        vehicles.push(newCar);
      }
    }

    // Re-index remaining queued/approaching cars so they advance forward smoothly
    const remainingActive = vehicles.filter(v => v.laneId === lane.Lane_ID && v.state !== 'departing');
    remainingActive.forEach((car, idx) => {
      car.slotIndex = idx;
      const target = getSlotPosition(dir, idx);
      car.targetX = target.x;
      car.targetY = target.y;
      car.brakeLights = (lane.Current_State === 'RED') || (idx === 0 && !isGreen);
      const shouldBeAmbulance = emergencyActive && emergencyLaneId === lane.Lane_ID && (idx === 0);
      car.isAmbulance = shouldBeAmbulance;
      if (shouldBeAmbulance) car.color = '#ffffff';
    });
  });
}

function reseedNode(lanes, nodeId) {
  vehicles = [];
  const nodeLanes = lanes.filter(l => l.Intersection_ID === nodeId);

  nodeLanes.forEach(lane => {
    const count = lane.Current_Car_Count || 0;
    const isEmergLane = emergencyActive && emergencyLaneId === lane.Lane_ID;

    for (let i = 0; i < count; i++) {
      const isCarAmbulance = (isEmergLane && i === 0);
      const v = createVehicle(lane.Direction, i, lane.Lane_ID, isCarAmbulance, false);
      vehicles.push(v);
    }
  });
}

// ----------------------------------------------------------------------------
// Physics & Animation Update Loop (60 FPS)
// ----------------------------------------------------------------------------
function updatePhysics(dt) {
  if (!simRunning) return;

  const effectiveDt = dt * simSpeed;

  vehicles.forEach(v => {
    if (v.state === 'departing') {
      // Accelerate through intersection towards exit
      const dx = v.departTargetX - v.x;
      const dy = v.departTargetY - v.y;
      const dist = Math.hypot(dx, dy);

      if (dist < 10) {
        v.markedForDeletion = true;
        return;
      }

      v.speed = Math.min(v.maxSpeed * 1.5, v.speed + 140 * effectiveDt);
      const move = v.speed * effectiveDt;
      v.x += (dx / dist) * move;
      v.y += (dy / dist) * move;
      v.brakeLights = false;
    } else {
      // Approaching or queued: move towards target slot
      const dx = v.targetX - v.x;
      const dy = v.targetY - v.y;
      const dist = Math.hypot(dx, dy);

      if (dist > 1) {
        v.speed = Math.min(v.maxSpeed, Math.max(25, dist * 3.5));
        const move = Math.min(dist, v.speed * effectiveDt);
        v.x += (dx / dist) * move;
        v.y += (dy / dist) * move;
        v.brakeLights = false;
      } else {
        v.x = v.targetX;
        v.y = v.targetY;
        v.speed = 0;
        v.state = 'queued';
        v.brakeLights = true;
      }
    }
  });

  // Clean up departed vehicles that left canvas
  vehicles = vehicles.filter(v => !v.markedForDeletion);
}

// ----------------------------------------------------------------------------
// Rendering Pipeline
// ----------------------------------------------------------------------------
function renderLoop(timestamp) {
  const dt = Math.min(0.1, (timestamp - lastTimestamp) / 1000);
  lastTimestamp = timestamp;

  updatePhysics(dt);
  draw(timestamp);

  animFrameId = requestAnimationFrame(renderLoop);
}

function draw(timestamp) {
  if (!ctx || width === 0 || height === 0) return;

  ctx.save();
  ctx.scale(dpr, dpr);

  // 1. Clear Stage Backdrop (Light Architectural CAD Grid)
  ctx.fillStyle = '#f1f5f9';
  ctx.fillRect(0, 0, width, height);

  // Subtle architectural grid lines
  ctx.save();
  ctx.strokeStyle = '#e2e8f0';
  ctx.lineWidth = 1;
  const gridSize = 32;
  ctx.beginPath();
  for (let x = 0; x < width; x += gridSize) {
    ctx.moveTo(x, 0);
    ctx.lineTo(x, height);
  }
  for (let y = 0; y < height; y += gridSize) {
    ctx.moveTo(0, y);
    ctx.lineTo(width, y);
  }
  ctx.stroke();
  ctx.restore();

  // 2. Draw Tarmac Roads & Markings (Sleek Monochrome Aerial)
  drawRoadInfrastructure();

  // 3. Draw Vehicles
  drawVehicles(timestamp);

  // 4. Draw Center Junction Hub Badge
  drawCenterHub();

  ctx.restore();
}

// ----------------------------------------------------------------------------
// Road & Crossroad Markings (Sleek Monochrome Aerial)
// ----------------------------------------------------------------------------
function drawRoadInfrastructure() {
  // Muted Cool Gray Tarmac Asphalt Roads (#334155)
  ctx.fillStyle = '#334155';

  // Vertical Road
  ctx.fillRect(centerX - HALF_ROAD, 0, ROAD_WIDTH, height);
  // Horizontal Road
  ctx.fillRect(0, centerY - HALF_ROAD, width, ROAD_WIDTH);

  // Road Borders (Concrete Kerbs)
  ctx.strokeStyle = '#94a3b8';
  ctx.lineWidth = 2;

  // Vertical road edges
  ctx.beginPath();
  ctx.moveTo(centerX - HALF_ROAD, 0);
  ctx.lineTo(centerX - HALF_ROAD, centerY - HALF_ROAD);
  ctx.moveTo(centerX - HALF_ROAD, centerY + HALF_ROAD);
  ctx.lineTo(centerX - HALF_ROAD, height);

  ctx.moveTo(centerX + HALF_ROAD, 0);
  ctx.lineTo(centerX + HALF_ROAD, centerY - HALF_ROAD);
  ctx.moveTo(centerX + HALF_ROAD, centerY + HALF_ROAD);
  ctx.lineTo(centerX + HALF_ROAD, height);

  // Horizontal road edges
  ctx.moveTo(0, centerY - HALF_ROAD);
  ctx.lineTo(centerX - HALF_ROAD, centerY - HALF_ROAD);
  ctx.moveTo(centerX + HALF_ROAD, centerY - HALF_ROAD);
  ctx.lineTo(width, centerY - HALF_ROAD);

  ctx.moveTo(0, centerY + HALF_ROAD);
  ctx.lineTo(centerX - HALF_ROAD, centerY + HALF_ROAD);
  ctx.moveTo(centerX + HALF_ROAD, centerY + HALF_ROAD);
  ctx.lineTo(width, centerY + HALF_ROAD);
  ctx.stroke();

  // Amber Dashed Centerlines (Dividing 2-way traffic)
  ctx.save();
  ctx.strokeStyle = '#f59e0b';
  ctx.lineWidth = 1.5;
  ctx.setLineDash([8, 8]);

  // North branch centerline
  ctx.beginPath();
  ctx.moveTo(centerX, 0);
  ctx.lineTo(centerX, centerY - HALF_ROAD);
  ctx.stroke();

  // South branch centerline
  ctx.beginPath();
  ctx.moveTo(centerX, centerY + HALF_ROAD);
  ctx.lineTo(centerX, height);
  ctx.stroke();

  // West branch centerline
  ctx.beginPath();
  ctx.moveTo(0, centerY);
  ctx.lineTo(centerX - HALF_ROAD, centerY);
  ctx.stroke();

  // East branch centerline
  ctx.beginPath();
  ctx.moveTo(centerX + HALF_ROAD, centerY);
  ctx.lineTo(width, centerY);
  ctx.stroke();
  ctx.restore();

  // Detailed Pedestrian Crosswalks (Crisp Zebra Stripes)
  drawCrosswalk(centerX - HALF_ROAD, centerY - HALF_ROAD - 10, ROAD_WIDTH, 8, true);
  drawCrosswalk(centerX - HALF_ROAD, centerY + HALF_ROAD + 2, ROAD_WIDTH, 8, true);
  drawCrosswalk(centerX - HALF_ROAD - 10, centerY - HALF_ROAD, 8, ROAD_WIDTH, false);
  drawCrosswalk(centerX + HALF_ROAD + 2, centerY - HALF_ROAD, 8, ROAD_WIDTH, false);

  // Solid White Stop Lines (Across incoming lane half only)
  ctx.strokeStyle = '#ffffff';
  ctx.lineWidth = 3;

  ctx.beginPath();
  // North approach stop line (left half of vertical road)
  ctx.moveTo(centerX - HALF_ROAD, centerY - HALF_ROAD);
  ctx.lineTo(centerX, centerY - HALF_ROAD);

  // South approach stop line (right half of vertical road)
  ctx.moveTo(centerX, centerY + HALF_ROAD);
  ctx.lineTo(centerX + HALF_ROAD, centerY + HALF_ROAD);

  // West approach stop line (bottom half of horizontal road)
  ctx.moveTo(centerX - HALF_ROAD, centerY);
  ctx.lineTo(centerX - HALF_ROAD, centerY + HALF_ROAD);

  // East approach stop line (top half of horizontal road)
  ctx.moveTo(centerX + HALF_ROAD, centerY - HALF_ROAD);
  ctx.lineTo(centerX + HALF_ROAD, centerY);
  ctx.stroke();
}

function drawCrosswalk(x, y, w, h, isHorizontal) {
  ctx.save();
  ctx.fillStyle = 'rgba(255, 255, 255, 0.85)';
  const stripe = 5;
  const gap = 3;

  if (isHorizontal) {
    for (let cx = x + 3; cx < x + w - 3; cx += (stripe + gap)) {
      ctx.fillRect(cx, y, stripe, h);
    }
  } else {
    for (let cy = y + 3; cy < y + h - 3; cy += (stripe + gap)) {
      ctx.fillRect(x, cy, w, stripe);
    }
  }
  ctx.restore();
}

// ----------------------------------------------------------------------------
// Vehicle Rendering (Cybernetic Sprites & Headlight Cones)
// ----------------------------------------------------------------------------
function drawVehicles(timestamp) {
  vehicles.forEach(v => {
    ctx.save();
    ctx.translate(v.x, v.y);
    ctx.rotate(v.angle);

    // 1. Headlight Cones (Forward beam projection)
    ctx.save();
    const beamGrad = ctx.createLinearGradient(0, 0, 45, 0);
    beamGrad.addColorStop(0, 'rgba(224, 242, 254, 0.28)');
    beamGrad.addColorStop(1, 'rgba(224, 242, 254, 0)');
    ctx.fillStyle = beamGrad;

    ctx.beginPath();
    ctx.moveTo(CAR_LENGTH / 2, -CAR_WIDTH / 3);
    ctx.lineTo(CAR_LENGTH / 2 + 40, -CAR_WIDTH);
    ctx.lineTo(CAR_LENGTH / 2 + 40, CAR_WIDTH);
    ctx.lineTo(CAR_LENGTH / 2, CAR_WIDTH / 3);
    ctx.closePath();
    ctx.fill();
    ctx.restore();

    // 2. Ambulance Flashing Strobe Aura
    if (v.isAmbulance) {
      const flash = Math.sin(timestamp * 0.015);
      const strobeColor = flash > 0 ? 'rgba(239, 68, 68, 0.45)' : 'rgba(56, 189, 248, 0.45)';

      ctx.save();
      ctx.beginPath();
      ctx.arc(0, 0, 22, 0, Math.PI * 2);
      ctx.fillStyle = strobeColor;
      ctx.fill();
      ctx.restore();
    }

    // 3. Vehicle Chassis (Rounded cybernetic body)
    ctx.save();
    ctx.shadowColor = 'rgba(0, 0, 0, 0.6)';
    ctx.shadowBlur = 6;
    ctx.shadowOffsetY = 2;

    ctx.fillStyle = v.color;
    drawRoundedRect(ctx, -CAR_LENGTH / 2, -CAR_WIDTH / 2, CAR_LENGTH, CAR_WIDTH, 3);
    ctx.fill();

    // Thin accent border
    ctx.strokeStyle = v.isAmbulance ? '#ef4444' : 'rgba(255, 255, 255, 0.3)';
    ctx.lineWidth = 1;
    ctx.stroke();
    ctx.restore();

    // 4. Windshield & Roof Canopy
    ctx.fillStyle = '#0f172a';
    drawRoundedRect(ctx, -CAR_LENGTH * 0.1, -CAR_WIDTH * 0.35, CAR_LENGTH * 0.45, CAR_WIDTH * 0.7, 2);
    ctx.fill();

    // 5. Taillights (Red glow on braking)
    ctx.save();
    const tailY = CAR_WIDTH * 0.32;
    const isBraking = v.brakeLights;
    const tailColor = isBraking ? '#ef4444' : '#7f1d1d';

    if (isBraking) {
      ctx.shadowColor = '#ef4444';
      ctx.shadowBlur = 8;
    }

    ctx.fillStyle = tailColor;
    ctx.fillRect(-CAR_LENGTH / 2, -tailY - 1, 2, 2.5);
    ctx.fillRect(-CAR_LENGTH / 2, tailY - 1, 2, 2.5);
    ctx.restore();

    // 6. Ambulance Emergency Cross/Strobe Details
    if (v.isAmbulance) {
      ctx.fillStyle = '#ef4444';
      // Red Cross on roof
      ctx.fillRect(-1.5, -4, 3, 8);
      ctx.fillRect(-4, -1.5, 8, 3);

      // Flashing Rooftop Beacon
      const isRedBeacon = Math.sin(timestamp * 0.02) > 0;
      ctx.fillStyle = isRedBeacon ? '#ef4444' : '#38bdf8';
      ctx.beginPath();
      ctx.arc(0, 0, 2.5, 0, Math.PI * 2);
      ctx.fill();
    }

    ctx.restore();
  });
}

function drawRoundedRect(c, x, y, w, h, r) {
  c.beginPath();
  c.moveTo(x + r, y);
  c.lineTo(x + w - r, y);
  c.quadraticCurveTo(x + w, y, x + w, y + r);
  c.lineTo(x + w, y + h - r);
  c.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  c.lineTo(x + r, y + h);
  c.quadraticCurveTo(x, y + h, x, y + h - r);
  c.lineTo(x, y + r);
  c.quadraticCurveTo(x, y, x + r, y);
  c.closePath();
}

// ----------------------------------------------------------------------------
// Center Junction Hub
// ----------------------------------------------------------------------------
function drawCenterHub() {
  ctx.save();
  ctx.translate(centerX, centerY);

  // Clean white circular badge with soft elevation shadow
  ctx.beginPath();
  ctx.arc(0, 0, 20, 0, Math.PI * 2);
  ctx.fillStyle = '#ffffff';
  ctx.shadowColor = 'rgba(15, 23, 42, 0.15)';
  ctx.shadowBlur = 8;
  ctx.shadowOffsetY = 2;
  ctx.fill();

  // Cobalt border ring
  ctx.strokeStyle = '#2563eb';
  ctx.lineWidth = 2;
  ctx.stroke();

  // Text inside hub
  ctx.font = '700 9px JetBrains Mono, monospace';
  ctx.fillStyle = '#0f172a';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText(`N${currentNodeId}`, 0, 0);

  ctx.restore();
}
