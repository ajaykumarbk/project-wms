Waste Management System (WMS) — Production Deployment on AWS EKS
A production-grade, cloud-native Waste Management System deployed on Amazon EKS, exposed securely using AWS Load Balancer Controller (ALB), with TLS via ACM, DNS via Cloudflare, and monitoring using Prometheus and Grafana.

Architecture Overview
text
User → Cloudflare DNS → AWS ALB → Kubernetes Ingress → Services → Pods → EBS Storage
Core Components
Layer	Technology
Container Orchestration	Amazon EKS
Load Balancer	AWS Application Load Balancer
TLS	AWS Certificate Manager
DNS	Cloudflare
Storage	AWS EBS CSI Driver
Monitoring	Prometheus + Grafana
CI/CD	GitHub Actions
Container	Docker
Features
JWT Authentication

Complaint lifecycle tracking

Image upload with persistent storage

Admin dashboard

Real-time updates using Socket.IO

Analytics dashboard

RBAC access control

Production-grade monitoring

Tech Stack
Frontend
React (Vite)

Axios

Socket.IO Client

Backend
Node.js

Express

Socket.IO

Multer

Database
MySQL

DevOps
Docker

Amazon EKS

AWS Load Balancer Controller

Cloudflare DNS

AWS Certificate Manager (ACM)

Helm

GitHub Actions

Prometheus

Grafana

Prerequisites
Verify installed tools:

bash
aws --version
kubectl version --client
helm version
eksctl version
docker version
Configure AWS CLI:

bash
aws configure
aws sts get-caller-identity
Deployment Guide
1. Create EKS Cluster
Create cluster.yaml:

yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: prod-lab-cluster
  region: us-east-1
  version: "1.31"

iam:
  withOIDC: true

managedNodeGroups:
  - name: standard-nodes
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 1
    maxSize: 4
    volumeSize: 20

addons:
  - name: vpc-cni
  - name: coredns
  - name: kube-proxy
  - name: aws-ebs-csi-driver
Create the cluster:

bash
eksctl create cluster -f cluster.yaml
Verify cluster is running:

bash
kubectl get nodes
2. Configure Storage
Create storageclass.yaml:

yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass

metadata:
  name: gp3

provisioner: ebs.csi.aws.com

parameters:
  type: gp3

volumeBindingMode: WaitForFirstConsumer
Apply storage configuration:

bash
kubectl apply -f storageclass.yaml
kubectl get storageclass
3. Install AWS Load Balancer Controller
Create IAM Policy
bash
curl -o iam_policy.json \
https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
Create IRSA (IAM Role for Service Account)
bash
eksctl create iamserviceaccount \
  --cluster prod-lab-cluster \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
Install Controller using Helm
bash
helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=prod-lab-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
Verify installation:

bash
kubectl get pods -n kube-system
4. Request SSL Certificate from ACM
Request certificate for your domain:

bash
aws acm request-certificate \
  --domain-name "*.datanetwork.online" \
  --validation-method DNS \
  --region us-east-1
List certificates to get ARN:

bash
aws acm list-certificates --region us-east-1
Note: Status must show "ISSUED" after DNS validation

5. Deploy Application
Apply all Kubernetes manifests in order:

bash
kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-backend-pvc.yaml
kubectl apply -f 03-backend-secret.yaml
kubectl apply -f 04-backend-deployment.yaml
kubectl apply -f 05-backend-service.yaml
kubectl apply -f 06-frontend-deployment.yaml
kubectl apply -f 07-frontend-service.yaml
kubectl apply -f 08-ingress.yaml
Verify deployment:

bash
kubectl get pods -n wms
kubectl get svc -n wms
kubectl get ingress -n wms
6. Configure Cloudflare DNS
Get the ALB DNS name from the ingress:

bash
kubectl get ingress -n wms
Create CNAME records in Cloudflare:

Name	Target	Proxy Status
app	ALB DNS name	DNS Only
grafana	ALB DNS name	DNS Only
prometheus	ALB DNS name	DNS Only
Important: Set Proxy Mode to "DNS Only" (grey cloud)

Verify DNS resolution:

bash
dig app.datanetwork.online
7. Verify HTTPS Configuration
Test the secure connection:

bash
curl -v https://app.datanetwork.online
Expected result:

HTTP 200 OK response

SSL/TLS handshake successful

Valid certificate from ACM

8. Install Monitoring Stack
Create monitoring namespace:

bash
kubectl create namespace monitoring
Install Prometheus and Grafana using Helm:

bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring
Retrieve Grafana admin password:

bash
kubectl get secret monitoring-grafana -n monitoring \
  -o jsonpath="{.data.admin-password}" | base64 -d
Apply monitoring ingress:

bash
kubectl apply -f monitoring-ingress.yaml
Access monitoring dashboards:

https://grafana.datanetwork.online

https://prometheus.datanetwork.online

Production Verification Checklist
Cluster Health
All nodes in Ready state

EBS CSI driver installed

OIDC provider enabled

CoreDNS running

Application Status
All pods running in wms namespace

Services created and endpoints ready

PVC bound to backend pod

Ingress resource created

Load Balancer
ALB provisioned successfully

HTTPS listener on port 443 active

SSL certificate properly attached

Target groups healthy

DNS & Networking
Domain resolves to ALB

HTTPS working with valid cert

WebSocket connections working

Monitoring
Prometheus targets discovered

Grafana accessible

Metrics being collected

Dashboards loading

Troubleshooting Tips
Common Issues and Solutions
ALB not provisioning

Check service account permissions

Verify subnets have proper tags

Check controller logs

PVC pending

Verify EBS CSI driver is installed

Check storage class exists

Ensure node has availability zones

Certificate not issued

Verify DNS validation records

Check domain ownership

Wait 5-10 minutes for propagation

Ingress not working

Check ALB controller logs

Verify ingress annotations

Confirm service endpoints exist

Maintenance
Backup Procedures
Regular etcd snapshots

Database backups

PVC snapshots via EBS

Updates
Cluster version upgrades using eksctl

Application updates via CI/CD

Monitoring stack updates via Helm

Scaling
Horizontal Pod Autoscaling (HPA)

Cluster Autoscaler for nodes

Manual scaling for special events

Security Considerations
Network policies implemented

Secrets encrypted in etcd

IAM roles for service accounts

Regular security group audits

TLS everywhere

RBAC enabled and configured

