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

# Test 3: Check models endpoint
echo -n "3. Checking models endpoint... "
MODELS=$(curl -s http://localhost:4000/models 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "✓ Responding"
else
  echo "✗ Not responding"
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
