# Step 2: Docker Compose Setup

**Archon Task ID:** `bb02d496-4d6c-4203-a304-615f9e329fd2`
**Project:** media-server-stack
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Depends On:** Step 1 (Project Structure)

---

## Context

You are creating the Docker Compose configuration for a complete media server stack running on macOS (Apple Silicon M3 Ultra). The directory structure has been created in Step 1.

The stack includes 8 services that work together:
- **RDTClient**: Real-Debrid download client (emulates qBittorrent API)
- **Radarr**: Movie management
- **Sonarr**: TV show management
- **Prowlarr**: Centralized indexer management
- **Bazarr**: Subtitle automation
- **Jellyfin**: Media server/player
- **Jellyseerr**: Request management UI
- **Flaresolverr**: Cloudflare bypass for indexers

---

## Your Task

Create a comprehensive `docker-compose.yml` file that defines all 8 services with proper networking, volumes, and dependencies.

### Requirements

1. **All images must be ARM64 compatible** (Apple Silicon)
2. **Use a custom bridge network** named `media-network` for inter-container communication
3. **All containers use `restart: unless-stopped`**
4. **LinuxServer.io containers** (Radarr, Sonarr, Prowlarr, Bazarr) use PUID=1000, PGID=1000, TZ=America/Chicago
5. **Volume mounts** must map to the directory structure created in Step 1
6. **Service dependencies** must be properly defined
7. **Use environment variables from .env** where appropriate

### Docker Compose File

Create `/Users/maxwell/Projects/mediamax/docker-compose.yml` with the following content:

```yaml
services:
  # Real-Debrid Download Client
  rdtclient:
    image: rogerfar/rdtclient:latest
    container_name: rdtclient
    restart: unless-stopped
    ports:
      - "${RDTCLIENT_PORT:-6500}:6500"
    volumes:
      - ./config/rdtclient:/data/db
      - ./media/downloads:/data/downloads
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6500"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Indexer Manager
  prowlarr:
    image: linuxserver/prowlarr:latest
    container_name: prowlarr
    restart: unless-stopped
    ports:
      - "${PROWLARR_PORT:-9696}:9696"
    volumes:
      - ./config/prowlarr:/config
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9696"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Movie Management
  radarr:
    image: linuxserver/radarr:latest
    container_name: radarr
    restart: unless-stopped
    ports:
      - "${RADARR_PORT:-7878}:7878"
    volumes:
      - ./config/radarr:/config
      - ./media:/media
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    depends_on:
      rdtclient:
        condition: service_healthy
      prowlarr:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7878"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # TV Show Management
  sonarr:
    image: linuxserver/sonarr:latest
    container_name: sonarr
    restart: unless-stopped
    ports:
      - "${SONARR_PORT:-8989}:8989"
    volumes:
      - ./config/sonarr:/config
      - ./media:/media
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    depends_on:
      rdtclient:
        condition: service_healthy
      prowlarr:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8989"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Subtitle Management
  bazarr:
    image: linuxserver/bazarr:latest
    container_name: bazarr
    restart: unless-stopped
    ports:
      - "${BAZARR_PORT:-6767}:6767"
    volumes:
      - ./config/bazarr:/config
      - ./media:/media
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    depends_on:
      radarr:
        condition: service_healthy
      sonarr:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6767"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # Media Server
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    ports:
      - "${JELLYFIN_PORT:-8096}:8096"
    volumes:
      - ./config/jellyfin:/config
      - ./media/movies:/data/movies:ro
      - ./media/tv:/data/tv:ro
    environment:
      - PUID=${PUID:-1000}
      - PGID=${PGID:-1000}
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    # Hardware acceleration for Apple Silicon (optional)
    # Uncomment if you want to enable hardware transcoding
    # devices:
    #   - /dev/dri:/dev/dri
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8096/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # Request Management UI
  jellyseerr:
    image: fallenbagel/jellyseerr:latest
    container_name: jellyseerr
    restart: unless-stopped
    ports:
      - "${JELLYSEERR_PORT:-5055}:5055"
    volumes:
      - ./config/jellyseerr:/app/config
    environment:
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    depends_on:
      jellyfin:
        condition: service_healthy
      radarr:
        condition: service_healthy
      sonarr:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:5055"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  # Cloudflare Bypass
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    ports:
      - "${FLARESOLVERR_PORT:-8191}:8191"
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ:-America/Chicago}
    networks:
      - media-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8191/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

networks:
  media-network:
    driver: bridge
    name: media-network
```

### Key Design Decisions

1. **Health Checks**: All services have health checks to ensure proper startup order and dependency management

2. **Volume Mappings**:
   - Config directories: `./config/<service>` → `/config` (or `/data/db` for RDTClient)
   - Media access: `./media` → `/media` for Radarr, Sonarr, Bazarr (read-write)
   - Jellyfin: Read-only access to final libraries (`/data/movies:ro`, `/data/tv:ro`)

3. **Network**: Single custom bridge network (`media-network`) allows services to communicate by container name

4. **Dependencies**: Services depend on their prerequisites with health check conditions

5. **Environment Variables**: All configurable values use `.env` with sensible defaults

6. **Port Configuration**: All ports are configurable via `.env` to handle conflicts

7. **ARM64 Compatibility**: All selected images support Apple Silicon

---

## Success Criteria

Before marking this step complete, verify:

1. **File created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/docker-compose.yml && echo "✓ File exists"
   ```

2. **Valid YAML syntax:**
   ```bash
   docker compose -f /Users/maxwell/Projects/mediamax/docker-compose.yml config > /dev/null && echo "✓ Valid YAML"
   ```

3. **All services defined:**
   ```bash
   docker compose -f /Users/maxwell/Projects/mediamax/docker-compose.yml config --services
   ```
   Should output all 8 services: rdtclient, prowlarr, radarr, sonarr, bazarr, jellyfin, jellyseerr, flaresolverr

4. **Network defined:**
   ```bash
   docker compose -f /Users/maxwell/Projects/mediamax/docker-compose.yml config --networks
   ```
   Should output: media-network

5. **No syntax errors:**
   ```bash
   docker compose -f /Users/maxwell/Projects/mediamax/docker-compose.yml config 2>&1 | grep -i error
   ```
   Should return nothing (no errors)

---

## Archon Task Update

Mark task as in_progress at start:

```bash
curl -X PUT "http://localhost:8181/api/tasks/bb02d496-4d6c-4203-a304-615f9e329fd2" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

When finished and verified:

```bash
curl -X PUT "http://localhost:8181/api/tasks/bb02d496-4d6c-4203-a304-615f9e329fd2" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

---

## Notes

- This is step 2 of 6 in the sequential plan
- Depends on Step 1 (directory structure must exist)
- Next step will create automation scripts (start.sh, stop.sh)
- Do NOT start the containers yet - just create the configuration
- The compose file uses health checks for proper startup sequencing
- All volume paths are relative to support easy relocation
