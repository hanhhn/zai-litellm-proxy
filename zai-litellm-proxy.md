# Z AI LiteLLM Proxy Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a Docker Compose setup with LiteLLM to proxy Claude CLI requests to Z AI API.

**Architecture:** Single LiteLLM Docker service running locally on port 4000, configured with environment variables and YAML config to forward requests to Z AI API using stored credentials.

**Tech Stack:** Docker, Docker Compose, LiteLLM, Z AI API

---

## Prerequisites

**Step 1: Verify Docker is installed**

Run: `docker --version`
Expected: Output showing Docker version (e.g., Docker version 24.x.x)

**Step 2: Verify Docker Compose is available**

Run: `docker-compose --version`
Expected: Output showing Docker Compose version (e.g., Docker Compose version v2.x.x)

---

### Task 1: Create Project Structure and .gitignore

**Files:**
- Create: `.gitignore`

**Step 1: Write .gitignore file**

```bash
# Environment variables with secrets
.env

# Docker volumes (if any)
docker/

# OS files
.DS_Store
Thumbs.db
```

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore for Z AI proxy setup"
```

---

### Task 2: Create Environment Variables File

**Files:**
- Create: `.env`

**Step 1: Create .env file with placeholder**

```bash
# Z AI API Key - replace <your-token> with actual API key
ZAI_API_KEY=<your-token>
```

**Step 2: Verify .env is ignored by git**

Run: `git status`
Expected: `.env` should NOT appear in untracked files

**Step 3: Commit**

```bash
git add .env
git commit -m "chore: add .env with ZAI_API_KEY placeholder"
```

---

### Task 3: Create LiteLLM Configuration

**Files:**
- Create: `config.yaml`

**Step 1: Write LiteLLM config file**

```yaml
model_list:
  - model_name: claude-3-5-sonnet
    litellm_params:
      model: zai/claude-3-5-sonnet
      api_key: os.environ/ZAI_API_KEY
  - model_name: claude-3-5-haiku
    litellm_params:
      model: zai/claude-3-5-haiku
      api_key: os.environ/ZAI_API_KEY
  - model_name: claude-3-opus
    litellm_params:
      model: zai/claude-3-opus
      api_key: os.environ/ZAI_API_KEY
```

**Step 2: Verify YAML syntax**

Run: `python -c "import yaml; yaml.safe_load(open('config.yaml'))"`
Expected: No error output (empty line or no output)

**Step 3: Commit**

```bash
git add config.yaml
git commit -m "feat: add LiteLLM config with Z AI model mappings"
```

---

### Task 4: Create Docker Compose File

**Files:**
- Create: `docker-compose.yml`

**Step 1: Write docker-compose.yml**

```yaml
version: '3.8'

services:
  litellm:
    image: ghcr.io/berriai/litellm:latest
    container_name: zai-litellm-proxy
    ports:
      - "4000:4000"
    volumes:
      - ./config.yaml:/app/config.yaml
    environment:
      - ZAI_API_KEY=${ZAI_API_KEY}
    command: ["--config", "/app/config.yaml", "--port", "4000", "--detailed_debug"]
    restart: unless-stopped
```

**Step 2: Verify Docker Compose syntax**

Run: `docker-compose config`
Expected: No errors, outputs the parsed configuration

**Step 3: Commit**

```bash
git add docker-compose.yml
git commit -m "feat: add Docker Compose configuration for LiteLLM"
```

---

### Task 5: Start and Verify LiteLLM Service

**Step 1: Pull the Docker image**

Run: `docker-compose pull`
Expected: Output showing image download progress for litellm:latest

**Step 2: Start the service**

Run: `docker-compose up -d`
Expected: Output indicating container creation and startup, container name "zai-litellm-proxy"

**Step 3: Wait 5 seconds for container to initialize**

Run: `sleep 5`

**Step 4: Check container status**

Run: `docker-compose ps`
Expected: Service "zai-litellm-proxy" shows status "Up"

**Step 5: View startup logs**

Run: `docker-compose logs litellm`
Expected: Logs showing successful config loading and server starting on port 4000

**Step 6: Test health endpoint**

Run: `curl -s http://localhost:4000/health`
Expected: Returns healthy status (JSON response with health check info)

**Step 7: Commit**

```bash
git add -A
git commit -m "test: verify LiteLLM service starts successfully"
```

---

