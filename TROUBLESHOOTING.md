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
