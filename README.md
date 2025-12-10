# Media Server Stack with Real-Debrid

A complete self-hosted media server stack for automated movie and TV show management using Real-Debrid.

## Overview

This stack provides a Netflix-like experience where you can request movies and TV shows, which are automatically downloaded via Real-Debrid and served through Jellyfin.

### What's Included

| Service | Purpose | Port |
|---------|---------|------|
| **RDTClient** | Real-Debrid download client (emulates qBittorrent) | 6500 |
| **Radarr** | Movie management and automation | 7878 |
| **Sonarr** | TV series management and automation | 8989 |
| **Prowlarr** | Indexer management (centralized) | 9696 |
| **Bazarr** | Subtitle management | 6767 |
| **Jellyfin** | Media server and player | 8096 |
| **Jellyseerr** | Request management (Netflix-like UI) | 5055 |
| **Flaresolverr** | Cloudflare bypass for indexers | 8191 |

### How It Works

1. **Request**: Use Jellyseerr to search and request movies/TV shows
2. **Search**: Radarr/Sonarr search configured indexers via Prowlarr
3. **Download**: Content is sent to RDTClient, which uses Real-Debrid
4. **Import**: Downloaded files are automatically imported to your library
5. **Subtitles**: Bazarr automatically downloads subtitles
6. **Watch**: Stream content through Jellyfin on any device

## Requirements

- **macOS** with Apple Silicon (M3 Ultra in this setup)
- **Docker Desktop** for Mac installed and running
- **Real-Debrid Premium Account** (required - get from https://real-debrid.com)
- **Minimum 50GB** free storage for media
- **Local network** access for all devices

## Quick Start

### 1. Initial Setup

```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your Real-Debrid API key
# Get it from: https://real-debrid.com/apitoken
nano .env  # or use your preferred editor
```

### 2. Start the Stack

```bash
# Make scripts executable
chmod +x start.sh stop.sh

# Start all services
./start.sh
```

The startup script will:
- Create all necessary directories
- Pull all Docker images
- Start all containers in the correct order
- Display service URLs when ready

### 3. Configure Services

After all services are running, follow the setup guide to configure each service:

```bash
# Open the setup guide
cat SETUP_GUIDE.md
```

You'll need to configure services in this order:
1. RDTClient (add Real-Debrid API key)
2. Prowlarr (add indexers)
3. Radarr (connect to RDTClient and Prowlarr)
4. Sonarr (connect to RDTClient and Prowlarr)
5. Bazarr (connect to Radarr/Sonarr)
6. Jellyfin (add media libraries)
7. Jellyseerr (connect to Jellyfin, Radarr, Sonarr)

### 4. Test the Setup

Once configured, request a movie through Jellyseerr and verify:
- It appears in Radarr
- Download starts in RDTClient
- File is imported to Jellyfin library
- You can play it in Jellyfin

See `VERIFICATION.md` for a complete checklist.

## Service Access

After starting the stack, access services at:

- **Jellyseerr** (Request UI): http://localhost:5055
- **Jellyfin** (Media Player): http://localhost:8096
- **Radarr** (Movies): http://localhost:7878
- **Sonarr** (TV): http://localhost:8989
- **Prowlarr** (Indexers): http://localhost:9696
- **Bazarr** (Subtitles): http://localhost:6767
- **RDTClient**: http://localhost:6500
- **Flaresolverr**: http://localhost:8191

## Directory Structure

```
mediamax/
├── docker-compose.yml          # Service definitions
├── .env                        # Configuration (copy from .env.example)
├── .env.example               # Configuration template
├── start.sh                   # Startup script
├── stop.sh                    # Shutdown script
├── README.md                  # This file
├── SETUP_GUIDE.md            # Detailed configuration instructions
├── VERIFICATION.md           # Setup validation checklist
├── TROUBLESHOOTING.md        # Common issues and solutions
├── config/                    # Service configurations (persisted)
│   ├── rdtclient/
│   ├── radarr/
│   ├── sonarr/
│   ├── prowlarr/
│   ├── bazarr/
│   ├── jellyfin/
│   └── jellyseerr/
└── media/                     # Media files
    ├── downloads/             # Temporary download location
    │   ├── movies/
    │   └── tv/
    ├── movies/                # Final movie library
    └── tv/                    # Final TV library
```

## Maintenance

### Starting and Stopping

```bash
# Start the stack
./start.sh

# Stop the stack
./stop.sh

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f radarr

# Restart a specific service
docker compose restart radarr
```

### Updating Services

```bash
# Stop the stack
./stop.sh

# Pull latest images
docker compose pull

# Start with updated images
./start.sh
```

### Backup

Important directories to backup:
- `config/` - All service configurations and databases
- `media/movies/` and `media/tv/` - Your media library (optional if using Real-Debrid)

```bash
# Backup configurations
tar -czf backup-config-$(date +%Y%m%d).tar.gz config/

# Backup everything
tar -czf backup-full-$(date +%Y%m%d).tar.gz config/ media/
```

## Documentation

- **SETUP_GUIDE.md** - Step-by-step configuration for each service
- **VERIFICATION.md** - Checklist to verify successful setup
- **TROUBLESHOOTING.md** - Common issues and solutions

## External Resources

- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Prowlarr Wiki](https://wiki.servarr.com/prowlarr)
- [RDTClient GitHub](https://github.com/rogerfar/rdt-client)
- [Jellyfin Documentation](https://jellyfin.org/docs/)
- [Jellyseerr Documentation](https://docs.jellyseerr.dev/)
- [Real-Debrid](https://real-debrid.com/)

## Support

If you encounter issues:
1. Check `TROUBLESHOOTING.md` for common problems
2. Review service logs: `docker compose logs <service_name>`
3. Verify all services are running: `docker compose ps`
4. Ensure Real-Debrid account is active and has premium status

## License

This configuration is provided as-is for personal use. Each service has its own license - please review individual project licenses.
