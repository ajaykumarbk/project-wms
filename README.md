# Waste Management System (WMS) — Production Deployment on AWS EKS

A production-grade, cloud-native Waste Management System deployed on Amazon EKS, exposed securely using AWS Load Balancer Controller (ALB), with TLS via ACM, DNS via Cloudflare, and monitoring using Prometheus and Grafana.

This project demonstrates how enterprise applications are deployed, secured, monitored, and operated in Kubernetes.

# Architecture Overview

Flow

User → Cloudflare DNS → AWS ALB → Kubernetes Ingress → Services → Pods → EBS Storage

Core Components
Layer	Technology
Container Orchestration	Amazon EKS
Load Balancer	AWS Application Load Balancer
TLS	AWS Certificate Manager
DNS	Cloudflare
Storage	AWS EBS CSI
Monitoring	Prometheus + Grafana
CI/CD	GitHub Actions
Container	Docker


# Features

JWT Authentication

Complaint lifecycle tracking

Image upload with persistent storage

Admin dashboard

Real-time updates using Socket.IO

Analytics dashboard

RBAC access

Production-grade monitoring

# Tech Stack

# Frontend

React (Vite)

Axios

Socket.IO Client

# Backend

Node.js

Express

Socket.IO

Multer

# Database

MySQL

# DevOps

Docker

Amazon EKS

AWS Load Balancer Controller

Cloudflare DNS

ACM

Helm

GitHub Actions

Prometheus

Grafana

# 1 Prerequisites

Install tools:

aws --version
kubectl version --client
helm version
eksctl version
docker version

# Configure AWS:

aws configure

aws sts get-caller-identity
# 2 Create EKS Cluster

cluster.yaml

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

# Create cluster:

eksctl create cluster -f cluster.yaml

Verify:

kubectl get nodes

# 3 Install AWS Load Balancer Controller

Create IAM Policy

curl -o iam_policy.json \
https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

aws iam create-policy \
 --policy-name AWSLoadBalancerControllerIAMPolicy \
 --policy-document file://iam_policy.json


# Create IRSA

eksctl create iamserviceaccount \
 --cluster prod-lab-cluster \
 --namespace kube-system \
 --name aws-load-balancer-controller \
 --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
 --approve


# Install Controller

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
 -n kube-system \
 --set clusterName=prod-lab-cluster \
 --set serviceAccount.create=false \
 --set serviceAccount.name=aws-load-balancer-controller

Verify:

kubectl get pods -n kube-system

# 4 Storage Configuration

storageclass.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass

metadata:
 name: gp3

provisioner: ebs.csi.aws.com

parameters:
 type: gp3

volumeBindingMode: WaitForFirstConsumer

Apply:

kubectl apply -f storageclass.yaml

Verify:

kubectl get storageclass


# 5 Deploy Application

Apply manifests:

kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-backend-pvc.yaml
kubectl apply -f 03-backend-secret.yaml
kubectl apply -f 04-backend-deployment.yaml
kubectl apply -f 05-backend-service.yaml
kubectl apply -f 06-frontend-deployment.yaml
kubectl apply -f 07-frontend-service.yaml
kubectl apply -f 08-ingress.yaml

Verify:

kubectl get pods -n wms
kubectl get svc -n wms
kubectl get ingress -n wms




# List certificate:

aws acm list-certificates --region us-east-1

Verify:

Status must be ISSUED

# 7 Configure Cloudflare DNS

Create CNAME records:

Name	Target
app	ALB DNS
grafana	ALB DNS
prometheus	ALB DNS

Important:

Proxy Mode must be DNS Only

Verify:

dig app.datanetwork.online
8 Verify HTTPS
curl -v https://app.datanetwork.online

Expected:

HTTP 200

SSL success

# 9 Install Monitoring

Create namespace:

kubectl create namespace monitoring

Install monitoring stack:

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm install monitoring prometheus-community/kube-prometheus-stack \
 --namespace monitoring

Get Grafana password:

kubectl get secret monitoring-grafana -n monitoring \
 -o jsonpath="{.data.admin-password}" | base64 -d

# Apply ingress:

kubectl apply -f monitoring-ingress.yaml

Access:

https://grafana.datanetwork.online

https://prometheus.datanetwork.online

# 10 Production Verification Checklist
Cluster

Nodes Ready

EBS CSI installed

OIDC Enabled

Application

Pods Running

Services Created

PVC Bound

Ingress Created

Load Balancer

ALB created

Listener 443 active

Certificate attached

DNS

Domain resolving

HTTPS working

Monitoring

Prometheus running

Grafana accessible

Metrics visible

