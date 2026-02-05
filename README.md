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
