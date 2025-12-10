# Step 6: Final Validation and Testing

**Archon Task ID:** `c1a68773-5fd1-4ca5-a77e-fac0acf7a45f`
**Project:** media-server-stack
**Working Directory:** `/Users/maxwell/Projects/mediamax`
**Depends On:** Step 5 (Verification and Troubleshooting Documentation)

---

## Context

This is the final step in the sequential plan. All files have been created in steps 1-5. Your task is to validate that everything is correct, properly formatted, and ready for use.

This step performs quality assurance checks to ensure the media server stack setup is complete and error-free.

---

## Your Task

Perform comprehensive validation of all created files and configurations.

### 1. Validate Directory Structure

Verify the complete directory structure exists:

```bash
cd /Users/maxwell/Projects/mediamax

# Check all directories exist
test -d config && echo "✓ config/ exists"
test -d config/rdtclient && echo "✓ config/rdtclient/ exists"
test -d config/radarr && echo "✓ config/radarr/ exists"
test -d config/sonarr && echo "✓ config/sonarr/ exists"
test -d config/prowlarr && echo "✓ config/prowlarr/ exists"
test -d config/bazarr && echo "✓ config/bazarr/ exists"
test -d config/jellyfin && echo "✓ config/jellyfin/ exists"
test -d config/jellyseerr && echo "✓ config/jellyseerr/ exists"

test -d media && echo "✓ media/ exists"
test -d media/downloads && echo "✓ media/downloads/ exists"
test -d media/downloads/movies && echo "✓ media/downloads/movies/ exists"
test -d media/downloads/tv && echo "✓ media/downloads/tv/ exists"
test -d media/movies && echo "✓ media/movies/ exists"
test -d media/tv && echo "✓ media/tv/ exists"

test -d prompts && echo "✓ prompts/ exists"
```

**Expected:** All directories exist with ✓ marks

### 2. Validate Core Files Exist

Check that all essential files were created:

```bash
cd /Users/maxwell/Projects/mediamax

# Core configuration files
test -f docker-compose.yml && echo "✓ docker-compose.yml exists"
test -f .env.example && echo "✓ .env.example exists"

# Scripts
test -f start.sh && echo "✓ start.sh exists"
test -f stop.sh && echo "✓ stop.sh exists"

# Documentation
test -f README.md && echo "✓ README.md exists"
test -f SETUP_GUIDE.md && echo "✓ SETUP_GUIDE.md exists"
test -f VERIFICATION.md && echo "✓ VERIFICATION.md exists"
test -f TROUBLESHOOTING.md && echo "✓ TROUBLESHOOTING.md exists"
```

**Expected:** All files exist with ✓ marks

### 3. Validate Docker Compose

Test docker-compose.yml for syntax errors and completeness:

```bash
cd /Users/maxwell/Projects/mediamax

# Test YAML syntax
echo "Testing docker-compose.yml syntax..."
docker compose config > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ docker-compose.yml has valid YAML syntax"
else
    echo "✗ docker-compose.yml has YAML syntax errors"
    docker compose config
fi

# List services
echo ""
echo "Services defined:"
docker compose config --services

# Verify service count
SERVICE_COUNT=$(docker compose config --services | wc -l | tr -d ' ')
if [ "$SERVICE_COUNT" -eq 8 ]; then
    echo "✓ All 8 services defined"
else
    echo "✗ Expected 8 services, found $SERVICE_COUNT"
fi

# Check for network
echo ""
echo "Networks defined:"
docker compose config --networks
NETWORK_COUNT=$(docker compose config --networks | wc -l | tr -d ' ')
if [ "$NETWORK_COUNT" -ge 1 ]; then
    echo "✓ Network defined"
else
    echo "✗ No network defined"
fi

# Validate no syntax errors in stderr
echo ""
echo "Checking for configuration errors..."
ERROR_OUTPUT=$(docker compose config 2>&1 >/dev/null)
if [ -z "$ERROR_OUTPUT" ]; then
    echo "✓ No configuration errors"
else
    echo "✗ Configuration errors found:"
    echo "$ERROR_OUTPUT"
fi
```

**Expected:**
- Valid YAML syntax
- 8 services (rdtclient, prowlarr, radarr, sonarr, bazarr, jellyfin, jellyseerr, flaresolverr)
- At least 1 network (media-network)
- No errors

