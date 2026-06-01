const http = require("http");
const fs = require("fs");
const path = require("path");
const { execFile } = require("child_process");

const ROOT = "/public";
const PORT = process.env.PORT ? Number(process.env.PORT) : 6502;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".zip": "application/zip",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".wasm": "application/wasm",
  ".map": "application/json",
};

// COOP/COEP enable crossOriginIsolated, required for the engine's SharedArrayBuffer.
function isolationHeaders(res) {
  res.setHeader("Cross-Origin-Opener-Policy", "same-origin");
  res.setHeader("Cross-Origin-Embedder-Policy", "require-corp");
  res.setHeader("Cross-Origin-Resource-Policy", "same-origin");
}

function rebuild(res) {
  execFile(
    "/app/build.sh", [],
    (err, _stdout, stderr) => {
      isolationHeaders(res);
      res.setHeader("Content-Type", "application/json");
      if (err) {
        res.writeHead(500);
        res.end(JSON.stringify({ ok: false, error: stderr || err.message }));
      } else {
        const size = fs.statSync(path.join(ROOT, "channel.zip")).size;
        res.writeHead(200);
        res.end(JSON.stringify({ ok: true, bytes: size }));
      }
    }
  );
}

const server = http.createServer((req, res) => {
  if (req.method === "POST" && req.url === "/rebuild") {
    return rebuild(res);
  }

  let urlPath = decodeURIComponent(req.url.split("?")[0]);
  if (urlPath === "/") urlPath = "/index.html";

  const filePath = path.normalize(path.join(ROOT, urlPath));
  if (!filePath.startsWith(ROOT)) {
    res.writeHead(403);
    return res.end("Forbidden");
  }

  fs.readFile(filePath, (err, data) => {
    isolationHeaders(res);
    if (err) {
      res.writeHead(404);
      return res.end("Not found: " + urlPath);
    }
    res.setHeader("Content-Type", MIME[path.extname(filePath)] || "application/octet-stream");
    res.writeHead(200);
    res.end(data);
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`[serve] brs-engine harness on http://localhost:${PORT}`);
});
