# Browser emulator (no Roku hardware)

Runs RokuDemoChannel in your browser using
[brs-engine](https://github.com/lvcabral/brs-engine) — a BrightScript +
SceneGraph interpreter compiled to JS/WebAssembly. Everything runs in Docker;
nothing is installed on your host.

## Run

```bash
docker compose -f emulator/docker-compose.yml up --build
# then open http://localhost:6502
```

The channel auto-runs on page load.

- **Remote:** on-screen buttons, or keyboard — arrows = d-pad, `Enter` = OK,
  `Esc`/`Backspace` = Back, `Home`, `i` = Info, `,`/`.` = rev/fwd, `Space` = play.
- **Debug console:** right-hand panel shows engine/print output.
- **Edit → re-test:** change channel source, click **⟳ Rebuild zip** (no restart),
  then **▶ Run channel**. (`POST /rebuild` repackages from the read-only mount.)

## How it's wired

- `build.sh` zips `manifest/source/components/images` into `/public/channel.zip`
  (injecting a sample `jsonUrl` if the channel ships without one).
- `serve.js` is a zero-dep static server that adds the **COOP/COEP** headers
  brs-engine needs for `SharedArrayBuffer`, and exposes `POST /rebuild`.
- `web/app.js` calls `brs.initialize()` with the **SceneGraph extension**
  (`brs-sg.js`) registered, then `brs.execute()` on the fetched zip.
- Pinned versions: `brs-engine@2.2.0`, `brs-scenegraph@0.2.0`.

## Caveats

- **SceneGraph support in brs-engine is experimental.** This channel is a
  SceneGraph app, so expect partial fidelity — some nodes/layouts may render
  imperfectly or log warnings.
- `requires_widevine_drm` video won't actually play (no DRM/CDM here); UI and
  channel logic still run.
- Not a substitute for certification testing on a real device.
