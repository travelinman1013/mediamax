#!/bin/bash

# Media Server Stack - Startup Script
# Starts all services with prerequisites checking

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "Media Server Stack - Startup"
echo "========================================="
echo ""

# Check for .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    echo ""
    echo "Please create .env from the template:"
    echo "  cp .env.example .env"
    echo ""
    echo "Then edit .env and add your Real-Debrid API key:"
    echo "  nano .env"
    echo ""
    echo "Get your API key from: https://real-debrid.com/apitoken"
    echo ""
    exit 1
fi

# Check for Real-Debrid API key
if grep -q "your_api_key_here" .env 2>/dev/null; then
    echo "Warning: Real-Debrid API key not configured"
    echo ""
    echo "RDTClient will not work without a valid API key."
    echo "Edit .env and replace 'your_api_key_here' with your actual key."
    echo ""
    echo "Get your API key from: https://real-debrid.com/apitoken"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Startup cancelled."
        exit 1
    fi
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo ""
    exit 1
fi

# Create directory structure if it doesn't exist
echo "Checking directory structure..."
mkdir -p config/{rdtclient,radarr,sonarr,prowlarr,bazarr,jellyfin,jellyseerr}
mkdir -p media/{downloads/{movies,tv},movies,tv}
echo "[OK] Directories ready"
echo ""

# Pull latest images (optional, can be slow on first run)
echo "Checking for image updates..."
echo "(This may take a few minutes on first run)"
docker compose pull
echo "[OK] Images up to date"
echo ""

# Start the stack
echo "Starting services..."
docker compose up -d

# Wait for services to initialize
echo ""
echo "Waiting for services to start..."
sleep 10

# Check container status
echo ""
echo "========================================="
echo "Container Status"
echo "========================================="
docker compose ps
echo ""

# Display service URLs
echo "========================================="
echo "Service Access URLs"
echo "========================================="
echo ""
echo "Primary Services:"
echo "  Jellyseerr (Request UI):  http://localhost:5055"
echo "  Jellyfin (Media Player):  http://localhost:8096"
echo ""
echo "Management Services:"
echo "  Radarr (Movies):          http://localhost:7878"
echo "  Sonarr (TV Shows):        http://localhost:8989"
echo "  Prowlarr (Indexers):      http://localhost:9696"
echo "  Bazarr (Subtitles):       http://localhost:6767"
echo ""
echo "Backend Services:"
echo "  RDTClient:                http://localhost:6500"
echo "  Flaresolverr:             http://localhost:8191"
echo ""
echo "========================================="
echo "Next Steps"
echo "========================================="
echo ""
echo "1. Configure each service (see SETUP_GUIDE.md)"
echo "2. Add your Real-Debrid API key in RDTClient"
echo "3. Configure indexers in Prowlarr"
echo "4. Connect services together"
echo "5. Request content in Jellyseerr!"
echo ""
echo "View logs: docker compose logs -f"
echo "Stop stack: ./stop.sh"
echo ""
