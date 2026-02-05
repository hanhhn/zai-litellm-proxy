# Z AI LiteLLM Proxy for Claude Code CLI

Forward Claude Code CLI requests to Z AI's GLM-4.7 model via LiteLLM proxy.

## How It Works

```
Claude Code CLI --> LiteLLM Proxy (localhost:4000) --> Z AI API (GLM-4.7)
```

The proxy maps Claude model names to Z AI's GLM-4.7:
- claude-sonnet-4-20250514 -> glm-4.7
- claude-opus-4-20250514 -> glm-4.7
- claude-3-5-sonnet-20241022 -> glm-4.7

## Setup

1. Ensure `.env` has your Z AI API key:
   ```
   ZAI_API_KEY=your_api_key_here
   ```

2. Start the proxy:
   ```bash
   docker compose up -d
   ```

3. Configure Claude Code CLI:
   ```bash
   export ANTHROPIC_BASE_URL=http://localhost:4000/v1
   ```

   Or add to ~/.claude/settings.json:
   ```json
   {
     "apiBaseUrl": "http://localhost:4000/v1"
   }
   ```

## Operations

- **View logs:** docker compose logs -f litellm
- **Stop:** docker compose down
- **Restart:** docker compose restart

## Testing

```bash
# Check health
curl http://localhost:4000/health/liveliness

# List models
curl http://localhost:4000/v1/models

# Test completion
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "claude-sonnet-4-20250514", "messages": [{"role": "user", "content": "Hello"}]}'
```

## Notes

- The proxy runs on port 4000 by default
- Docker Compose will pull the LiteLLM image on first run
- The service is configured to restart unless stopped manually
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
curl http://localhost:4000/models
```

Check logs for errors:
```bash
docker-compose logs litellm
```

## Notes

- The proxy runs on port 4000 by default
- Docker Compose automatically pulls the LiteLLM image on first run
- The service is configured to restart unless stopped manually
