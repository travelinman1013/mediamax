# Cloudflare Tunnel Setup for maxmerize.watch

**Goal:** Expose Jellyfin and Jellyseerr to friends without port forwarding

| Service | URL |
|---------|-----|
| Jellyfin | `https://watch.maxmerize.watch` |
| Jellyseerr | `https://request.maxmerize.watch` |

---

## Pre-configured (already done)

- [x] `.env` - Added `CLOUDFLARE_TUNNEL_TOKEN` placeholder
- [x] `docker-compose.yml` - Added `cloudflared` service

---

## Step 1: Create Cloudflare Account & Add Domain

1. Go to https://cloudflare.com
2. Click **Sign Up** (or log in if you have an account)
3. Click **Add a Site**
4. Enter: `maxmerize.watch`
5. Select the **Free** plan → Continue
6. Cloudflare will show you two nameservers like:
   ```
   ada.ns.cloudflare.com
   bob.ns.cloudflare.com
   ```
7. **Copy these nameservers** - you'll need them in Step 2

---

## Step 2: Update GoDaddy Nameservers

1. Go to https://godaddy.com → Sign in
2. Click **My Products** → Find `maxmerize.watch`
3. Click **DNS** or **Manage DNS**
4. Scroll to **Nameservers** section
5. Click **Change Nameservers**
6. Select **"I'll use my own nameservers"**
7. Enter the Cloudflare nameservers from Step 1
8. Click **Save**

**Wait 10-30 minutes** - Cloudflare will email you when the domain is active.

---

## Step 3: Create the Tunnel

1. Go to https://one.dash.cloudflare.com (Cloudflare Zero Trust)
2. If prompted, create a team name (e.g., `maxwell-media`)
3. Select the **Free** plan
4. In the left sidebar, click **Networks** → **Tunnels**
5. Click **Create a tunnel**
6. Select **Cloudflared** as the connector type
7. Name your tunnel: `mediaserver`
8. Click **Save tunnel**

### Copy the Token

1. On the installation page, click the **Docker** tab
2. You'll see a command like:
   ```
   docker run cloudflare/cloudflared:latest tunnel run --token eyJhIjoiNjk...
   ```
3. **Copy the entire token** starting with `eyJ...` (it's very long, ~200+ characters)

---

## Step 4: Add Token to .env

```bash
cd /Users/maxwell/Projects/mediamax
nano .env
```

Find this line at the bottom:
```
CLOUDFLARE_TUNNEL_TOKEN=your_tunnel_token_here
```

Replace `your_tunnel_token_here` with your actual token:
```
CLOUDFLARE_TUNNEL_TOKEN=eyJhIjoiNjk2ZTQ3YzZiMjE4...your_full_token
```

Save and exit (Ctrl+X, Y, Enter).

---

## Step 5: Start the Tunnel

```bash
cd /Users/maxwell/Projects/mediamax
docker compose up -d
docker compose logs -f cloudflared
```

Look for this output:
```
INF Starting tunnel tunnelID=xxxxx-xxxx-xxxx
INF Connection registered connIndex=0
INF Connection registered connIndex=1
```

Press `Ctrl+C` to exit logs once you see connections registered.

---

## Step 6: Configure Public Hostnames

Back in the Cloudflare Zero Trust dashboard:

1. Go to **Networks** → **Tunnels**
2. Click on your tunnel name (`mediaserver`)
3. Go to the **Public Hostnames** tab
4. Click **Add a public hostname**

### Add Jellyfin:
| Field | Value |
|-------|-------|
| Subdomain | `watch` |
| Domain | `maxmerize.watch` (select from dropdown) |
| Path | (leave empty) |
| Type | `HTTP` |
| URL | `jellyfin:8096` |

Click **Save hostname**

### Add Jellyseerr:
Click **Add a public hostname** again:

| Field | Value |
|-------|-------|
| Subdomain | `request` |
| Domain | `maxmerize.watch` |
| Path | (leave empty) |
| Type | `HTTP` |
| URL | `jellyseerr:5055` |

Click **Save hostname**

---

## Step 7: Test External Access

**Important:** Test from your phone on **cellular data** (not WiFi) to verify it works externally.

1. Visit `https://watch.maxmerize.watch`
   - Should show Jellyfin login page
   - Should have HTTPS padlock (no certificate warnings)

2. Visit `https://request.maxmerize.watch`
   - Should show Jellyseerr

3. Log into Jellyfin and test playing a video

---

## Troubleshooting

### Tunnel not connecting
```bash
docker compose logs cloudflared | tail -20
```

### "Bad Gateway" or 502 errors
The tunnel works but can't reach Jellyfin:
```bash
# Check Jellyfin is healthy
docker compose ps jellyfin

# Restart cloudflared
docker compose restart cloudflared
```

### DNS not resolving
- Wait longer (up to 48 hours for some registrars)
- Verify Cloudflare dashboard shows domain as "Active"
- Check: `dig watch.maxmerize.watch`

### Token issues
```bash
# Verify token is set (should show eyJ...)
docker compose config | grep TUNNEL_TOKEN
```

---

## Important Reminders

### Mac Must Stay Awake
Your Mac needs to stay on for friends to stream:
- **System Settings** → **Energy** → Turn off "Automatically sleep when display is off"
- Or run `caffeinate -d` in terminal while hosting

### Bandwidth (2-3 concurrent streams)
| Quality | Upload Needed |
|---------|---------------|
| 720p | 9-15 Mbps |
| 1080p | 24-36 Mbps |
| 4K | 60-120 Mbps |

If your upload is limited, configure Jellyfin to transcode remote streams.

### Never Expose These Services
Keep internal-only (already configured correctly):
- Radarr, Sonarr, Prowlarr (admin access)
- RDTClient (contains Real-Debrid API key)
- Bazarr, Flaresolverr (internal tools)

---

## Quick Commands Reference

```bash
# Start everything
cd /Users/maxwell/Projects/mediamax
docker compose up -d

# Check tunnel status
docker compose logs -f cloudflared

# Restart tunnel
docker compose restart cloudflared

# Stop everything
docker compose down
```
