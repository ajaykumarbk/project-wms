
# Waste Management System (WMS)

A production-grade, cloud-native Waste Management System designed to demonstrate real-world full-stack development and DevOps practices.
The application is deployed on a Google Kubernetes Engine (GKE) Standard cluster and exposed securely using NGINX Gateway API Fabric backed by a Google Cloud external Load Balancer, with DNS managed via Cloudflare.

This project focuses not just on features, but on how real production systems are built, deployed, monitored, and operated.

# Features

JWT-based user authentication

Report waste issues with image uploads

Complaint lifecycle tracking
Pending → In Progress → Resolved

Admin dashboard for complaint management

Real-time updates using Socket.IO

Analytics dashboard

Pagination and role-based access control (RBAC)

# Architecture Overview

Frontend and backend are fully containerized

Deployed on GKE Standard (production-style cluster)

NGINX Gateway API Fabric handles ingress using Kubernetes Gateway API

Google Cloud provisions an external Load Balancer

Application domain is mapped via Cloudflare A record

Persistent storage for uploaded images using PVCs

CI/CD pipeline automates build, scan, and deployment

# Tech Stack

Frontend

React (Vite)

Axios

Socket.IO Client

Backend

Node.js + Express

# Database

MySQL

Multer (image uploads)

Socket.IO

# DevOps & Platform

Docker

Google Kubernetes Engine (GKE – Standard)

NGINX Gateway API Fabric

Google Cloud External Load Balancer

Cloudflare DNS

GitHub Actions (CI/CD)

SonarQube

# Networking & Routing

# NGINX Gateway API Fabric

Acts as the cluster ingress layer

Uses the Kubernetes Gateway API

Integrates natively with Google Cloud Load Balancer

Clean separation between frontend and backend traffic

HTTP Routing Rules
/api        → Backend Service
/uploads   → Backend Service
/           → Frontend Service

# External Access

Google Cloud assigns a public Load Balancer IP

Cloudflare A record points the domain to the LB IP

# HTTPS handled via:

Cert-Manager 

Install Cert-Manager

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml


# CI/CD Pipeline

Implemented using GitHub Actions:

Triggered on every branch push

SonarQube scan with quality gate enforcement

Docker image build for frontend and backend

Images pushed to Docker Hub (:latest)

Kubernetes rollout via:

Deployment restart, or

Image tag update

This setup mirrors real production CI/CD workflows.

# Health, Reliability & Resilience

/health endpoint for backend service

Kubernetes readiness & liveness probes

Graceful shutdown handling

Resilient Socket.IO connections

Persistent storage ensures uploads survive pod restarts

# Monitoring & Observability

Monitoring is implemented using Prometheus and Grafana.

Installation

kubectl create namespace monitoring

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set kubeDns.enabled=false \
  --set coreDns.enabled=false \
  --set kubeControllerManager.enabled=false \
  --set kubeScheduler.enabled=false \
  --set kubeEtcd.enabled=false \
  --set kubeProxy.enabled=false

# Verification
kubectl get pods -n monitoring

# What’s Monitored

Node and cluster health

Pod CPU & memory usage

Application-level metrics

Custom Grafana dashboards