### Task 6: Create README with Usage Instructions

**Files:**
- Create: `README.md`

**Step 1: Write README with setup and usage instructions**

```markdown
# Z AI LiteLLM Proxy for Claude CLI

Proxy Claude CLI requests to Z AI API using LiteLLM.

## Setup

1. Update `.env` with your Z AI API key:
   ```bash
   ZAI_API_KEY=your_actual_api_key_here
   ```

2. Start the service:
   ```bash
   docker-compose up -d
   ```

3. Configure Claude CLI to use:
   ```
   API Base URL: http://localhost:4000/v1
   Model: claude-3-5-sonnet (or any mapped model)
   ```

## Operations

- **View logs:** `docker-compose logs -f litellm`
- **Stop service:** `docker-compose down`
- **Restart service:** `docker-compose restart`
- **Update config:** Edit `config.yaml` or `.env`, then restart

## Model Mappings

- `claude-3-5-sonnet` → Z AI equivalent
- `claude-3-5-haiku` → Z AI equivalent
- `claude-3-opus` → Z AI equivalent

## Testing

Verify the proxy is working:
```bash
curl http://localhost:4000/health
```

Check logs for errors:
```bash
docker-compose logs litellm
```
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with setup and usage instructions"
```

---

### Task 7: Create Test Script for Validation

**Files:**
- Create: `test-proxy.sh`

**Step 1: Write test script**

```bash
#!/bin/bash

echo "Testing Z AI LiteLLM Proxy Setup..."

# Test 1: Check if Docker is running
echo -n "1. Checking Docker... "
if docker info > /dev/null 2>&1; then
  echo "✓ Running"
else
  echo "✗ Not running"
  exit 1
fi

# Test 2: Check if container is running
echo -n "2. Checking container status... "
if docker-compose ps | grep -q "Up"; then
  echo "✓ Running"
else
  echo "✗ Not running"
  echo "   Start with: docker-compose up -d"
  exit 1
fi

# Test 3: Check health endpoint
echo -n "3. Checking health endpoint... "
HEALTH=$(curl -s http://localhost:4000/health 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "✓ Healthy"
else
  echo "✗ Unhealthy"
  exit 1
fi

# Test 4: Check for API key
echo -n "4. Checking API key... "
if [ -f .env ] && grep -q "ZAI_API_KEY" .env; then
  if grep -q "<your-token>" .env; then
    echo "⚠ Placeholder detected - update with actual key"
  else
    echo "✓ Configured"
  fi
else
  echo "✗ Missing"
  exit 1
fi

echo -e "\n✓ All tests passed!"
```

**Step 2: Make script executable**

Run: `chmod +x test-proxy.sh`

**Step 3: Run test script**

Run: `./test-proxy.sh`
Expected: All tests pass with ✓ markers

**Step 4: Commit**

```bash
git add test-proxy.sh
git commit -m "test: add validation script for proxy setup"
```

---

### Task 8: Final Verification and Documentation

**Step 1: Run the test script to verify complete setup**

Run: `./test-proxy.sh`
Expected: All 4 tests pass

**Step 2: Check all files are committed**

Run: `git status`
Expected: "nothing to commit, working tree clean"

**Step 3: View git log**

Run: `git log --oneline`
Expected: 7 commits showing progression through tasks

**Step 4: Create final commit**

```bash
git commit --allow-empty -m "chore: complete Z AI LiteLLM proxy setup"
```

**Step 5: Tag the release (optional)**

```bash
git tag -a v1.0.0 -m "Initial release of Z AI LiteLLM proxy"
```

---

## Post-Setup Instructions

After completing the implementation:

1. **Update your API key:**
   Edit `.env` and replace `<your-token>` with your actual Z AI API key

2. **Restart the service:**
   ```bash
   docker-compose restart
   ```

3. **Configure Claude CLI:**
   Set API base URL to: `http://localhost:4000/v1`
   Model to use: `claude-3-5-sonnet`

4. **Verify working:**
   Run a simple prompt in Claude CLI and check logs:
   ```bash
   docker-compose logs -f litellm
   ```

## Troubleshooting

- **Container won't start:** Check `docker-compose logs litellm`
- **Port 4000 in use:** Edit `docker-compose.yml` to use a different port
- **API errors:** Verify ZAI_API_KEY is correct in `.env`
- **Connection refused:** Ensure container is running: `docker-compose ps`
