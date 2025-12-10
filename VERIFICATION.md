# Setup Verification Checklist

Use this checklist to verify your media server stack is properly configured and working end-to-end.

---

## Phase 1: Container Health

### All Containers Running

```bash
docker compose ps
```

**Expected:** All 8 containers show status "Up" and healthy:
- [ ] rdtclient
- [ ] prowlarr
- [ ] radarr
- [ ] sonarr
- [ ] bazarr
- [ ] jellyfin
- [ ] jellyseerr
- [ ] flaresolverr

### No Restart Loops

```bash
docker compose ps --format "table {{.Name}}\t{{.Status}}"
```

**Expected:** All containers show "Up" without "(restarting)" or recent restart counts.

### Check Logs for Errors

```bash
docker compose logs --tail=50 | grep -i error
```

**Expected:** No critical errors. Some "error" mentions may be normal (e.g., failed login attempts, unavailable features).

---

## Phase 2: Service Accessibility

### Access All Web UIs

Verify each service loads without errors:

- [ ] **RDTClient**: http://localhost:6500
  - Should show login page or dashboard
- [ ] **Prowlarr**: http://localhost:9696
  - Should show indexer management interface
- [ ] **Radarr**: http://localhost:7878
  - Should show movie management interface
- [ ] **Sonarr**: http://localhost:8989
  - Should show TV show management interface
- [ ] **Bazarr**: http://localhost:6767
  - Should show subtitle management interface
- [ ] **Jellyfin**: http://localhost:8096
  - Should show media player interface
- [ ] **Jellyseerr**: http://localhost:5055
  - Should show request management interface
- [ ] **Flaresolverr**: http://localhost:8191
  - Should show simple status page

---

## Phase 3: Configuration Verification

### RDTClient

- [ ] Real-Debrid API key configured
- [ ] Connection test succeeds
- [ ] Download path set to `/data/downloads`
- [ ] qBittorrent emulation enabled with username/password

### Prowlarr

- [ ] At least 3 indexers added and working
- [ ] Flaresolverr proxy added (if using Cloudflare-protected indexers)
- [ ] Radarr app connection configured with API key
- [ ] Sonarr app connection configured with API key

### Radarr

- [ ] API key noted
- [ ] Root folder set to `/media/movies`
- [ ] RDTClient download client added and tested (green checkmark)
- [ ] Indexers synced from Prowlarr (Settings → Indexers shows multiple indexers)
- [ ] Quality profile configured

### Sonarr

- [ ] API key noted
- [ ] Root folder set to `/media/tv`
- [ ] RDTClient download client added and tested (green checkmark)
- [ ] Indexers synced from Prowlarr (Settings → Indexers shows multiple indexers)
- [ ] Quality profile configured

### Bazarr

- [ ] Connected to Radarr (test succeeds)
- [ ] Connected to Sonarr (test succeeds)
- [ ] At least one subtitle provider added
- [ ] Preferred languages configured

### Jellyfin

- [ ] Admin user created
- [ ] Movies library added pointing to `/data/movies`
- [ ] TV Shows library added pointing to `/data/tv`
- [ ] Libraries are empty (no content yet - this is expected)

### Jellyseerr

- [ ] Connected to Jellyfin (shows "Connected")
- [ ] Connected to Radarr (shows "Connected")
- [ ] Connected to Sonarr (shows "Connected")
- [ ] Radarr quality profile and root folder configured
- [ ] Sonarr quality profile and root folder configured

---

## Phase 4: Integration Tests

### Test 1: Prowlarr → Radarr Indexer Sync

1. In Radarr, go to **Settings** → **Indexers**
2. **Expected:** Multiple indexers from Prowlarr are listed
3. Click **Test All** (if available)
4. **Expected:** All or most indexers test successfully

**Status:** [ ] PASS / [ ] FAIL

### Test 2: Prowlarr → Sonarr Indexer Sync

1. In Sonarr, go to **Settings** → **Indexers**
2. **Expected:** Multiple indexers from Prowlarr are listed
3. Click **Test All** (if available)
4. **Expected:** All or most indexers test successfully

**Status:** [ ] PASS / [ ] FAIL

### Test 3: RDTClient Connection from Radarr

1. In Radarr, go to **Settings** → **Download Clients**
2. Find **RDTClient**
3. Click **Test**
4. **Expected:** Green checkmark, no errors

**Status:** [ ] PASS / [ ] FAIL

### Test 4: RDTClient Connection from Sonarr

1. In Sonarr, go to **Settings** → **Download Clients**
2. Find **RDTClient**
3. Click **Test**
4. **Expected:** Green checkmark, no errors

**Status:** [ ] PASS / [ ] FAIL

### Test 5: Bazarr Connections

1. In Bazarr, go to **Settings** → **Radarr**
2. Click **Test**
3. **Expected:** Success message
4. Go to **Settings** → **Sonarr**
5. Click **Test**
6. **Expected:** Success message

**Status:** [ ] PASS / [ ] FAIL

---

