#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Starting Installation: Helm, Kubectl, cert-manager, and NGF ---"

# 1. Install Helm
echo "Installing Helm..."
sudo apt-get update
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm -y

# 2. Install Kubectl (v1.35)
echo "Installing Kubectl..."
sudo apt-get install -y ca-certificates gnupg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# 3. Install Gateway API CRDs
echo "Installing Gateway API CRDs..."
kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.4.1" | kubectl apply -f -

kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/experimental?ref=v2.4.1" | kubectl apply -f -

# 4. Install cert-manager
echo "Installing cert-manager via Helm..."
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" \
  --set config.kind="ControllerConfiguration" \
  --set config.enableGatewayAPI=true \
  --set crds.enabled=true

# Wait for cert-manager to be ready
echo "Waiting for cert-manager pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=120s

# 5. Create CA Issuers and Certificates
echo "Configuring NGINX Gateway Fabric PKI..."
kubectl create namespace nginx-gateway --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned-issuer
  namespace: nginx-gateway
spec:
  selfSigned: {}
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-gateway-ca
  namespace: nginx-gateway
spec:
  isCA: true
  commonName: nginx-gateway
  secretName: nginx-gateway-ca
  privateKey:
    algorithm: RSA
    size: 2048
  issuerRef:
    name: selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: nginx-gateway-issuer
  namespace: nginx-gateway
spec:
  ca:
    secretName: nginx-gateway-ca
EOF

# 6. Create Server and Client Certificates
echo "Creating TLS certificates for control plane and agent..."
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-gateway
  namespace: nginx-gateway
spec:
  secretName: server-tls
  usages:
  - digital signature
  - key encipherment
  dnsNames:
  - ngf-nginx-gateway-fabric.nginx-gateway.svc
  issuerRef:
    name: nginx-gateway-issuer
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx
  namespace: nginx-gateway
spec:
  secretName: agent-tls
  usages:
  - "digital signature"
  - "key encipherment"
  dnsNames:
  - "*.cluster.local"
  issuerRef:
    name: nginx-gateway-issuer
EOF

# 7. Deploy NGINX Gateway Fabric (NGF)
echo "Deploying NGINX Gateway Fabric from OCI registry..."
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
  --create-namespace \
  -n nginx-gateway \
  --set certGenerator.agentTLSSecretName=agent-tls

echo "--- Installation Complete ---"
echo "Verifying Secrets:"
kubectl -n nginx-gateway get secrets
echo "Verifying Pods:"
kubectl -n nginx-gateway get pods
