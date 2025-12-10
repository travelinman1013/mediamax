# Step 5: Verification and Troubleshooting Documentation

**Archon Task ID:** `9c359274-71b3-4bcd-bfae-8bada7db5749`
**Project:** media-server-stack
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Depends On:** Step 4 (Setup Documentation)

---

## Context

The setup documentation has been created in Step 4. Now you need to create two additional documentation files:
1. **VERIFICATION.md** - Checklist to verify successful setup
2. **TROUBLESHOOTING.md** - Common issues and solutions

These files help users validate their setup and resolve problems independently.

---

## Your Task

Create two documentation files for verification and troubleshooting.

### 1. Create VERIFICATION.md

Create `/Users/maxwell/Projects/mediamax/VERIFICATION.md`:

```markdown
# Setup Verification Checklist

Use this checklist to verify your media server stack is properly configured and working end-to-end.

---

## Phase 1: Container Health

### All Containers Running

```bash
docker compose ps
```

**Expected:** All 8 containers show status "Up" and healthy:
- ✅ rdtclient
- ✅ prowlarr
- ✅ radarr
- ✅ sonarr
- ✅ bazarr
- ✅ jellyfin
- ✅ jellyseerr
- ✅ flaresolverr

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
   - **Start search for missing movie**: ✅ Yes
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
```

### 2. Create TROUBLESHOOTING.md

Create `/Users/maxwell/Projects/mediamax/TROUBLESHOOTING.md`:

```markdown
# Troubleshooting Guide

Common issues and solutions for the media server stack.

---

## General Debugging

### View All Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f radarr

# Last 100 lines
docker compose logs --tail=100

# Follow logs with timestamps
docker compose logs -f -t
```

### Check Container Status

```bash
# List all containers
docker compose ps

# Check resource usage
docker stats

# Inspect specific container
docker compose logs rdtclient --tail=50
```

### Restart Services

```bash
# Restart specific service
docker compose restart radarr

# Restart all services
docker compose restart

# Full restart (down then up)
docker compose down && docker compose up -d
```

---

## RDTClient Issues

### RDTClient Not Downloading

**Symptoms:** Downloads stuck at 0% or not starting

**Solutions:**

1. **Verify Real-Debrid API key:**
   ```bash
   docker compose logs rdtclient | grep -i "api"
   ```
   - Ensure API key is correct in RDTClient settings
   - Verify Real-Debrid account has premium status at https://real-debrid.com

2. **Check Real-Debrid account:**
   - Log in to https://real-debrid.com
   - Verify premium subscription is active
   - Check account limits (downloads per day)

3. **Test Real-Debrid connection:**
   - In RDTClient → Settings → Download Client
   - Click "Test" next to Real-Debrid configuration
   - Should show success message

4. **Check download path permissions:**
   ```bash
   ls -la /Users/maxwell/Projects/mediamax/media/downloads
   ```
   - Ensure directory is writable

### RDTClient Container Restarting

**Symptoms:** Container keeps restarting

**Solutions:**

1. **Check logs for errors:**
   ```bash
   docker compose logs rdtclient --tail=100
   ```

2. **Verify volume mounts:**
   ```bash
   docker compose config | grep -A 10 rdtclient
   ```

3. **Remove corrupted database:**
   ```bash
   docker compose stop rdtclient
   mv config/rdtclient config/rdtclient.backup
   docker compose up -d rdtclient
   ```
   - Note: This resets RDTClient configuration

---

## Prowlarr Issues

### Indexers Failing

**Symptoms:** Indexers show red X or fail to search

**Solutions:**

1. **Check if indexer requires Flaresolverr:**
   - If indexer says "Cloudflare Protected"
   - Ensure Flaresolverr is running: `docker compose ps flaresolverr`
   - Add Flaresolverr proxy in Prowlarr settings
   - URL: `http://flaresolverr:8191`

2. **Test individual indexer:**
   - In Prowlarr → Indexers
   - Click on indexer name
   - Click "Test"
   - Check error message

3. **Indexer temporarily down:**
   - Public indexers can be unreliable
   - Try different indexers
   - Wait and try again later

4. **Rate limiting:**
   - Some indexers limit requests
   - Reduce search frequency
   - Add more indexers for redundancy

### Indexers Not Syncing to Radarr/Sonarr

**Symptoms:** Radarr/Sonarr show no indexers

**Solutions:**

1. **Verify API keys:**
   - Check Radarr API key: http://localhost:7878 → Settings → General
   - Check Sonarr API key: http://localhost:8989 → Settings → General
   - Ensure correct API keys in Prowlarr → Settings → Apps

2. **Manual sync:**
   - In Prowlarr → Settings → Apps
   - Click "Sync App Indexers" button for each app

3. **Check connectivity:**
   - Test that services can reach each other:
   ```bash
   docker compose exec prowlarr wget -O- http://radarr:7878
   docker compose exec prowlarr wget -O- http://sonarr:8989
   ```