### 4. Validate Scripts

Check that scripts are executable and have correct syntax:

```bash
cd /Users/maxwell/Projects/mediamax

# Check executable permissions
echo "Checking script permissions..."
if [ -x start.sh ]; then
    echo "✓ start.sh is executable"
else
    echo "✗ start.sh is not executable"
    echo "  Fix with: chmod +x start.sh"
fi

if [ -x stop.sh ]; then
    echo "✓ stop.sh is executable"
else
    echo "✗ stop.sh is not executable"
    echo "  Fix with: chmod +x stop.sh"
fi

# Check bash syntax
echo ""
echo "Checking bash syntax..."
bash -n start.sh 2>&1
if [ $? -eq 0 ]; then
    echo "✓ start.sh has valid bash syntax"
else
    echo "✗ start.sh has bash syntax errors"
fi

bash -n stop.sh 2>&1
if [ $? -eq 0 ]; then
    echo "✓ stop.sh has valid bash syntax"
else
    echo "✗ stop.sh has bash syntax errors"
fi

# Check shebangs
echo ""
echo "Checking shebangs..."
START_SHEBANG=$(head -n 1 start.sh)
STOP_SHEBANG=$(head -n 1 stop.sh)

if [ "$START_SHEBANG" = "#!/bin/bash" ]; then
    echo "✓ start.sh has correct shebang"
else
    echo "✗ start.sh has incorrect shebang: $START_SHEBANG"
fi

if [ "$STOP_SHEBANG" = "#!/bin/bash" ]; then
    echo "✓ stop.sh has correct shebang"
else
    echo "✗ stop.sh has incorrect shebang: $STOP_SHEBANG"
fi
```

