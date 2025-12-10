# Step 4: Setup Documentation

**Archon Task ID:** `76ff58f0-88b9-4b0e-a258-8fcebe0aa7da`
**Project:** media-server-stack
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Depends On:** Step 3 (Automation Scripts)

---

## Context

The docker-compose.yml and automation scripts have been created. Now you need to create comprehensive setup documentation that guides users through configuring all 8 services in the correct order.

This is the most important documentation file - users will follow it step-by-step to connect all services together and create a working media automation pipeline.

---

## Your Task

Create `/Users/maxwell/Projects/mediamax/SETUP_GUIDE.md` with detailed configuration instructions for all services.

### SETUP_GUIDE.md Content

```markdown
# Media Server Stack - Setup Guide

This guide walks you through configuring each service after running `./start.sh`. Services must be configured in the order shown to ensure proper integration.

## Prerequisites

Before starting, ensure:
- ✅ All containers are running: `docker compose ps`
- ✅ You have a Real-Debrid premium account
- ✅ You have your Real-Debrid API key from https://real-debrid.com/apitoken

---

## Configuration Order

Configure services in this exact order:

1. **RDTClient** - Configure Real-Debrid integration
2. **Prowlarr** - Add indexers and Flaresolverr
3. **Radarr** - Connect to RDTClient and Prowlarr
4. **Sonarr** - Connect to RDTClient and Prowlarr
5. **Bazarr** - Connect to Radarr and Sonarr
6. **Jellyfin** - Add media libraries
7. **Jellyseerr** - Connect to Jellyfin, Radarr, and Sonarr

---

## 1. RDTClient Configuration

**URL:** http://localhost:6500

### First-Time Setup

1. Open http://localhost:6500
2. Create an admin account (username/password)
3. Log in with your new admin credentials

### Configure Real-Debrid

1. Go to **Settings** (gear icon)
2. Navigate to **Download Client** tab
3. Select **Real-Debrid** as the provider
4. Enter your **Real-Debrid API key** (from https://real-debrid.com/apitoken)
5. Click **Test** to verify connection
6. Click **Save**

### Download Settings

1. Still in **Settings** → **Download Client**:
   - ✅ Enable "Automatic download"
   - ✅ Enable "Automatic unpack"
   - Set **Minimum file size**: `100` MB (avoids sample files)
   - Set **Download path**: `/data/downloads` (default)
   - Click **Save**

### qBittorrent Emulation Settings

1. Go to **Settings** → **qBittorrent / *Arr**
2. Note the **Username** and **Password** (or set your own)
3. Keep **Port**: `6500`
4. Click **Save**

**Important:** Write down the username and password - you'll need them for Radarr and Sonarr.

---

## 2. Prowlarr Configuration

**URL:** http://localhost:9696

### Initial Setup

1. Open http://localhost:9696
2. Complete the quick setup wizard (if prompted)
3. Go to **Settings** → **General**
4. Note your **API Key** (you'll need this for Radarr/Sonarr)

### Add Flaresolverr (Optional but Recommended)

Some indexers are protected by Cloudflare and require Flaresolverr.

1. Go to **Settings** → **Indexers**
2. Scroll down to **Indexer Proxies**
3. Click **+** to add a proxy
4. Select **FlareSolverr**
5. Configure:
   - **Name**: `FlareSolverr`
   - **Tags**: Leave empty (or add tag if you want to use it selectively)
   - **Host**: `http://flaresolverr:8191/`
6. Click **Test** then **Save**

### Add Indexers

Prowlarr supports hundreds of indexers. Here are recommended public indexers:

1. Go to **Indexers** → **Add Indexer**
2. Search and add these popular public indexers:

   **For Movies:**
   - **YTS** (YIFY Torrents) - Small file sizes, good for movies
   - **1337x** - General purpose, large selection
   - **The Pirate Bay** (TPB) - Classic, needs Flaresolverr
   - **TorrentGalaxy** - Good selection

   **For TV Shows:**
   - **EZTV** - Specializes in TV shows
   - **1337x** - Also good for TV
   - **TorrentGalaxy** - Also good for TV