---

## Radarr/Sonarr Issues

### Downloads Not Importing

**Symptoms:** Files downloaded but not appearing in library

**Solutions:**

1. **Check Activity → Queue:**
   - Look for import errors
   - Common issues: file permissions, path mapping, quality not matching profile

2. **Verify path mappings:**
   - Download client category must match
   - RDTClient downloads to `/data/downloads`
   - Radarr/Sonarr should see same path

3. **Check file permissions:**
   ```bash
   ls -la /Users/maxwell/Projects/mediamax/media/downloads/movies/
   ```
   - Files should be readable by PUID 1000

4. **Manual import:**
   - Go to Activity → Manual Import
   - Select files to import manually
   - Check why automatic import failed

### "No indexers available" Error

**Symptoms:** Can't search for content

**Solutions:**

1. **Sync indexers from Prowlarr:**
   - In Prowlarr → Settings → Apps
   - Click "Sync App Indexers"

2. **Verify indexers in Radarr/Sonarr:**
   - Settings → Indexers
   - Should show multiple indexers
   - Test indexers

3. **Check indexer settings:**
   - Ensure indexers are enabled
   - Verify capabilities (search, RSS)

### Download Client Connection Failed

**Symptoms:** RDTClient shows red X

**Solutions:**

1. **Verify RDTClient is running:**
   ```bash
   docker compose ps rdtclient
   curl http://localhost:6500
   ```

2. **Check username/password:**
   - Must match RDTClient → Settings → qBittorrent settings
   - Case-sensitive

3. **Verify hostname:**
   - Use `rdtclient` (container name), not `localhost`

4. **Check category:**
   - Radarr should use category `movies`
   - Sonarr should use category `tv`

---

## Bazarr Issues

### Not Connecting to Radarr/Sonarr

**Symptoms:** Connection test fails

**Solutions:**

1. **Verify API keys:**
   - Get fresh API keys from Radarr/Sonarr
   - Re-enter in Bazarr settings

2. **Check hostnames:**
   - Use `radarr` and `sonarr`, not `localhost`

3. **Verify ports:**
   - Radarr: 7878
   - Sonarr: 8989

### Subtitles Not Downloading

**Symptoms:** No subtitles found or downloaded

**Solutions:**

1. **Check subtitle providers:**
   - Ensure at least one provider is configured
   - Test provider connection
   - Some providers require accounts

2. **Verify languages:**
   - Settings → Languages
   - Ensure desired languages are selected

3. **Check if content is monitored:**
   - Bazarr only downloads for content in Radarr/Sonarr
   - Verify movie/show exists in Radarr/Sonarr first

---

## Jellyfin Issues

### Library Not Showing Content

**Symptoms:** Movies/TV shows don't appear

**Solutions:**

1. **Manual library scan:**
   - Dashboard → Libraries
   - Click on library → Scan Library

2. **Verify library path:**
   - Dashboard → Libraries → Edit Library
   - Movies: `/data/movies`
   - TV: `/data/tv`

3. **Check file permissions:**
   ```bash
   ls -la /Users/maxwell/Projects/mediamax/media/movies/
   ls -la /Users/maxwell/Projects/mediamax/media/tv/
   ```

4. **Check file format:**
   - Jellyfin supports: MKV, MP4, AVI, etc.
   - Check if files are valid (not corrupted)

### Playback Issues

**Symptoms:** Buffering, stuttering, or won't play

**Solutions:**

1. **Check transcoding:**
   - Dashboard → Playback
   - Verify hardware acceleration settings
   - Try disabling hardware acceleration

2. **Check network:**
   - Ensure good network connection
   - Try lower quality settings

3. **Check codec support:**
   - Some codecs require transcoding
   - Check playback info for transcoding details

---

## Jellyseerr Issues

### Can't Connect to Jellyfin

**Symptoms:** Connection fails during setup

**Solutions:**

1. **Verify Jellyfin URL:**
   - Use `http://jellyfin:8096` (container name)
   - NOT `http://localhost:8096`

2. **Check Jellyfin is running:**
   ```bash
   docker compose ps jellyfin
   curl http://localhost:8096
   ```

3. **Use correct credentials:**
   - Jellyfin admin username/password

### Can't Connect to Radarr/Sonarr

**Symptoms:** Connection test fails

**Solutions:**

1. **Use container names:**
   - Radarr: `radarr` (not `localhost`)
   - Sonarr: `sonarr` (not `localhost`)

2. **Verify API keys:**
   - Get fresh keys from Radarr/Sonarr settings

3. **Check root folders:**
   - Radarr: `/media/movies`
   - Sonarr: `/media/tv`

### Requests Not Creating Downloads

**Symptoms:** Request succeeds but nothing downloads

**Solutions:**

1. **Check Radarr/Sonarr:**
   - Verify request appeared in Radarr/Sonarr
   - Check Activity → Queue for errors

2. **Verify quality profile:**
   - Ensure quality profile allows available releases

