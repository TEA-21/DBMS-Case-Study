// ============================================================================
// SmartFlow Grid — Enterprise Municipal Traffic Operations Console
// Client Controller (Adaptive Actuation • Dynamic Speed • Locked Viewport)
// ============================================================================

import {
  initTrafficSimulator,
  syncSimulatorWithLanes,
  setSimRunningState,
  setSimSpeedMultiplier
} from './traffic-simulator.js';

let simRunning = true;
let simSpeed = 1; // 1x, 2x, 5x
let activeNodeId = 1;

let emergencyActive = false;
let emergencyNodeId = null;
let emergencyLaneId = null;

let state = {
  intersections: [],
  lanes: []
};

let dashboardRows = [];
let congestionList = [];
let traceLogs = [];

let selectedCorridorByNode = {};
let dropdownCurrentNodeId = null;

let telemetryTimeout = null;
let cycleTimeout = null;
let roundRobinIndex = 1;

// ----------------------------------------------------------------------------
// Initialization
// ----------------------------------------------------------------------------
document.addEventListener('DOMContentLoaded', async () => {
  setupEventListeners();
  startClock();

  // Initialize HiDPI 2D Traffic Simulation Canvas
  const canvasEl = document.getElementById('traffic-canvas');
  const containerEl = document.getElementById('crossroad-stage-container');
  if (canvasEl && containerEl) {
    initTrafficSimulator(canvasEl, containerEl);
  }

  await refreshAll();

  startSimulationLoops();
  logTrace('SYSTEM', 'SmartFlow Grid Adaptive IoT Operations Engine online. SQLite connected.');
});

function startClock() {
  const clockEl = document.getElementById('live-municipal-clock');
  if (!clockEl) return;
  function updateTime() {
    const now = new Date();
    clockEl.textContent = now.toLocaleTimeString('en-US', { hour12: false });
  }
  updateTime();
  setInterval(updateTime, 1000);
}

// ----------------------------------------------------------------------------
// Event Listeners
// ----------------------------------------------------------------------------
function setupEventListeners() {
  // Sim play/pause
  const btnToggleSim = document.getElementById('btn-toggle-sim');
  const lblSimState = document.getElementById('lbl-sim-state');
  const iconSimState = document.getElementById('icon-sim-state');

  btnToggleSim.addEventListener('click', () => {
    simRunning = !simRunning;
    setSimRunningState(simRunning);
    lblSimState.textContent = simRunning ? 'PAUSE' : 'RESUME';
    iconSimState.textContent = simRunning ? '❚❚' : '▶';
    logTrace('OPERATOR', simRunning ? 'Simulation resumed.' : 'Simulation paused by operator.');

    if (simRunning) {
      scheduleTelemetryLoop();
      scheduleCycleLoop();
    } else {
      if (telemetryTimeout) clearTimeout(telemetryTimeout);
      if (cycleTimeout) clearTimeout(cycleTimeout);
    }
  });

  // Advance cycle manually (+1 Tick)
  document.getElementById('btn-advance-cycle').addEventListener('click', async () => {
    await cycleSignal(activeNodeId);
    await runTelemetryTick();
    logTrace('SQL', `MANUAL TICK: Stepped signal phase & telemetry on Node ${activeNodeId}.`);
  });

  // Speed chips: 1x, 2x, 5x (Fully dynamic rescheduling)
  document.querySelectorAll('.btn-chip').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.btn-chip').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      simSpeed = parseInt(btn.dataset.speed) || 1;
      setSimSpeedMultiplier(simSpeed);

      const tInterval = Math.max(300, Math.round(2500 / simSpeed));
      const cInterval = Math.max(500, Math.round(4500 / simSpeed));
      logTrace('OPERATOR', `Simulation acceleration adjusted to ${simSpeed}x (Telemetry: ${tInterval}ms, Cycles: ${cInterval}ms).`);

      if (simRunning) {
        scheduleTelemetryLoop();
        scheduleCycleLoop();
      }
    });
  });

  // Target Priority Corridor Dropdown change listener
  const laneSelectEl = document.getElementById('override-target-lane');
  if (laneSelectEl) {
    laneSelectEl.addEventListener('change', (e) => {
      const val = parseInt(e.target.value);
      if (!isNaN(val)) {
        selectedCorridorByNode[activeNodeId] = val;
        logTrace('OPERATOR', `Target corridor for Node ${activeNodeId} selected: Lane #${val}.`);
      }
    });
  }

  // Emergency override action
  document.getElementById('btn-engage-emergency').addEventListener('click', async () => {
    const laneSelect = document.getElementById('override-target-lane');
    const targetLane = laneSelect.value ? parseInt(laneSelect.value) : null;
    await engageEmergency(activeNodeId, targetLane);
  });

  // Clear emergency override
  document.getElementById('btn-clear-emergency').addEventListener('click', async () => {
    const targetNode = emergencyNodeId || activeNodeId;
    await clearEmergency(targetNode);
  });

  // Metrics Card Tabs
  document.querySelectorAll('.metrics-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.metrics-tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.metrics-pane').forEach(p => p.classList.remove('active'));
      tab.classList.add('active');
      document.getElementById(tab.dataset.tab).classList.add('active');
    });
  });

  // Drawer Toggle
  const drawer = document.getElementById('db-drawer');
  const backdrop = document.getElementById('drawer-backdrop');
  const btnToggleDrawer = document.getElementById('btn-toggle-drawer');
  const btnCloseDrawer = document.getElementById('btn-close-drawer');

  btnToggleDrawer.addEventListener('click', () => {
    drawer.classList.remove('closed');
    backdrop.classList.remove('hidden');
  });

  const closeDrawer = () => {
    drawer.classList.add('closed');
    backdrop.classList.add('hidden');
  };
  btnCloseDrawer.addEventListener('click', closeDrawer);
  backdrop.addEventListener('click', closeDrawer);

  // Drawer Tabs
  document.querySelectorAll('.drawer-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.drawer-tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-pane').forEach(p => p.classList.remove('active'));
      tab.classList.add('active');
      document.getElementById(tab.dataset.tab).classList.add('active');
    });
  });

}

