# logos-storage-test-agent

![storage-stack](https://img.shields.io/badge/logos--storage--modules-passing-brightgreen)

End-to-end test harness for the Logos storage stack. For each new release of
[`logos-basecamp`](https://github.com/logos-co/logos-basecamp),
[`logos-storage-module`](https://github.com/logos-co/logos-storage-module), or
[`logos-storage-ui`](https://github.com/logos-co/logos-storage-ui), it verifies that the
core storage module and the storage UI load and function inside basecamp — onboarding
completes, a file can be shared and re-downloaded, and the sha256 round-trips.

## How it runs

This repo is driven by a Claude Code agent invoked against `CLAUDE.md`, typically on CI
when one of the upstream repos publishes a new release. The agent clones, builds,
installs, and exercises the stack via the QML inspector, then commits a dated PASS/FAIL
summary under `runs/`, refreshes the runs index in this README, and updates the badge
above. You don't run anything by hand.

If the current combination of upstream tags (basecamp + storage-module + storage-ui) is
already present in the index below with `PASS`, the agent recognises that and exits
without re-testing.

## Layout

```
CLAUDE.md       Task instructions read by the agent on each run.
CLAUDE-TIPS.md  Stable lessons learned across runs — update when new gotchas surface.
tools/          Build/install helpers (install.sh) and the QML inspector driver (logos-cli.py).
logos/          Where the three upstream repos get cloned. Recreated by each run.
runs/           One dated PASS/FAIL summary per release; never overwritten.
```

## Prerequisites (CI box)

- Nix (with flakes enabled).
- `curl`, `jq`, `git`, `python3`.
- A graphical session — basecamp is a Qt/QML desktop app.

## Test runs

Most recent first. The badge at the top reflects the latest row's result.

| Date       | basecamp | storage-module | storage-ui | Result | Summary                                          |
|------------|----------|----------------|------------|--------|--------------------------------------------------|
| 2026-05-25 | 0.1.2    | v0.3.2         | v0.1.0     | PASS   | [link](runs/2026-05-25-basecamp-0.1.2.md)        |
