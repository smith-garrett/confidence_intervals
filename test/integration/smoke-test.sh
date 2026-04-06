#!/bin/bash
set -e

GLEAM_URL="http://127.0.0.1:3001"
MAX_WAIT=120  # seconds to wait for Julia to warm up
POLL_INTERVAL=5

echo "=== Building images ==="
podman build -t ci-demo-gleam .
podman build -t ci-demo-julia -f SimulateAndPlot/Dockerfile ./SimulateAndPlot

echo "=== Starting pod ==="
podman pod create --name ci-smoke --network=host

podman run -d \
  --pod ci-smoke \
  --name ci-smoke-julia \
  --health-cmd "curl -f http://127.0.0.1:8080/healthz || exit 1" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-start-period 60s \
  --health-retries 5 \
  ci-demo-julia

podman run -d \
  --pod ci-smoke \
  --name ci-smoke-gleam \
  --health-cmd "wget -qO- http://127.0.0.1:3001/healthz || exit 1" \
  --health-interval 10s \
  --health-timeout 3s \
  --health-start-period 10s \
  --health-retries 3 \
  -e HOST=0.0.0.0 \
  -e PORT=3001 \
  -e JULIA_URL=http://127.0.0.1:8080 \
  ci-demo-gleam

echo "=== Waiting for services to be healthy ==="
elapsed=0
while true; do
  gleam_health=$(podman inspect ci-smoke-gleam --format '{{.State.Health.Status}}')
  julia_health=$(podman inspect ci-smoke-julia --format '{{.State.Health.Status}}')

  echo "  Gleam: $gleam_health | Julia: $julia_health (${elapsed}s elapsed)"

  if [ "$gleam_health" = "healthy" ] && [ "$julia_health" = "healthy" ]; then
    echo "  Both services healthy."
    break
  fi

  if [ "$elapsed" -ge "$MAX_WAIT" ]; then
    echo "ERROR: Services did not become healthy within ${MAX_WAIT}s"
    podman logs ci-smoke-gleam
    podman logs ci-smoke-julia
    exit 1
  fi

  sleep $POLL_INTERVAL
  elapsed=$((elapsed + POLL_INTERVAL))
done

echo "=== Running smoke tests ==="

# Test 1: frontend loads
echo "Test 1: GET / returns HTML..."
response=$(wget -qO- "$GLEAM_URL/")
echo "$response" | grep -q "<html" && echo "  PASS" || { echo "  FAIL (response did not contain HTML)"; exit 1; }

# Test 2: healthz endpoint
echo "Test 2: GET /healthz returns 200..."
wget -qO- "$GLEAM_URL/healthz" > /dev/null && echo "  PASS" || { echo "  FAIL"; exit 1; }

# Test 3: simulate endpoint returns SVG
echo "Test 3: POST /simulate returns SVG..."
response=$(wget -qO- --post-data='{"n_experiments":10,"n_samples_per_experiment":20}' \
  --header="Content-Type: application/json" \
  "$GLEAM_URL/simulate")
echo "$response" | grep -q "<svg" && echo "  PASS" || { echo "  FAIL (response did not contain SVG)"; exit 1; }

# Test 4: invalid params return 400
echo "Test 4: POST /simulate with invalid params returns 400..."
status=$(wget -qO- --server-response \
  --post-data='{"n_experiments":-1,"n_samples_per_experiment":20}' \
  --header="Content-Type: application/json" \
  "$GLEAM_URL/simulate" 2>&1 >/dev/null | grep "HTTP/" | awk '{print $2}' || true)
[ "$status" = "400" ] && echo "  PASS" || { echo "  FAIL (got $status)"; exit 1; }

echo "=== All tests passed ==="
