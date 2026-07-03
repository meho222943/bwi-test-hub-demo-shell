# bwi-test-hub-demo

A minimal, self-contained test repository for trying out the **BWI Test
Hub**. Register this repository's clone URL in the hub and start a run —
no Docker daemon required.

## What it does

- `run-tests.sh` runs four trivial POSIX-shell "test cases" and writes:
  - `report/index.html` — a browsable HTML report
  - `report/junit.xml` — JUnit results
- The manifest declares **no runtime profile**, so the hub executes it
  as a plain host process (`DIRECT_PROCESS`) — it needs only `sh` on the
  runner, not a container runtime.

## Manifest

See [`.icarus-execution.yaml`](.icarus-execution.yaml). Key point: no
`runtime:` block ⇒ runs without a container.

## Register in the BWI Test Hub

1. Open the hub → **Repositories** → *New registration*.
2. Source: **Remote**, URL: this repo's HTTPS clone URL, ref: `main`.
3. Save, then start the target from the main screen.

## See a failing run

In `run-tests.sh`, change the expected value of the `line-count` case
from `"3"` to `"999"` and push — the next run turns red, exercising the
hub's error UX.

## Run locally

```sh
sh run-tests.sh && open report/index.html
```