// ----------------------------------------------------------------------------
// API State Calls
// ----------------------------------------------------------------------------
async function refreshAll() {
  await fetchState();
  await fetchDashboardLive();
  await fetchCongestionWMA();
  await fetchAuditLog();
}

async function fetchState() {
  try {
    const res = await fetch('/api/state');
    state = await res.json();
    renderNodeTabs();
    renderCrossroadStage();
    // Pass false so existing dropdown selection is NOT clobbered!
    updateCorridorDropdown(activeNodeId, false);
    renderEmergencyStatus();
  } catch (err) {
    console.error('fetchState error:', err);
  }
}

async function fetchDashboardLive() {
  try {
    const res = await fetch('/api/dashboard-live');
    dashboardRows = await res.json();
    renderDashboardTable(dashboardRows);
  } catch (err) {
    console.error('fetchDashboardLive error:', err);
  }
}

async function fetchCongestionWMA() {
  try {
    const res = await fetch('/api/congestion-wma');
    congestionList = await res.json();
    renderCongestionRanking(congestionList);
    renderCrossroadStage();
  } catch (err) {
    console.error('fetchCongestionWMA error:', err);
  }
}

async function fetchAuditLog() {
  try {
    const res = await fetch('/api/audit-log');
    const logs = await res.json();
    renderAuditTable(logs);
  } catch (err) {
    console.error('fetchAuditLog error:', err);
  }
}


// ----------------------------------------------------------------------------
// Emergency Preemption API Handling
// ----------------------------------------------------------------------------
async function engageEmergency(nodeId, laneId) {
  try {
    const res = await fetch('/api/emergency-override', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ intersection_id: nodeId, emergency_lane_id: laneId })
    });
    const data = await res.json();
    emergencyActive = true;
    emergencyNodeId = nodeId;
    emergencyLaneId = data.cleared_lane_id;

    selectedCorridorByNode[nodeId] = emergencyLaneId;
    updateCorridorDropdown(activeNodeId, true);
    renderEmergencyStatus();

    logTrace('PROCEDURE', `CALL proc_Emergency_Override(${nodeId}, ${data.cleared_lane_id}) executed successfully.`);
    logTrace('TRIGGER', `trg_signal_phase_audit recorded ${data.audits?.length || 0} state transitions into Audit_Traffic_Log.`);

    await refreshAll();
  } catch (err) {
    console.error('engageEmergency error:', err);
  }
}

async function clearEmergency(nodeId) {
  try {
    const res = await fetch('/api/clear-emergency', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ intersection_id: nodeId })
    });
    emergencyActive = false;
    emergencyNodeId = null;
    emergencyLaneId = null;

    updateCorridorDropdown(activeNodeId, true);
    renderEmergencyStatus();

    logTrace('OPERATOR', `Emergency override cleared on Node ${nodeId}. Dual-phase signal cycle resumed.`);
    await refreshAll();
  } catch (err) {
    console.error('clearEmergency error:', err);
  }
}

