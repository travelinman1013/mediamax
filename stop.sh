#!/bin/bash

# Media Server Stack - Shutdown Script
# Stops all services gracefully

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "Media Server Stack - Shutdown"
echo "========================================="
echo ""

# Check if docker-compose.yml exists
if [ ! -f docker-compose.yml ]; then
    echo "Error: docker-compose.yml not found"
    echo "Are you in the correct directory?"
    exit 1
fi

# Check if any containers are running
if ! docker compose ps --quiet | grep -q .; then
    echo "No containers are currently running."
    exit 0
fi

echo "Stopping services..."
docker compose down

echo ""
echo "[OK] All services stopped"
echo ""
echo "To start again: ./start.sh"
echo ""