3. **Check indexers:**
   - Ensure indexers can find the content
   - Try manual search in Radarr/Sonarr

---

## Network Issues

### Services Can't Communicate

**Symptoms:** Services can't connect to each other

**Solutions:**

1. **Verify network exists:**
   ```bash
   docker network ls | grep media-network
   ```

2. **Check all containers on same network:**
   ```bash
   docker compose ps
   ```

3. **Recreate network:**
   ```bash
   docker compose down
   docker compose up -d
   ```

4. **Test connectivity:**
   ```bash
   docker compose exec radarr wget -O- http://prowlarr:9696
   ```

---

## Performance Issues

### Slow Download Speeds

**Solutions:**

1. **Check Real-Debrid status:**
   - Real-Debrid has its own speed limits
   - Check account status at https://real-debrid.com

2. **Check disk space:**
   ```bash
   df -h /Users/maxwell/Projects/mediamax
   ```

3. **Check Docker resources:**
   - Docker Desktop → Settings → Resources
   - Increase CPU/Memory if needed

### High CPU/Memory Usage

**Solutions:**

1. **Check which container:**
   ```bash
   docker stats
   ```

2. **Reduce concurrent operations:**
   - Limit simultaneous downloads
   - Reduce library scan frequency

3. **Increase Docker resources:**
   - Docker Desktop → Settings → Resources

---

## Docker Issues

### Containers Won't Start

**Symptoms:** `docker compose up` fails

**Solutions:**

1. **Check Docker is running:**
   ```bash
   docker info
   ```

2. **Check for port conflicts:**
   ```bash
   lsof -i :6500
   lsof -i :7878
   # ... check all ports
   ```

3. **Check compose file syntax:**
   ```bash
   docker compose config
   ```

4. **View startup errors:**
   ```bash
   docker compose up
   # (without -d to see output)
   ```

### Permission Denied Errors

**Symptoms:** Container can't write to volumes

**Solutions:**

1. **Check directory permissions:**
   ```bash
   ls -la /Users/maxwell/Projects/mediamax/
   ```

2. **Fix permissions:**
   ```bash
   chmod -R 755 config/
   chmod -R 755 media/
   ```

3. **Verify PUID/PGID:**
   - Check .env file has PUID=1000, PGID=1000

---

## Getting More Help

If issues persist:

1. **Check service-specific documentation:**
   - [Radarr Wiki](https://wiki.servarr.com/radarr)
   - [Sonarr Wiki](https://wiki.servarr.com/sonarr)
   - [Prowlarr Wiki](https://wiki.servarr.com/prowlarr)
   - [RDTClient GitHub](https://github.com/rogerfar/rdt-client)
   - [Jellyfin Docs](https://jellyfin.org/docs/)

2. **Collect diagnostic information:**
   ```bash
   # Container status
   docker compose ps > diagnostic.txt

   # Recent logs
   docker compose logs --tail=200 >> diagnostic.txt

   # System info
   docker info >> diagnostic.txt
   ```

3. **Community support:**
   - Check GitHub issues for each project
   - Reddit: r/radarr, r/sonarr, r/jellyfin
   - Discord servers for each project
```

---

## Success Criteria

Before marking this step complete, verify:

1. **VERIFICATION.md created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/VERIFICATION.md && echo "✓ VERIFICATION.md exists"
   ```

2. **TROUBLESHOOTING.md created:**
   ```bash
   test -f /Users/maxwell/Projects/mediamax/TROUBLESHOOTING.md && echo "✓ TROUBLESHOOTING.md exists"
   ```

3. **Both files have substantial content:**
   ```bash
   wc -l /Users/maxwell/Projects/mediamax/VERIFICATION.md
   wc -l /Users/maxwell/Projects/mediamax/TROUBLESHOOTING.md
   ```
   VERIFICATION.md should be 300+ lines, TROUBLESHOOTING.md should be 400+ lines

4. **VERIFICATION.md has all test phases:**
   ```bash
   grep -c "## Phase" /Users/maxwell/Projects/mediamax/VERIFICATION.md
   ```
   Should return 6 (phases 1-6)

5. **TROUBLESHOOTING.md covers all services:**
   ```bash
   grep -c "## .* Issues" /Users/maxwell/Projects/mediamax/TROUBLESHOOTING.md
   ```
   Should return 7+ (one section per service plus general)

---

## Archon Task Update

Mark task as in_progress at start:

```bash
curl -X PUT "http://localhost:8181/api/tasks/9c359274-71b3-4bcd-bfae-8bada7db5749" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

When finished and verified:

```bash
curl -X PUT "http://localhost:8181/api/tasks/9c359274-71b3-4bcd-bfae-8bada7db5749" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

---

## Notes

- This is step 5 of 6 in the sequential plan
- Depends on Step 4 (setup documentation)
- Next step will perform final validation
- These files are critical for user success
- Verification checklist should be comprehensive
- Troubleshooting should cover all common issues