function renderEmergencyStatus() {
  const banner = document.getElementById('emergency-active-banner');
  const bannerText = document.getElementById('emergency-active-text');
  const btnEngage = document.getElementById('btn-engage-emergency');
  const btnClear = document.getElementById('btn-clear-emergency');
  const laneSelect = document.getElementById('override-target-lane');

  if (emergencyActive && emergencyNodeId) {
    banner.classList.remove('hidden');
    bannerText.textContent = `ACTIVE OVERRIDE: Node ${emergencyNodeId} • Lane #${emergencyLaneId}`;
    btnEngage.classList.add('hidden');
    btnClear.classList.remove('hidden');
    if (laneSelect) laneSelect.disabled = true;
  } else {
    banner.classList.add('hidden');
    btnEngage.classList.remove('hidden');
    btnClear.classList.add('hidden');
    if (laneSelect) laneSelect.disabled = false;
  }
}

// ----------------------------------------------------------------------------
// Signal Cycling & Telemetry Ticks
// ----------------------------------------------------------------------------
async function runTelemetryTick() {
  if (!simRunning) return;
  try {
    const res = await fetch('/api/telemetry-tick', { method: 'POST' });
    const data = await res.json();
    await fetchState();
    await fetchDashboardLive();
    await fetchCongestionWMA();
  } catch (err) {
    console.error('runTelemetryTick error:', err);
  }
}

async function cycleSignal(nodeId) {
  try {
    const res = await fetch('/api/cycle-signal', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ intersection_id: nodeId })
    });
    const data = await res.json();
    logTrace('SQL', `CYCLE SIGNAL: Node ${nodeId} phase transition -> ${data.audits?.length || 0} trigger records.`);
    await fetchState();
    await fetchDashboardLive();
    await fetchAuditLog();
  } catch (err) {
    console.error('cycleSignal error:', err);
  }
}

// ----------------------------------------------------------------------------
// Adaptive Dynamic Signal Actuation Engine
// ----------------------------------------------------------------------------
async function checkAdaptiveSignalCycling() {
  if (!simRunning || !state.intersections.length || !state.lanes.length) return;

  // 1. Check currently active viewed node for dynamic gap-out actuation
  const activeLanes = state.lanes.filter(l => l.Intersection_ID === activeNodeId);
  const activeGreen = activeLanes.filter(l => l.Current_State === 'GREEN');
  const activeRed = activeLanes.filter(l => l.Current_State === 'RED');

  const greenQueue = activeGreen.reduce((sum, l) => sum + (l.Current_Car_Count || 0), 0);
  const redQueue = activeRed.reduce((sum, l) => sum + (l.Current_Car_Count || 0), 0);

  const isNodeEmergency = emergencyActive && emergencyNodeId === activeNodeId;

  // Adaptive Gap-Out Actuation:
  // If active green lanes are drained (<= 2 vehicles total)
  // AND the waiting red lanes have demand (>= 4 vehicles)
  if (!isNodeEmergency && greenQueue <= 2 && redQueue >= 4) {
    logTrace('ADAPTIVE', `Node ${activeNodeId} dynamic actuation: Green queue drained (${greenQueue} veh), Red queue waiting (${redQueue} veh) -> Advancing signal phase.`);
    await cycleSignal(activeNodeId);
    return;
  }

  // 2. Network-wide adaptive check across all other nodes
  for (const node of state.intersections) {
    if (node.Intersection_ID === activeNodeId) continue;
    if (emergencyActive && emergencyNodeId === node.Intersection_ID) continue;

    const nLanes = state.lanes.filter(l => l.Intersection_ID === node.Intersection_ID);
    const nGreen = nLanes.filter(l => l.Current_State === 'GREEN');
    const nRed = nLanes.filter(l => l.Current_State === 'RED');

    const nGreenQueue = nGreen.reduce((sum, l) => sum + (l.Current_Car_Count || 0), 0);
    const nRedQueue = nRed.reduce((sum, l) => sum + (l.Current_Car_Count || 0), 0);

    if (nGreenQueue <= 2 && nRedQueue >= 8) {
      logTrace('ADAPTIVE', `Node ${node.Intersection_ID} dynamic actuation: Green queue drained (${nGreenQueue} veh), Red queue waiting (${nRedQueue} veh) -> Advancing signal phase.`);
      await cycleSignal(node.Intersection_ID);
      return;
    }
  }

  // 3. Regular cyclic rotation across nodes if no gap-out triggered
  roundRobinIndex = (roundRobinIndex % state.intersections.length) + 1;
  if (emergencyActive && roundRobinIndex === emergencyNodeId) {
    roundRobinIndex = (roundRobinIndex % state.intersections.length) + 1;
  }
  await cycleSignal(roundRobinIndex);
}

