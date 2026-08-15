# macOS window-manager stack

- `aerospace/` — tiling WM (`aerospace.toml`).
- `borders/` — window borders; **active** (launched by aerospace's `after-startup-command`).
- `sketchybar/` — Lua status bar. Its launch is **intentionally commented out** in `aerospace.toml` (disabled while using aerospace).

## C helpers — the one build in this repo

`sketchybar/.config/sketchybar/helpers/makefile` (lowercase) compiles C in `helpers/event_providers/{cpu_load,network_load}/` and `helpers/menus/`. This is the **only** build here — the repo otherwise has no build/test/lint/typecheck. Re-run `make` in `helpers/` after editing those helpers (it recurses into `event_providers/` and `menus/`).