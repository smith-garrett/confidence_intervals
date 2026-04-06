#!/bin/bash
set -e

SERVICE=${1:-"all"}  # pass "gleam", "julia", or leave blank for both

podman pod stop ci-demo 2>/dev/null || true
podman pod rm ci-demo 2>/dev/null || true

if [ "$SERVICE" = "gleam" ] || [ "$SERVICE" = "all" ]; then
  echo "Building Gleam image..."
  podman build -t ci-gleam-web .
fi

if [ "$SERVICE" = "julia" ] || [ "$SERVICE" = "all" ]; then
  echo "Building Julia image..."
  podman build -t ci-julia-compute -f SimulateAndPlot/Dockerfile ./SimulateAndPlot
fi

echo "Creating pod..."
podman pod create --name ci-demo --network=host

echo "Starting Julia..."
podman run -d \
  --pod ci-demo \
  --name ci-julia-compute \
  --health-cmd "curl -f http://localhost:8080/healthz || exit 1" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-start-period 60s \
  --health-retries 5 \
  ci-julia-compute

echo "Starting Gleam..."
podman run -d \
  --pod ci-demo \
  --name ci-gleam-web \
  --health-cmd "wget -qO- http://127.0.0.1:${PORT:-3001}/healthz || exit 1" \
  --health-interval 10s \
  --health-timeout 3s \
  --health-start-period 10s \
  --health-retries 3 \
  -e HOST=0.0.0.0 \
  -e PORT=3001 \
  -e JULIA_URL=http://localhost:8080 \
  ci-gleam-web
echo "Done. Julia warming up — give it ~60s before testing."
echo "Visit http://localhost:3001 when ready."