// ----------------------------------------------------------------------------
// Rendering: Horizontal Node Tabs
// ----------------------------------------------------------------------------
function renderNodeTabs() {
  const container = document.getElementById('node-tabs-bar');
  if (!container || !state.intersections.length) return;

  container.innerHTML = '';

  state.intersections.forEach(node => {
    const nodeLanes = state.lanes.filter(l => l.Intersection_ID === node.Intersection_ID);
    const tab = document.createElement('div');
    const isSelected = node.Intersection_ID === activeNodeId;
    const isEmergency = emergencyActive && emergencyNodeId === node.Intersection_ID;

    tab.className = `node-tab ${isSelected ? 'active' : ''} ${isEmergency ? 'emergency-pulse' : ''}`;
    tab.onclick = () => {
      activeNodeId = node.Intersection_ID;
      renderNodeTabs();
      renderCrossroadStage();
      // True = Node explicitly switched by user -> populate dropdown for this node
      updateCorridorDropdown(activeNodeId, true);
      logTrace('OPERATOR', `Visualizer focused on Node ${activeNodeId} (${node.Location_Name}).`);
    };

    let totalCars = 0;
    let totalCap = 0;
    const dotsHtml = ['NORTHBOUND', 'SOUTHBOUND', 'EASTBOUND', 'WESTBOUND'].map(dir => {
      const lane = nodeLanes.find(l => l.Direction === dir);
      if (lane) {
        totalCars += (lane.Current_Car_Count || 0);
        totalCap += lane.Capacity_Limit;
        const isGreen = lane.Current_State === 'GREEN';
        return `<span class="tab-dot ${isGreen ? 'green' : 'red'}" title="${dir}: ${lane.Current_State}"></span>`;
      }
      return '<span class="tab-dot"></span>';
    }).join('');

    const satPct = totalCap > 0 ? Math.round((totalCars / totalCap) * 100) : 0;
    const cleanName = node.Location_Name.split('&')[0].trim();

    tab.innerHTML = `
      <div class="node-tab-top">
        <span class="node-tab-name">${node.Intersection_ID}. ${cleanName}</span>
        <span class="node-tab-cap">${satPct}%</span>
      </div>
      <div class="node-tab-bottom">
        <div class="node-tab-dots">
          ${dotsHtml}
        </div>
        <span class="node-tab-zone">${node.Grid_Zone.split(' - ')[0]}</span>
      </div>
    `;

    container.appendChild(tab);
  });
}

