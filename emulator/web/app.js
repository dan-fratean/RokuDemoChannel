const logEl = document.getElementById("log");
const countsEl = document.getElementById("counts");
const filterInput = document.getElementById("filter");
let activeLevel = "all";
let hideNoise = false;
let filterText = "";
let total = 0;
let last = null;

const NOISE = new Set(["debug"]);

function matches(e) {
  if (hideNoise && NOISE.has(e.level)) return false;
  if (activeLevel !== "all" && e.level !== activeLevel) return false;
  if (filterText && !((e.label + " " + e.msg).toLowerCase().includes(filterText))) return false;
  return true;
}

function makeEntry(level, label, msg) {
  const long = msg.length > 140 || msg.includes("\n");
  const el = document.createElement("div");
  el.className = "entry " + level + (long ? " collapsed" : "");
  el.innerHTML =
    `<span class="dot"></span>` +
    `<span class="body">${long ? '<span class="twirl">▶</span>' : ""}` +
      `<span class="tag"></span><span class="msg"></span></span>` +
    `<span class="count" style="display:none"></span>`;
  el.querySelector(".tag").textContent = label ? `[${label}]` : "";
  el.querySelector(".msg").textContent = msg;
  if (long) {
    const toggle = () => {
      el.classList.toggle("collapsed");
      el.querySelector(".twirl").textContent = el.classList.contains("collapsed") ? "▶" : "▼";
    };
    el.querySelector(".twirl").addEventListener("click", (ev) => { ev.stopPropagation(); toggle(); });
    el.addEventListener("click", toggle);
  }
  return el;
}

function push(level, label, msg) {
  total++;
  if (last && last.level === level && last.label === label && last.msg === msg) {
    last.count++;
    const c = last.el.querySelector(".count");
    c.style.display = "";
    c.textContent = "×" + last.count;
    countsEl.textContent = total + " lines";
    return;
  }
  const el = makeEntry(level, label, msg);
  const atBottom = logEl.scrollTop + logEl.clientHeight >= logEl.scrollHeight - 30;
  logEl.appendChild(el);
  last = { level, label, msg, el, count: 1 };
  el.style.display = matches(last) ? "" : "none";
  countsEl.textContent = total + " lines";
  if (atBottom) logEl.scrollTop = logEl.scrollHeight;
}

function refilter() {
  for (const el of logEl.children) {
    const level = el.classList[1];
    const label = (el.querySelector(".tag").textContent || "").replace(/^\[|\]$/g, "");
    const msg = el.querySelector(".msg").textContent;
    el.style.display = matches({ level, label, msg }) ? "" : "none";
  }
}

function levelOf(kind) {
  if (/error|crash|exception|fail/i.test(kind)) return "error";
  if (/warn/i.test(kind)) return "warn";
  if (/loaded|started|launch|ready|ok/i.test(kind)) return "info";
  if (/beacon|print|debug|registry|icon|resolution|version/i.test(kind)) return "debug";
  return "info";
}
function log(msg, level) { push(level || "info", "", msg); }

document.querySelector(".console-bar").addEventListener("click", (e) => {
  const f = e.target.closest("[data-filter]");
  const t = e.target.closest("[data-toggle]");
  const clear = e.target.closest("[data-act=clear]");
  if (f) {
    activeLevel = f.dataset.filter;
    document.querySelectorAll("[data-filter]").forEach((b) => b.classList.toggle("on", b === f));
    refilter();
  } else if (t) {
    hideNoise = !hideNoise;
    t.classList.toggle("on", hideNoise);
    refilter();
  } else if (clear) {
    logEl.innerHTML = ""; last = null; total = 0; countsEl.textContent = "0 lines";
  }
});
filterInput.addEventListener("input", () => { filterText = filterInput.value.trim().toLowerCase(); refilter(); });

if (!self.crossOriginIsolated) {
  log("page is not crossOriginIsolated — SharedArrayBuffer unavailable. Serve via the provided server.", "warn");
}

let booted = false;
let muted = false;
let runStartedAt = 0;
let retried = false;

async function boot() {
  if (booted) return;
  // Warm common.zip cache + brief delay so the engine has it before the first execute.
  try { await fetch("./assets/common.zip", { cache: "force-cache" }); } catch {}

  const deviceOverrides = {
    extensions: new Map([[brs.SupportedExtension.SceneGraph, "./brs-sg.js"]]),
  };
  await brs.initialize(deviceOverrides, { debugToConsole: true });
  await new Promise((r) => setTimeout(r, 250));
  log("engine " + brs.getVersion() + " ready · SceneGraph extension registered", "info");

  brs.subscribe("harness", (event, data) => {
    let level = levelOf(event);
    let label = event;
    let msg;
    if (typeof data === "string") {
      msg = data.trim();
    } else if (data && typeof data === "object") {
      if (data.level && data.content !== undefined) { level = levelOf(data.level); label = data.level; msg = String(data.content).trim(); }
      else { try { msg = JSON.stringify(data); } catch { msg = String(data); } }
    } else { msg = String(data); }
    if (msg === "") return;
    push(level, label, msg);

    if (event === "closed" && /crash/i.test(String(data)) &&
        !retried && performance.now() - runStartedAt < 2500) {
      retried = true;
      log("early crash detected — retrying once…", "warn");
      setTimeout(run, 400);
    }
  });

  booted = true;
}

async function run() {
  await boot();
  log("fetching channel.zip …", "debug");
  const resp = await fetch("./channel.zip?t=" + Date.now());
  if (!resp.ok) { log("channel.zip not found (" + resp.status + ")", "error"); return; }
  const buf = await resp.arrayBuffer();
  log(`executing channel.zip (${(buf.byteLength / 1024).toFixed(0)} KB)`, "info");
  runStartedAt = performance.now();
  brs.execute("channel.zip", buf, { clearDisplayOnExit: true, debugToConsole: true });
}

async function rebuild() {
  retried = false;
  log("rebuilding zip from current source …", "info");
  try {
    const r = await fetch("/rebuild", { method: "POST" });
    const j = await r.json();
    if (j.ok) { log(`rebuilt channel.zip (${(j.bytes / 1024).toFixed(0)} KB)`, "info"); await run(); }
    else log("rebuild failed: " + j.error, "error");
  } catch (e) { log("rebuild request failed: " + e.message, "error"); }
}

function key(name) { if (booted) brs.sendKeyPress(name); }

document.addEventListener("click", (e) => {
  const btn = e.target.closest("#stage button");
  if (!btn) return;
  const act = btn.dataset.act;
  if (act === "run") { retried = false; run(); }
  else if (act === "rebuild") rebuild();
  else if (act === "key") key(btn.dataset.key);
  else if (act === "mute") { muted = !muted; brs.setAudioMute(muted); btn.textContent = muted ? "🔈 Unmute" : "🔇 Mute"; }
});

const KEYMAP = {
  ArrowUp: "up", ArrowDown: "down", ArrowLeft: "left", ArrowRight: "right",
  Enter: "select", " ": "play", Backspace: "back", Escape: "back",
  Home: "home", i: "info", I: "info", ",": "rev", ".": "fwd",
};
window.addEventListener("keydown", (e) => {
  const k = KEYMAP[e.key]; if (!k || !booted) return; e.preventDefault(); brs.sendKeyDown(k);
});
window.addEventListener("keyup", (e) => {
  const k = KEYMAP[e.key]; if (!k || !booted) return; e.preventDefault(); brs.sendKeyUp(k);
});

run().catch((err) => log("boot failed: " + (err && err.message ? err.message : err), "error"));
