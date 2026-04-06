#!/bin/bash
podman pod stop ci-smoke 2>/dev/null || true
podman pod rm ci-smoke 2>/dev/null || true
echo "Pod removed."