// ----------------------------------------------------------------------------
// Rendering: 4-Way Crossroad Visualizer Stage
// ----------------------------------------------------------------------------
function renderCrossroadStage() {
  const activeNode = state.intersections.find(i => i.Intersection_ID === activeNodeId);
  if (!activeNode) return;

  const centerNodeId = document.getElementById('center-node-id');
  if (centerNodeId) {
    centerNodeId.textContent = `NODE ${activeNode.Intersection_ID}`;
  }

  const nodeLanes = state.lanes.filter(l => l.Intersection_ID === activeNodeId);

  const directions = [
    { key: 'NORTHBOUND', slotId: 'approach-north', label: 'NORTH' },
    { key: 'SOUTHBOUND', slotId: 'approach-south', label: 'SOUTH' },
    { key: 'EASTBOUND', slotId: 'approach-east', label: 'EAST' },
    { key: 'WESTBOUND', slotId: 'approach-west', label: 'WEST' }
  ];

  directions.forEach(dirInfo => {
    const container = document.getElementById(dirInfo.slotId);
    if (!container) return;

    const lane = nodeLanes.find(l => l.Direction === dirInfo.key);
    if (!lane) {
      container.innerHTML = '<span class="text-dim">No lane</span>';
      return;
    }

    const satPct = Math.min(100, Math.round(((lane.Current_Car_Count || 0) / lane.Capacity_Limit) * 100));
    let barColor = '#10b981';
    if (satPct >= 85) barColor = '#ef4444';
    else if (satPct >= 60) barColor = '#f59e0b';

    const wmaItem = congestionList.find(c => c.lane_id === lane.Lane_ID);
    const wmaLevel = wmaItem ? wmaItem.level : (satPct >= 75 ? 'High' : (satPct >= 40 ? 'Medium' : 'Low'));
    const wmaBadgeClass = wmaLevel === 'High' ? 'high' : (wmaLevel === 'Medium' ? 'med' : 'low');

    const isGreen = lane.Current_State === 'GREEN';
    const isYellow = lane.Current_State === 'YELLOW';
    const isRed = lane.Current_State === 'RED';

    container.className = `approach-card ${isGreen ? 'phase-green' : 'phase-red'}`;
    container.innerHTML = `
      <div class="card-top-row">
        <div class="direction-badge">
          <span>${dirInfo.label}</span>
          <span class="lane-num mono">#${lane.Lane_ID}</span>
          ${lane.Is_Emergency_Corridor ? '<span class="emergency-pill mono">EMERGENCY</span>' : ''}
        </div>
        <div class="traffic-lamp">
          <div class="lamp-dot red ${isRed ? 'lit' : ''}"></div>
          <div class="lamp-dot yellow ${isYellow ? 'lit' : ''}"></div>
          <div class="lamp-dot green ${isGreen ? 'lit' : ''}"></div>
        </div>
      </div>
      <div class="card-mid-row">
        <div>
          <span class="queue-val mono">${lane.Current_Car_Count || 0}</span>
          <span class="queue-label"> / ${lane.Capacity_Limit} veh</span>
        </div>
        <div>
          <span class="wma-badge ${wmaBadgeClass} mono">${wmaLevel.toUpperCase()}</span>
        </div>
      </div>
      <div class="queue-progress-track">
        <div class="queue-progress-bar" style="width: ${satPct}%; background-color: ${barColor};"></div>
      </div>
    `;
  });

  // Synchronize 60 FPS 2D Canvas vehicle simulation with database lanes
  syncSimulatorWithLanes(state.lanes, activeNodeId, emergencyActive, emergencyLaneId);
}

function updateCorridorDropdown(nodeId, force = false) {
  const select = document.getElementById('override-target-lane');
  if (!select) return;

  // Preserve options and selection if already initialized for this node
  if (dropdownCurrentNodeId === nodeId && !force && select.options.length > 0) {
    if (emergencyActive && emergencyNodeId === nodeId) {
      select.value = emergencyLaneId;
      select.disabled = true;
    } else {
      select.disabled = false;
    }
    return;
  }

  const lanes = state.lanes.filter(l => l.Intersection_ID === nodeId);
  if (!lanes.length) return;

  // Determine which lane should be selected:
  let targetToSelect = null;
  if (emergencyActive && emergencyNodeId === nodeId) {
    targetToSelect = emergencyLaneId;
  } else if (selectedCorridorByNode[nodeId]) {
    targetToSelect = selectedCorridorByNode[nodeId];
  } else {
    const def = lanes.find(l => l.Is_Emergency_Corridor);
    targetToSelect = def ? def.Lane_ID : lanes[0].Lane_ID;
  }

  select.innerHTML = '';
  lanes.forEach(l => {
    const opt = document.createElement('option');
    opt.value = l.Lane_ID;
    opt.textContent = `Lane #${l.Lane_ID} (${l.Direction})${l.Is_Emergency_Corridor ? ' [EMERGENCY CORRIDOR]' : ''}`;
    if (l.Lane_ID === targetToSelect) {
      opt.selected = true;
    }
    select.appendChild(opt);
  });

  select.disabled = (emergencyActive && emergencyNodeId === nodeId);
  dropdownCurrentNodeId = nodeId;
}

// ----------------------------------------------------------------------------
// Rendering: Sidebar Database Metrics
// ----------------------------------------------------------------------------
function renderDashboardTable(rows) {
  const tbody = document.getElementById('view-dashboard-body');
  if (!tbody) return;

  tbody.innerHTML = '';

  rows.forEach(r => {
    const tr = document.createElement('tr');
    const flowClass = r.Flow_Classification === 'HEAVY_FLOW' ? 'flow-heavy' : (r.Flow_Classification === 'NORMAL_FLOW' ? 'flow-normal' : 'flow-free');
    const sat = r.Saturation_Pct;
    const barFillColor = sat >= 80 ? '#ef4444' : (sat >= 50 ? '#f59e0b' : '#10b981');

    tr.innerHTML = `
      <td style="color: #0f172a; font-weight: 700;">Node ${r.Intersection_ID}</td>
      <td style="color: #334155;">#${r.Lane_ID} <span style="color: #64748b; font-size: 9px;">(${r.Direction.charAt(0)})</span></td>
      <td><b style="color: #0f172a;">${r.Current_Volume}</b><span style="color: #64748b;">/${r.Capacity_Limit}</span></td>
      <td>
        <div class="sat-cell">
          <div class="sat-bar-bg">
            <div class="sat-bar-fill" style="width: ${Math.min(100, sat)}%; background-color: ${barFillColor};"></div>
          </div>
          <span class="sat-val" style="color: ${barFillColor};">${sat}%</span>
        </div>
      </td>
      <td><span class="flow-pill ${flowClass}">${r.Flow_Classification.split('_')[0]}</span></td>
    `;
    tbody.appendChild(tr);
  });
}