**Expected:**
- Both scripts executable
- Valid bash syntax
- Correct shebangs (#!/bin/bash)

### 5. Validate Environment File Template

Check .env.example completeness:

```bash
cd /Users/maxwell/Projects/mediamax

echo "Validating .env.example..."

# Check for required variables
REQUIRED_VARS=("PUID" "PGID" "TZ" "RD_API_KEY" "RADARR_URL" "SONARR_URL" "PROWLARR_URL" "JELLYFIN_URL")

for VAR in "${REQUIRED_VARS[@]}"; do
    if grep -q "^$VAR=" .env.example 2>/dev/null || grep -q "^# $VAR=" .env.example 2>/dev/null; then
        echo "✓ $VAR defined"
    else
        echo "✗ $VAR missing"
    fi
done

# Check for port variables
PORT_VARS=("RDTCLIENT_PORT" "RADARR_PORT" "SONARR_PORT" "PROWLARR_PORT" "BAZARR_PORT" "JELLYFIN_PORT" "JELLYSEERR_PORT" "FLARESOLVERR_PORT")

echo ""
echo "Checking port variables..."
for VAR in "${PORT_VARS[@]}"; do
    if grep -q "^$VAR=" .env.example 2>/dev/null; then
        echo "✓ $VAR defined"
    else
        echo "✗ $VAR missing"
    fi
done
```

**Expected:** All required and port variables present in .env.example

### 6. Validate Documentation Content

Check documentation files for completeness:

```bash
cd /Users/maxwell/Projects/mediamax

echo "Validating documentation files..."

# README.md
README_LINES=$(wc -l < README.md | tr -d ' ')
if [ "$README_LINES" -gt 150 ]; then
    echo "✓ README.md has substantial content ($README_LINES lines)"
else
    echo "⚠ README.md may be too short ($README_LINES lines)"
fi

# Check README has key sections
if grep -q "## Overview" README.md && \
   grep -q "## Requirements" README.md && \
   grep -q "## Quick Start" README.md; then
    echo "✓ README.md has required sections"
else
    echo "✗ README.md missing required sections"
fi

# SETUP_GUIDE.md
SETUP_LINES=$(wc -l < SETUP_GUIDE.md | tr -d ' ')
if [ "$SETUP_LINES" -gt 400 ]; then
    echo "✓ SETUP_GUIDE.md has substantial content ($SETUP_LINES lines)"
else
    echo "⚠ SETUP_GUIDE.md may be too short ($SETUP_LINES lines)"
fi

# Check for all 7 service sections
SERVICE_SECTIONS=$(grep -c "^## [1-7]\." SETUP_GUIDE.md)
if [ "$SERVICE_SECTIONS" -eq 7 ]; then
    echo "✓ SETUP_GUIDE.md has all 7 service sections"
else
    echo "✗ SETUP_GUIDE.md has $SERVICE_SECTIONS service sections (expected 7)"
fi

# VERIFICATION.md
VERIFY_LINES=$(wc -l < VERIFICATION.md | tr -d ' ')
if [ "$VERIFY_LINES" -gt 200 ]; then
    echo "✓ VERIFICATION.md has substantial content ($VERIFY_LINES lines)"
else
    echo "⚠ VERIFICATION.md may be too short ($VERIFY_LINES lines)"
fi

# Check for test phases
PHASE_COUNT=$(grep -c "^## Phase" VERIFICATION.md)
if [ "$PHASE_COUNT" -ge 4 ]; then
    echo "✓ VERIFICATION.md has test phases ($PHASE_COUNT phases)"
else
    echo "✗ VERIFICATION.md missing test phases (found $PHASE_COUNT)"
fi

# TROUBLESHOOTING.md
TROUBLE_LINES=$(wc -l < TROUBLESHOOTING.md | tr -d ' ')
if [ "$TROUBLE_LINES" -gt 300 ]; then
    echo "✓ TROUBLESHOOTING.md has substantial content ($TROUBLE_LINES lines)"
else
    echo "⚠ TROUBLESHOOTING.md may be too short ($TROUBLE_LINES lines)"
fi
```

**Expected:**
- README.md: 150+ lines, has Overview, Requirements, Quick Start sections
- SETUP_GUIDE.md: 400+ lines, has all 7 service configuration sections
- VERIFICATION.md: 200+ lines, has multiple test phases
- TROUBLESHOOTING.md: 300+ lines

### 7. Create Final Summary Report

Generate a completion report:

```bash
cd /Users/maxwell/Projects/mediamax

cat > VALIDATION_REPORT.txt << 'EOF'
Media Server Stack - Validation Report
=======================================

Generated: $(date)

File Structure:
--------------
$(ls -lh docker-compose.yml .env.example start.sh stop.sh README.md SETUP_GUIDE.md VERIFICATION.md TROUBLESHOOTING.md 2>/dev/null | awk '{print $9, "-", $5}')

Directory Structure:
-------------------
$(find config media -type d | sort)

Docker Compose Validation:
--------------------------
Services: $(docker compose config --services 2>/dev/null | wc -l | tr -d ' ') defined
Networks: $(docker compose config --networks 2>/dev/null | wc -l | tr -d ' ') defined
YAML Valid: $(docker compose config > /dev/null 2>&1 && echo "YES" || echo "NO")

Documentation Metrics:
---------------------
README.md: $(wc -l < README.md | tr -d ' ') lines
SETUP_GUIDE.md: $(wc -l < SETUP_GUIDE.md | tr -d ' ') lines
VERIFICATION.md: $(wc -l < VERIFICATION.md | tr -d ' ') lines
TROUBLESHOOTING.md: $(wc -l < TROUBLESHOOTING.md | tr -d ' ') lines

Script Validation:
-----------------
start.sh executable: $(test -x start.sh && echo "YES" || echo "NO")
stop.sh executable: $(test -x stop.sh && echo "YES" || echo "NO")

Setup Status:
------------
✓ Directory structure created
✓ Docker Compose configuration ready
✓ Automation scripts ready
✓ Documentation complete

Next Steps:
----------
1. Copy .env.example to .env and configure Real-Debrid API key
2. Run ./start.sh to start all services
3. Follow SETUP_GUIDE.md to configure each service
4. Use VERIFICATION.md to test the setup
5. Refer to TROUBLESHOOTING.md if issues arise

Ready for deployment!
EOF

echo ""
echo "Validation report created: VALIDATION_REPORT.txt"
echo ""
cat VALIDATION_REPORT.txt
```

### 8. Display Final Project Status

Show the complete project tree:

```bash
cd /Users/maxwell/Projects/mediamax

echo ""
echo "========================================="
echo "Final Project Structure"
echo "========================================="
echo ""

tree -L 3 -a || find . -type f -o -type d | grep -v "^\./$" | sort

echo ""
echo "========================================="
echo "File Summary"
echo "========================================="
echo ""
echo "Configuration:"
echo "  - docker-compose.yml ($(wc -l < docker-compose.yml | tr -d ' ') lines)"
echo "  - .env.example ($(wc -l < .env.example | tr -d ' ') lines)"
echo ""
echo "Scripts:"
echo "  - start.sh ($(wc -l < start.sh | tr -d ' ') lines)"
echo "  - stop.sh ($(wc -l < stop.sh | tr -d ' ') lines)"
echo ""
echo "Documentation:"
echo "  - README.md ($(wc -l < README.md | tr -d ' ') lines)"
echo "  - SETUP_GUIDE.md ($(wc -l < SETUP_GUIDE.md | tr -d ' ') lines)"
echo "  - VERIFICATION.md ($(wc -l < VERIFICATION.md | tr -d ' ') lines)"
echo "  - TROUBLESHOOTING.md ($(wc -l < TROUBLESHOOTING.md | tr -d ' ') lines)"
echo "  - VALIDATION_REPORT.txt"
echo ""
```

---

## Success Criteria

All validations must pass:

1. ✅ All directories exist (16 directories total)
2. ✅ All core files exist (8 files: docker-compose.yml, .env.example, 2 scripts, 4 docs)
3. ✅ docker-compose.yml has valid YAML syntax
4. ✅ All 8 services defined in docker-compose.yml
5. ✅ Network defined in docker-compose.yml
6. ✅ Both scripts are executable
7. ✅ Both scripts have valid bash syntax
8. ✅ .env.example contains all required variables
9. ✅ README.md has substantial content and key sections
10. ✅ SETUP_GUIDE.md has all 7 service sections
11. ✅ VERIFICATION.md has test phases
12. ✅ TROUBLESHOOTING.md has substantial content
13. ✅ VALIDATION_REPORT.txt generated

---

## Archon Task Update

Mark task as in_progress at start:

```bash
curl -X PUT "http://localhost:8181/api/tasks/c1a68773-5fd1-4ca5-a77e-fac0acf7a45f" \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

When finished and ALL validations pass:

```bash
curl -X PUT "http://localhost:8181/api/tasks/c1a68773-5fd1-4ca5-a77e-fac0acf7a45f" \
  -H "Content-Type: application/json" \
  -d '{"status": "done"}'
```

---

## Final Report to User

After all validations pass, provide this summary:

```
========================================
Media Server Stack Setup - COMPLETE
========================================

All 6 steps completed successfully:
✓ Step 1: Project Structure and Base Configuration
✓ Step 2: Docker Compose Setup
✓ Step 3: Automation Scripts
✓ Step 4: Setup Documentation
✓ Step 5: Verification and Troubleshooting Documentation
✓ Step 6: Final Validation and Testing

Files Created:
-------------
- docker-compose.yml (complete service stack)
- .env.example (environment template)
- start.sh (startup automation)
- stop.sh (shutdown automation)
- README.md (project overview)
- SETUP_GUIDE.md (detailed configuration guide)
- VERIFICATION.md (testing checklist)
- TROUBLESHOOTING.md (problem solutions)
- VALIDATION_REPORT.txt (this validation)

Directory Structure:
-------------------
- config/ (7 service config directories)
- media/ (downloads and library directories)
- prompts/ (sequential execution prompts)

Validation Results:
------------------
All checks passed ✓

Next Steps:
----------
1. Copy .env.example to .env:
   cp .env.example .env

2. Add your Real-Debrid API key to .env:
   nano .env
   (Get key from: https://real-debrid.com/apitoken)

3. Start the stack:
   ./start.sh

4. Follow SETUP_GUIDE.md to configure each service

5. Use VERIFICATION.md to test your setup

The media server stack is ready for deployment!
```

---

## Notes

- This is the final step (6 of 6) in the sequential plan
- Depends on all previous steps (1-5)
- This step performs quality assurance only
- No new files are created except VALIDATION_REPORT.txt
- All validations must pass before marking complete
- If any validation fails, fix the issue and re-run
- The project is complete when this step passes
