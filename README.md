# RokuDemoChannel

Just an example Roku channel, written from scratch, with a small HTTP helper ([`httpUtils.brs`](components/libs/httpUtils.brs)) adapted from a public snippet I found online (source long forgotten). A simple stack manages the screens, and the screen content — titles, buttons, the movie list — is driven by a JSON feed.

Had this code laying around for a long time — now it's public, with an overdue facelift. :)

## Run it without a Roku

There's a browser-based emulator under [`emulator/`](emulator/) (brs-engine, in Docker — no hardware needed):

```bash
docker compose -f emulator/docker-compose.yml up --build
# then open http://localhost:6502
```

It ships with sample data ([`emulator/web/movies.json`](emulator/web/movies.json)) so the channel has something to render. See [emulator/README.md](emulator/README.md) for the on-screen/keyboard remote, the debug console, and how it's wired.

## On a real Roku

Set `jsonUrl` in [`components/constants.brs`](components/constants.brs) to your feed, then sideload with the `makefile` (`make install`, with `ROKU_DEV_TARGET` set to your device's IP).

## Roku OS 15

When running on OS 15, the channel uses the new zero-rendezvous data APIs — `roRenderThreadQueue` for the Task→Scene handoff and `MoveIntoField` for the list content — and falls back to the classic field/observer path on older devices. The capability is detected once at runtime, so the same build runs everywhere.