function renderCongestionRanking(list) {
  const container = document.getElementById('congestion-list');
  if (!container) return;

  container.innerHTML = '';
  const sorted = [...list].sort((a, b) => b.ratio - a.ratio);

  sorted.slice(0, 4).forEach(item => {
    const div = document.createElement('div');
    div.className = 'wma-item';
    const badgeClass = item.level === 'High' ? 'high' : (item.level === 'Medium' ? 'med' : 'low');

    div.innerHTML = `
      <div class="wma-item-left">
        <span class="wma-item-lane">Lane #${item.lane_id} <span style="font-weight: 500; color: #64748b;">(${item.direction})</span></span>
        <span class="wma-item-sub">Node ${item.intersection_id} • Cap ${item.capacity} veh</span>
      </div>
      <div class="wma-item-right">
        <span class="wma-item-score mono">WMA: ${item.wma}</span>
        <span class="wma-badge ${badgeClass} mono">${item.level.toUpperCase()}</span>
      </div>
    `;
    container.appendChild(div);
  });
}

function renderAuditTable(logs) {
  const tbody = document.getElementById('audit-table-body');
  if (!tbody) return;

  tbody.innerHTML = '';

  logs.slice(0, 20).forEach(a => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td style="color: #0f172a; font-weight: 600;">#${a.Audit_ID}</td>
      <td style="color: #334155;">Phase ${a.Phase_ID}</td>
      <td style="color: ${a.Old_State === 'GREEN' ? '#059669' : '#dc2626'}; font-weight: 600;">${a.Old_State || 'NULL'}</td>
      <td style="color: ${a.New_State === 'GREEN' ? '#059669' : '#dc2626'}; font-weight: 600;">${a.New_State}</td>
      <td style="color: #64748b;">${a.Changed_At.slice(11)}</td>
      <td style="color: #2563eb; font-size: 9px; font-weight: 600;">${a.Trigger_Source}</td>
    `;
    tbody.appendChild(tr);
  });
}

function logTrace(type, msg) {
  const term = document.getElementById('live-trace-stream');
  if (!term) return;

  const now = new Date().toTimeString().slice(0, 8);
  const entry = document.createElement('div');
  entry.style.marginBottom = '3px';

  let typeColor = '#38bdf8';
  if (type === 'SQL') typeColor = '#fef08a';
  else if (type === 'TRIGGER') typeColor = '#34d399';
  else if (type === 'PROCEDURE') typeColor = '#fbbf24';
  else if (type === 'OPERATOR') typeColor = '#a78bfa';
  else if (type === 'ADAPTIVE') typeColor = '#38bdf8';

  entry.innerHTML = `<span style="color: #6b7280;">[${now}]</span> <b style="color: ${typeColor};">[${type}]</b> ${msg}`;
  term.appendChild(entry);
  term.scrollTop = term.scrollHeight;
}

// ----------------------------------------------------------------------------
// Dynamic Simulation Loop Scheduling
// ----------------------------------------------------------------------------
function scheduleTelemetryLoop() {
  if (telemetryTimeout) clearTimeout(telemetryTimeout);
  const interval = Math.max(300, Math.round(2500 / simSpeed));
  telemetryTimeout = setTimeout(async () => {
    if (simRunning) {
      await runTelemetryTick();
    }
    scheduleTelemetryLoop();
  }, interval);
}

function scheduleCycleLoop() {
  if (cycleTimeout) clearTimeout(cycleTimeout);
  const interval = Math.max(500, Math.round(4500 / simSpeed));
  cycleTimeout = setTimeout(async () => {
    if (simRunning) {
      await checkAdaptiveSignalCycling();
    }
    scheduleCycleLoop();
  }, interval);
}

function startSimulationLoops() {
  scheduleTelemetryLoop();
  scheduleCycleLoop();
}
