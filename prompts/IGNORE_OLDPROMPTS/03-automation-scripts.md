# Step 3: Automation Scripts

**Archon Task ID:** `f3324e99-13fb-4fc7-831d-072d594a918d`
**Project:** media-server-stack
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Depends On:** Step 2 (Docker Compose)

---

## Context

The docker-compose.yml has been created in Step 2. Now you need to create convenience scripts to start and stop the media server stack with proper error checking and user feedback.

These scripts will:
- Ensure prerequisites are met (`.env` file, directory structure)
- Provide clear feedback to the user
- Handle errors gracefully
- Display service URLs when ready

---

## Your Task

Create two automation scripts: `start.sh` and `stop.sh`, then make them executable.

### 1. Create start.sh

Create `/Users/maxwell/Projects/mediamax/start.sh`:

```bash
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
    echo "❌ Error: .env file not found"
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
    echo "⚠️  Warning: Real-Debrid API key not configured"
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
    echo "❌ Error: Docker is not running"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo ""
    exit 1
fi

# Create directory structure if it doesn't exist
echo "Checking directory structure..."
mkdir -p config/{rdtclient,radarr,sonarr,prowlarr,bazarr,jellyfin,jellyseerr}
mkdir -p media/{downloads/{movies,tv},movies,tv}
echo "✓ Directories ready"
echo ""

# Pull latest images (optional, can be slow on first run)
echo "Checking for image updates..."
echo "(This may take a few minutes on first run)"
docker compose pull
echo "✓ Images up to date"
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
echo "  🎬 Jellyseerr (Request UI):  http://localhost:5055"
echo "  📺 Jellyfin (Media Player):  http://localhost:8096"
echo ""
echo "Management Services:"
echo "  🎥 Radarr (Movies):          http://localhost:7878"
echo "  📡 Sonarr (TV Shows):        http://localhost:8989"
echo "  🔍 Prowlarr (Indexers):      http://localhost:9696"
echo "  💬 Bazarr (Subtitles):       http://localhost:6767"
echo ""
echo "Backend Services:"
echo "  ⬇️  RDTClient:                http://localhost:6500"
echo "  🔓 Flaresolverr:             http://localhost:8191"
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
```

### 2. Create stop.sh

Create `/Users/maxwell/Projects/mediamax/stop.sh`:

```bash
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
    echo "❌ Error: docker-compose.yml not found"
    echo "Are you in the correct directory?"
    exit 1
fi

# Check if any containers are running
if ! docker compose ps --quiet | grep -q .; then
    echo "ℹ️  No containers are currently running."
    exit 0
fi

echo "Stopping services..."
docker compose down

echo ""
echo "✓ All services stopped"
echo ""
echo "To start again: ./start.sh"
echo ""
```

### 3. Make Scripts Executable

```bash
chmod +x /Users/maxwell/Projects/mediamax/start.sh
chmod +x /Users/maxwell/Projects/mediamax/stop.sh
```

---

## Script Features

### start.sh Features

1. **Prerequisites Check**:
   - Validates `.env` file exists
   - Warns if Real-Debrid API key is not configured
   - Checks if Docker is running

2. **Directory Creation**:
   - Creates all required directories if missing
   - Ensures config and media directories exist

3. **Image Management**:
   - Pulls latest images before starting
   - Ensures all containers use current versions

4. **Graceful Startup**:
   - Uses `docker compose up -d` for background operation
   - Waits for services to initialize
   - Shows container status

5. **User Guidance**:
   - Displays all service URLs
   - Provides next steps
   - Shows helpful commands

### stop.sh Features

1. **Safe Shutdown**:
   - Checks if compose file exists
   - Checks if containers are running
   - Gracefully stops all services

2. **User Feedback**:
   - Confirms shutdown
   - Reminds how to restart

---

## Success Criteria

Before marking this step complete, verify:

1. **start.sh created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/start.sh && echo "✓ start.sh exists"
   ```

2. **stop.sh created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/stop.sh && echo "✓ stop.sh exists"
   ```

3. **Scripts are executable:**
   ```bash
   test -x /Users/maxwell/Projects/mediamax/start.sh && echo "✓ start.sh is executable"
   test -x /Users/maxwell/Projects/mediamax/stop.sh && echo "✓ stop.sh is executable"
   ```

4. **Scripts have correct shebang:**
   ```bash
   head -n 1 /Users/maxwell/Projects/mediamax/start.sh | grep -q "#!/bin/bash" && echo "✓ start.sh has bash shebang"
   head -n 1 /Users/maxwell/Projects/mediamax/stop.sh | grep -q "#!/bin/bash" && echo "✓ stop.sh has bash shebang"
   ```

5. **Scripts contain expected content:**
   ```bash
   grep -q "Real-Debrid API key" /Users/maxwell/Projects/mediamax/start.sh && echo "✓ start.sh checks API key"
   grep -q "docker compose down" /Users/maxwell/Projects/mediamax/stop.sh && echo "✓ stop.sh uses compose down"
   ```

---

## Archon Task Update

Mark task as in_progress at start:

```bash
curl -X PUT "http://localhost:8181/api/tasks/f3324e99-13fb-4fc7-831d-072d594a918d" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

When finished and verified:

```bash
curl -X PUT "http://localhost:8181/api/tasks/f3324e99-13fb-4fc7-831d-072d594a918d" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

---

## Notes

- This is step 3 of 6 in the sequential plan
- Depends on Step 2 (docker-compose.yml must exist)
- Next step will create setup documentation
- Do NOT run the scripts yet - this step only creates them
- Scripts include error checking and user-friendly output
- Both scripts use `set -e` to exit on any error
