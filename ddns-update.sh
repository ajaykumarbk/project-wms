#!/bin/bash

# Cloudflare API Token
CF_API_TOKEN="ZkUQyiqKjOaDsD5yLObULWddvbSvdydta4IQ-C-p"
CF_ZONE_ID="3e70d69870ecf0a8a5400bf8180ad3f4"
DOMAIN="datanetwork.online"
SUBDOMAINS=("app" "api")

# Get MetalLB LoadBalancer IP
LB_IP=$(kubectl get svc -n nginx-gateway nginx-gateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$LB_IP" ]; then
  echo "❌ MetalLB IP not found!"
  exit 1
fi

# Update DNS records
for subdomain in "${SUBDOMAINS[@]}"; do
  RECORD_NAME="$subdomain.$DOMAIN"
  RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records?name=$RECORD_NAME" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

  if [ "$RECORD_ID" == "null" ]; then
    echo "❌ DNS record not found for $RECORD_NAME"
    continue
  fi

  RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$CF_ZONE_ID/dns_records/$RECORD_ID" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data "{\"type\":\"A\",\"name\":\"$RECORD_NAME\",\"content\":\"$LB_IP\",\"ttl\":120,\"proxied\":false}")

  if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "✅ Updated $RECORD_NAME → $LB_IP"
  else
    echo "❌ Failed to update $RECORD_NAME"
    echo "$RESPONSE"
  fi
done