## Phase 5: End-to-End Test (Movie)

This is the most important test - it verifies the entire pipeline works.

### Step 1: Request a Movie in Radarr

1. In Radarr, click **Movies** → **Add New**
2. Search for a popular movie (e.g., "Inception")
3. Select the movie
4. Configure:
   - **Root Folder**: `/media/movies`
   - **Quality Profile**: Your preferred profile
   - **Monitor**: Yes
   - **Start search for missing movie**: Yes
5. Click **Add Movie**

**Expected:** Movie added to Radarr

**Status:** [ ] PASS / [ ] FAIL

### Step 2: Verify Search Started

1. In Radarr, click **Activity** (top menu)
2. Look in the **Queue** tab
3. **Expected:** Movie appears with status "Downloading" or "Searching"

**Status:** [ ] PASS / [ ] FAIL

### Step 3: Verify Download in RDTClient

1. Open RDTClient: http://localhost:6500
2. Check the downloads page
3. **Expected:** Movie appears in download queue
4. Wait for download to complete (usually 1-5 minutes with Real-Debrid)
5. **Expected:** Download shows 100% complete

**Status:** [ ] PASS / [ ] FAIL

### Step 4: Verify Import to Radarr

1. In Radarr, go to **Activity** → **Queue**
2. **Expected:** Movie shows "Importing"
3. Wait for import to complete (usually under 1 minute)
4. Go to **Movies**
5. **Expected:** Movie shows green checkmark (downloaded)

**Status:** [ ] PASS / [ ] FAIL

### Step 5: Verify File Exists

```bash
ls -lh /Users/maxwell/Projects/mediamax/media/movies/
```

**Expected:** Directory for the movie exists with video file inside

**Status:** [ ] PASS / [ ] FAIL

### Step 6: Verify Movie Appears in Jellyfin

1. In Jellyfin, go to **Dashboard** → **Libraries**
2. Find **Movies** library
3. Click **Scan Library**
4. Wait for scan to complete
5. Go to home page
6. **Expected:** Movie appears in Movies library

**Status:** [ ] PASS / [ ] FAIL

### Step 7: Verify Playback in Jellyfin

1. Click on the movie
2. Click **Play**
3. **Expected:** Movie starts playing without errors

**Status:** [ ] PASS / [ ] FAIL

### Step 8: Verify Subtitles (Optional)

1. Wait a few minutes for Bazarr to process
2. In Bazarr, check if subtitles were downloaded
3. In Jellyfin, play the movie and check if subtitles are available

**Status:** [ ] PASS / [ ] FAIL / [ ] SKIPPED

---

## Phase 6: End-to-End Test (TV Show via Jellyseerr)

This tests the Jellyseerr request workflow.

### Step 1: Request TV Show in Jellyseerr

1. Open Jellyseerr: http://localhost:5055
2. Search for a popular TV show (e.g., "Breaking Bad")
3. Click on the show
4. Select **Request**
5. Choose seasons to request (e.g., Season 1)
6. Click **Request**

**Expected:** Request submitted successfully

**Status:** [ ] PASS / [ ] FAIL

### Step 2: Verify Show Added to Sonarr

1. In Sonarr, go to **Series**
2. **Expected:** TV show appears in the list
3. Go to **Activity** → **Queue**
4. **Expected:** Episodes appear in queue

**Status:** [ ] PASS / [ ] FAIL

### Step 3: Verify Downloads

1. Check RDTClient for active downloads
2. **Expected:** Episodes downloading
3. Wait for downloads to complete
4. **Expected:** Episodes imported to Sonarr

**Status:** [ ] PASS / [ ] FAIL

### Step 4: Verify in Jellyfin

1. In Jellyfin, scan TV Shows library
2. **Expected:** TV show appears with downloaded episodes
3. Test playback
4. **Expected:** Episodes play correctly

**Status:** [ ] PASS / [ ] FAIL

---

## Summary

### Quick Status Check

```bash
# Container count (should be 8)
docker compose ps --quiet | wc -l

# Healthy containers (should be 8)
docker compose ps --format "{{.Name}}" | wc -l

# Check if all critical services are responding
curl -I http://localhost:6500 2>/dev/null | head -n 1
curl -I http://localhost:7878 2>/dev/null | head -n 1
curl -I http://localhost:8989 2>/dev/null | head -n 1
curl -I http://localhost:8096 2>/dev/null | head -n 1
curl -I http://localhost:5055 2>/dev/null | head -n 1
```

### Overall Status

- [ ] All Phase 1 checks passed (Container Health)
- [ ] All Phase 2 checks passed (Service Accessibility)
- [ ] All Phase 3 checks passed (Configuration)
- [ ] All Phase 4 checks passed (Integration Tests)
- [ ] Phase 5 passed (End-to-End Movie Test)
- [ ] Phase 6 passed (End-to-End TV Test via Jellyseerr)

**Setup Complete:** [ ] YES / [ ] NO

---

## If Any Tests Failed

See `TROUBLESHOOTING.md` for common issues and solutions.