3. For each indexer:
   - Click on the indexer name
   - If it says "Cloudflare Protected", select **FlareSolverr** in the proxy dropdown
   - Click **Test** to verify it works
   - Click **Save**

**Tip:** Start with 3-5 indexers. You can add more later.

### Connect to Radarr and Sonarr

This syncs indexers to Radarr/Sonarr automatically.

1. Go to **Settings** → **Apps**
2. Click **+** to add an application
3. Select **Radarr**
4. Configure:
   - **Sync Level**: `Full Sync`
   - **Prowlarr Server**: `http://prowlarr:9696`
   - **Radarr Server**: `http://radarr:7878`
   - **API Key**: (from Radarr - see next section)
5. Click **Test** then **Save**

6. Repeat for **Sonarr**:
   - **Sync Level**: `Full Sync`
   - **Prowlarr Server**: `http://prowlarr:9696`
   - **Sonarr Server**: `http://sonarr:8989`
   - **API Key**: (from Sonarr - see next section)

**Note:** You'll need to get API keys from Radarr and Sonarr first, then come back to complete this step.

---

## 3. Radarr Configuration

**URL:** http://localhost:7878

### Initial Setup

1. Open http://localhost:7878
2. Complete authentication setup if prompted
3. Go to **Settings** → **General**
4. Note your **API Key** (copy it to Prowlarr if you haven't already)

### Media Management

1. Go to **Settings** → **Media Management**
2. **Root Folders**:
   - Click **Add Root Folder**
   - Path: `/media/movies`
   - Click **OK**
3. **File Management**:
   - ✅ Enable "Rename Movies"
   - ✅ Enable "Replace Illegal Characters"
4. **File Naming** (click "Show"):
   - **Standard Movie Format**:
     ```
     {Movie Title} ({Release Year})/{Movie Title} ({Release Year}) - {Quality Full}
     ```
   - This creates: `Inception (2010)/Inception (2010) - Bluray-1080p.mkv`
5. Click **Save Changes**

### Add Download Client (RDTClient)

1. Go to **Settings** → **Download Clients**
2. Click **+** to add a download client
3. Select **qBittorrent**
4. Configure:
   - **Name**: `RDTClient`
   - **Enable**: ✅ Yes
   - **Host**: `rdtclient`
   - **Port**: `6500`
   - **Username**: (from RDTClient settings)
   - **Password**: (from RDTClient settings)
   - **Category**: `movies`
   - **Priority**: `1`
5. Click **Test** - should show green checkmark
6. Click **Save**

### Configure Quality Profiles

1. Go to **Settings** → **Profiles**
2. Edit the **HD-1080p** profile (or create your own)
3. Ensure desired qualities are checked
4. Click **Save**

### Sync Indexers from Prowlarr

1. In **Prowlarr** → **Settings** → **Apps**
2. Find your Radarr connection
3. Click **Sync App Indexers**
4. In **Radarr** → **Settings** → **Indexers**, you should now see all Prowlarr indexers

---

## 4. Sonarr Configuration

**URL:** http://localhost:8989

### Initial Setup

1. Open http://localhost:8989
2. Complete authentication setup if prompted
3. Go to **Settings** → **General**
4. Note your **API Key** (copy it to Prowlarr if you haven't already)

### Media Management

1. Go to **Settings** → **Media Management**
2. **Root Folders**:
   - Click **Add Root Folder**
   - Path: `/media/tv`
   - Click **OK**
3. **Episode Naming**:
   - ✅ Enable "Rename Episodes"
   - ✅ Enable "Replace Illegal Characters"
4. **Episode File Naming** (click "Show"):
   - **Standard Episode Format**:
     ```
     {Series Title}/Season {season:00}/{Series Title} - S{season:00}E{episode:00} - {Episode Title} - {Quality Full}
     ```
   - This creates: `Breaking Bad/Season 01/Breaking Bad - S01E01 - Pilot - Bluray-1080p.mkv`
5. Click **Save Changes**

### Add Download Client (RDTClient)

1. Go to **Settings** → **Download Clients**
2. Click **+** to add a download client
3. Select **qBittorrent**
4. Configure:
   - **Name**: `RDTClient`
   - **Enable**: ✅ Yes
   - **Host**: `rdtclient`
   - **Port**: `6500`
   - **Username**: (from RDTClient settings)
   - **Password**: (from RDTClient settings)
   - **Category**: `tv`
   - **Priority**: `1`
5. Click **Test** - should show green checkmark
6. Click **Save**

### Configure Quality Profiles

1. Go to **Settings** → **Profiles**
2. Edit the **HD-1080p** profile (or create your own)
3. Ensure desired qualities are checked
4. Click **Save**

### Sync Indexers from Prowlarr

1. In **Prowlarr** → **Settings** → **Apps**
2. Find your Sonarr connection
3. Click **Sync App Indexers**
4. In **Sonarr** → **Settings** → **Indexers**, you should now see all Prowlarr indexers

---

## 5. Bazarr Configuration

**URL:** http://localhost:6767

### Initial Setup

1. Open http://localhost:6767
2. Complete the setup wizard:
   - Select your preferred languages for subtitles
   - Configure general settings

### Connect to Sonarr

1. Go to **Settings** → **Sonarr**
2. ✅ Enable "Use Sonarr"
3. Configure:
   - **Address**: `sonarr`
   - **Port**: `8989`
   - **API Key**: (from Sonarr → Settings → General)
   - **Base URL**: Leave empty
4. Click **Test** then **Save**

### Connect to Radarr

1. Go to **Settings** → **Radarr**
2. ✅ Enable "Use Radarr"
3. Configure:
   - **Address**: `radarr`
   - **Port**: `7878`
   - **API Key**: (from Radarr → Settings → General)
   - **Base URL**: Leave empty
4. Click **Test** then **Save**

### Add Subtitle Providers

1. Go to **Settings** → **Providers**
2. Click **Add New Provider**
3. Recommended providers:

   **OpenSubtitles.com** (Requires free account):
   - Sign up at https://www.opensubtitles.com/
   - Get API key from your account
   - Add provider with your credentials

   **Subscene**:
   - No account needed
   - Just enable it

   **Addic7ed** (Good for TV shows):
   - May require free account
   - Configure with your credentials

4. Click **Save**

### Configure Languages

1. Go to **Settings** → **Languages**
2. Add your preferred subtitle languages (e.g., English)
3. Set language profiles
4. Click **Save**

---

## 6. Jellyfin Configuration

**URL:** http://localhost:8096

### Initial Setup Wizard

1. Open http://localhost:8096
2. Select your **preferred language**
3. Create an **admin user** (username/password)
4. Click **Next**

### Add Media Libraries

1. **Add Movie Library**:
   - Click **Add Media Library**
   - **Content type**: `Movies`
   - **Display name**: `Movies`
   - Click **+** next to Folders
   - Select `/data/movies`
   - Click **OK**
   - Click **Next**

2. **Add TV Library**:
   - Click **Add Media Library**
   - **Content type**: `Shows`
   - **Display name**: `TV Shows`
   - Click **+** next to Folders
   - Select `/data/tv`
   - Click **OK**
   - Click **Next**

3. Complete the wizard

### Configure Metadata

1. Go to **Dashboard** → **Libraries**
2. For each library, click **⋮** → **Manage Library**
3. Configure metadata providers (default settings are usually fine)

### Optional: Enable Hardware Acceleration

For better performance on Apple Silicon:
1. Go to **Dashboard** → **Playback**
2. **Hardware acceleration**: Try `Video Toolbox` (macOS)
3. Click **Save**

---

## 7. Jellyseerr Configuration

**URL:** http://localhost:5055

### Initial Setup

1. Open http://localhost:5055
2. Select **Use Jellyfin Account**
3. Click **Continue**

### Connect to Jellyfin

1. **Jellyfin URL**: `http://jellyfin:8096`
2. Click **Connect**
3. **Sign in** with your Jellyfin admin credentials
4. **Sync Libraries**: Select which libraries to use (Movies, TV Shows)
5. Click **Continue**

### Connect to Radarr (Movies)

1. **Add Radarr Server**:
   - **Default Server**: ✅ Yes
   - **4K Server**: ☐ No
   - **Server Name**: `Radarr`
   - **Hostname or IP**: `radarr`
   - **Port**: `7878`
   - **Use SSL**: ☐ No
   - **API Key**: (from Radarr → Settings → General)
2. Click **Test** - should succeed
3. Configure:
   - **Quality Profile**: Select your preferred profile (e.g., `HD-1080p`)
   - **Root Folder**: `/media/movies`
   - **Minimum Availability**: `Released` (or `Announced` for pre-releases)
   - **Tags**: Leave empty
4. Click **Add Server**

### Connect to Sonarr (TV Shows)

1. **Add Sonarr Server**:
   - **Default Server**: ✅ Yes
   - **4K Server**: ☐ No
   - **Server Name**: `Sonarr`
   - **Hostname or IP**: `sonarr`
   - **Port**: `8989`
   - **Use SSL**: ☐ No
   - **API Key**: (from Sonarr → Settings → General)
2. Click **Test** - should succeed
3. Configure:
   - **Quality Profile**: Select your preferred profile (e.g., `HD-1080p`)
   - **Root Folder**: `/media/tv`
   - **Language Profile**: `English` (or your preference)
   - **Tags**: Leave empty
4. Click **Add Server**

### Finish Setup

1. Click **Finish Setup**
2. You're now ready to request content!

---

## Verification

After completing all configurations, verify integration:

### Test 1: Indexer Sync
- Radarr → Settings → Indexers should show all Prowlarr indexers
- Sonarr → Settings → Indexers should show all Prowlarr indexers

### Test 2: Download Client Connection
- Radarr → Settings → Download Clients → RDTClient should have green checkmark
- Sonarr → Settings → Download Clients → RDTClient should have green checkmark

### Test 3: Bazarr Connection
- Bazarr → Settings → Sonarr → Test should succeed
- Bazarr → Settings → Radarr → Test should succeed

### Test 4: Jellyseerr Connection
- Jellyseerr → Settings → Radarr should show "Connected"
- Jellyseerr → Settings → Sonarr should show "Connected"
- Jellyseerr → Settings → Jellyfin should show "Connected"

---

## Next Steps

Your media server stack is now configured! See `VERIFICATION.md` for end-to-end testing instructions.

## Troubleshooting

If you encounter issues, see `TROUBLESHOOTING.md` for common problems and solutions.
```

---

## Success Criteria

Before marking this step complete, verify:

1. **File created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/SETUP_GUIDE.md && echo "✓ SETUP_GUIDE.md exists"
   ```

2. **File has substantial content:**
   ```bash
   wc -l /Users/maxwell/Projects/mediamax/SETUP_GUIDE.md
   ```
   Should show 500+ lines

3. **Contains all service sections:**
   ```bash
   grep -c "## [1-7]\\." /Users/maxwell/Projects/mediamax/SETUP_GUIDE.md
   ```
   Should return 7 (one section for each service)

4. **Contains verification section:**
   ```bash
   grep -q "## Verification" /Users/maxwell/Projects/mediamax/SETUP_GUIDE.md && echo "✓ Has verification section"
   ```

---

## Archon Task Update

Mark task as in_progress at start:

```bash
curl -X PUT "http://localhost:8181/api/tasks/76ff58f0-88b9-4b0e-a258-8fcebe0aa7da" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

When finished and verified:

```bash
curl -X PUT "http://localhost:8181/api/tasks/76ff58f0-88b9-4b0e-a258-8fcebe0aa7da" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

---

## Notes

- This is step 4 of 6 in the sequential plan
- This is the most comprehensive documentation file
- Configuration order is critical for successful integration
- Next step will create verification and troubleshooting documentation
- Do NOT actually configure the services - just create the documentation
