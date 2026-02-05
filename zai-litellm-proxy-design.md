# LiteLLM Proxy for Z AI Integration

## Overview
Set up LiteLLM as a forward proxy to enable Claude CLI to use Z AI's API services. Claude CLI connects to a local LiteLLM instance running in Docker, which forwards requests to Z AI.

## Architecture
Docker Compose runs a single LiteLLM service on port 4000. Claude CLI is configured to use `http://localhost:4000` as its API endpoint. LiteLLM authenticates to Z AI using an API key stored in environment variables and handles request/response translation between Claude and Z AI.

```
Claude CLI → LiteLLM Proxy (localhost:4000) → Z AI API
```

## Components

### Docker Compose
Minimal setup with a single LiteLLM service:
- Official `ghcr.io/berriai/litellm` image
- Port mapping: 4000:4000
- Volume mount: `./config.yaml:/app/config.yaml`
- Environment variable: `ZAI_API_KEY`
- Command: Run with config file on port 4000 with debug enabled
- Auto-restart policy: unless-stopped

### LiteLLM Configuration
`config.yaml` defines model mappings:
```yaml
model_list:
  - model_name: claude-3-5-sonnet
    litellm_params:
      model: zai/claude-3-5-sonnet
      api_key: os.environ/ZAI_API_KEY
```

### Environment Storage
`.env` file contains:
```
ZAI_API_KEY=<your-token>
```
Added to `.gitignore` to prevent committing secrets.

## Operations

**Start service:**
```bash
docker-compose up -d
```

**Stop service:**
```bash
docker-compose down
```

**View logs:**
```bash
docker-compose logs -f litellm
```

**Update configuration:**
Edit `config.yaml` or `.env`, then restart:
```bash
docker-compose restart
```

## Data Flow

1. User runs Claude CLI configured with `http://localhost:4000/v1`
2. Claude sends request with model name (e.g., claude-3-5-sonnet)
3. LiteLLM receives request, reads config.yaml for model mapping
4. LiteLLM authenticates to Z AI using ZAI_API_KEY
5. LiteLLM forwards formatted request to Z AI API
6. Z AI returns response to LiteLLM
7. LiteLLM standardizes response and returns to Claude
8. Claude displays output to user

## Error Handling

- **Invalid API key**: Returns 401 from Z AI, logged by LiteLLM
- **Network errors**: Propagated to Claude with clear error messages
- **Configuration errors**: LiteLLM fails fast on startup with detailed logs
- **Debug mode enabled**: Detailed logging for troubleshooting

## Testing

### Service Verification
- Start container and check health endpoint: `curl http://localhost:4000/health`
- Verify logs show no startup errors

### API Key Validation
- Test with invalid key to confirm 401 error handling
- Verify LiteLLM logs authentication failures

### End-to-End Test
- Configure Claude CLI to use `http://localhost:4000/v1`
- Run simple prompt: "echo hello"
- Verify response comes from Z AI (check logs)
- Confirm model mapping works correctly

### Configuration Testing
- Test with invalid config.yaml (should fail fast)
- Test with multiple model mappings
- Verify port availability

## Files Structure
```
.
├── docker-compose.yml
├── config.yaml
├── .env
└── .gitignore
```
