# HANDOFF: Media Server Stack Setup

You are receiving a handoff for implementing a complete self-hosted media server stack with Real-Debrid integration.

---

## Project Overview

**Project Name:** media-server-stack
**Archon Project ID:** 6462ddac-26e5-44a1-b537-8c3f869a694c
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Archon Host:** http://localhost:8181

### Objective

Set up a complete self-hosted media server stack with Real-Debrid integration for automated movie and TV show management. The system should allow the user to request media, have it automatically found and downloaded via Real-Debrid, and served through a media player interface.

### Environment

- **Host OS:** macOS (Mac Studio M3 Ultra)
- **Container Runtime:** Docker Desktop for Mac
- **Architecture:** ARM64 (Apple Silicon)
- **Network:** Local home network
- **Storage:** Local storage for downloaded media

### Stack Components

The complete stack includes 8 Docker services:

1. **RDTClient** (rogerfar/rdtclient) - Real-Debrid download client
2. **Radarr** (linuxserver/radarr) - Movie management
3. **Sonarr** (linuxserver/sonarr) - TV show management
4. **Prowlarr** (linuxserver/prowlarr) - Indexer management
5. **Bazarr** (linuxserver/bazarr) - Subtitle management
6. **Jellyfin** (jellyfin/jellyfin) - Media server/player
7. **Jellyseerr** (fallenbagel/jellyseerr) - Request management UI
8. **Flaresolverr** (ghcr.io/flaresolverr/flaresolverr) - Cloudflare bypass

---

## Implementation Plan

This project is broken into 6 sequential steps, each with its own prompt file:

### Step 1: Project Structure and Base Configuration
**File:** `01-project-structure-base-config.md`
**Task ID:** e9437627-c228-4a38-ae38-270985b572e4
**What:** Create directory structure (config/, media/), .env.example, and README.md
**Duration:** ~5-10 minutes

### Step 2: Docker Compose Setup
**File:** `02-docker-compose-setup.md`
**Task ID:** bb02d496-4d6c-4203-a304-615f9e329fd2
**What:** Create comprehensive docker-compose.yml with all 8 services
**Duration:** ~10-15 minutes
**Depends On:** Step 1

### Step 3: Automation Scripts
**File:** `03-automation-scripts.md`
**Task ID:** f3324e99-13fb-4fc7-831d-072d594a918d
**What:** Create start.sh and stop.sh scripts with proper permissions
**Duration:** ~5 minutes
**Depends On:** Step 2

### Step 4: Setup Documentation
**File:** `04-setup-documentation.md`
**Task ID:** 76ff58f0-88b9-4b0e-a258-8fcebe0aa7da
**What:** Create SETUP_GUIDE.md with step-by-step configuration for all services
**Duration:** ~15-20 minutes
**Depends On:** Step 3

### Step 5: Verification and Troubleshooting Documentation
**File:** `05-verification-troubleshooting.md`
**Task ID:** 9c359274-71b3-4bcd-bfae-8bada7db5749
**What:** Create VERIFICATION.md and TROUBLESHOOTING.md
**Duration:** ~15-20 minutes
**Depends On:** Step 4

### Step 6: Final Validation and Testing
**File:** `06-final-validation.md`
**Task ID:** c1a68773-5fd1-4ca5-a77e-fac0acf7a45f
**What:** Validate docker-compose.yml syntax, test scripts, verify all files
**Duration:** ~5-10 minutes
**Depends On:** Step 5

**Total Estimated Time:** 55-80 minutes

---

## Deliverables

At completion, the following files will exist in `/Users/maxwell/Projects/mediamax`:

### Configuration Files
- `docker-compose.yml` - Complete Docker Compose configuration with all 8 services
- `.env.example` - Environment variable template (user copies to `.env`)

### Automation Scripts
- `start.sh` - Startup script with prerequisites checking and user guidance
- `stop.sh` - Shutdown script

### Documentation
- `README.md` - Project overview with quick start instructions
- `SETUP_GUIDE.md` - Detailed step-by-step configuration for all 8 services
- `VERIFICATION.md` - Testing checklist with end-to-end validation
- `TROUBLESHOOTING.md` - Common issues and solutions
- `VALIDATION_REPORT.txt` - Final validation report (generated in step 6)

### Directory Structure
```
/Users/maxwell/Projects/mediamax/
├── docker-compose.yml
├── .env.example
├── start.sh
├── stop.sh
├── README.md
├── SETUP_GUIDE.md
├── VERIFICATION.md
├── TROUBLESHOOTING.md
├── config/
│   ├── rdtclient/
│   ├── radarr/
│   ├── sonarr/
│   ├── prowlarr/
│   ├── bazarr/
│   ├── jellyfin/
│   └── jellyseerr/
└── media/
    ├── downloads/
    │   ├── movies/
    │   └── tv/
    ├── movies/
    └── tv/
```

---

## Success Criteria

The setup is complete when:

1. ✅ All containers start without errors
2. ✅ User can add a movie in Radarr and it automatically:
   - Searches indexers
   - Sends to RDTClient
   - Downloads via Real-Debrid
   - Gets imported to the library
   - Appears in Jellyfin
3. ✅ User can request content through Jellyseerr and the flow completes automatically
4. ✅ Subtitles are automatically downloaded for content (via Bazarr)

---

## Important Notes

### Design Principles
- **Turnkey Setup:** Make configuration as automated as possible while remaining configurable
- **ARM64 Compatible:** All images must support Apple Silicon
- **Container Communication:** Use service names (not localhost) for inter-container references
- **User Experience:** Focus on clear documentation and helpful error messages
- **Security:** Include warnings about not committing sensitive files (.env)

### Technical Requirements
- All linuxserver.io containers use PUID=1000, PGID=1000, TZ=America/Chicago
- Use custom bridge network named `media-network`
- All containers use `restart: unless-stopped`
- Volume paths are relative to support easy relocation
- Health checks for proper startup sequencing
- Scripts include error checking and user feedback

### Don't Do
- Don't run the containers (user will do this after configuration)
- Don't assume prerequisites are installed (check and guide)
- Don't use placeholder values without clear instructions
- Don't skip validation steps

---

## Archon Integration

All steps are tracked in Archon:
- **Project:** media-server-stack (ID: 6462ddac-26e5-44a1-b537-8c3f869a694c)
- **Tasks:** 6 tasks created (one per step)
- **API:** http://localhost:8181/api/

Each prompt file contains the task ID and Archon update commands.

---

## Execution Instructions

The prompts are designed to be executed sequentially by Opus 4.5 sub-agents. Each prompt:
- Is self-contained with full context
- Has pre-populated Archon task ID
- Includes success criteria and verification commands
- Has explicit Archon status update commands

Execute in order:
1. 01-project-structure-base-config.md
2. 02-docker-compose-setup.md
3. 03-automation-scripts.md
4. 04-setup-documentation.md
5. 05-verification-troubleshooting.md
6. 06-final-validation.md

If any step fails, stop and resolve before continuing.

---

## ACTION REQUIRED

To execute this plan, use the **sequential-execution** skill.

The prompts are located in: `/Users/maxwell/Projects/mediamax/prompts/`

Invoke the sequential-execution skill to run the plan.
