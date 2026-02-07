<!-- # Waste Management System (WMS)

A production-grade, cloud-native Waste Management System built with a modern full-stack architecture and deployed on a self-managed Kubernetes cluster, exposed securely using Envoy Gateway + Cloudflare Tunnel.

This project demonstrates real-world DevOps practices, including containerization, CI/CD, Kubernetes networking, persistent storage, secure ingress, and live troubleshooting.

# Application

User authentication (JWT based)

Report waste issues with image upload

Track complaint status (Pending → In Progress → Resolved)

Admin dashboard for complaint management

Real-time updates using Socket.IO

Analytics dashboard

Pagination and role-based access control

# Platform & DevOps

Dockerized frontend and backend

Self-managed Kubernetes cluster (EC2 + kubeadm)

Envoy Gateway (Gateway API) for traffic routing

Cloudflare Tunnel for secure internet exposure (no public load balancer)

Persistent storage for uploaded images using PVC

# CI/CD pipeline with GitHub Actions

SonarQube integration for code quality

Health checks, readiness & liveness probes


# Tech Stack

# Frontend

React (Vite)

Axios

Socket.IO Client

# Backend

Node.js + Express

Multer (image uploads)

Socket.IO

MySQL

# DevOps / Platform

Docker

Kubernetes (kubeadm)

Envoy Gateway (Gateway API)

Cloudflare Tunnel

GitHub Actions (CI/CD)

SonarQube

Persistent Volumes & Claims

# Networking & Routing

Envoy Gateway (Gateway API)

Handles HTTP routing inside the cluster

Clean separation of frontend and backend traffic

HTTPRoute Rules
/api      → backend service
/uploads  → backend service
/         → frontend service

Cloudflare Tunnel

Secure ingress without public LoadBalancer

Automatic HTTPS

No exposed node ports

# CI/CD Pipeline

Implemented using GitHub Actions:

Triggered on branch push

SonarQube scan & quality gate

Docker image build (frontend + backend)

Push images to Docker Hub (:latest)

Kubernetes rollout via deployment restart

# Health & Reliability

/health endpoint for backend

Readiness & liveness probes

Socket.IO resilience

Persistent storage for uploads

Graceful shutdown handling


# Monitoring with grafana and prometheus

# Add the prometheus-community helm repository

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Create the namespace
kubectl create namespace monitoring

# Install the stack
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123  # Set your own password here

# Verfy 

kubectl get pods -n monitoring -->



♻️ Waste Management System (WMS)

A production-grade, cloud-native Waste Management System designed to demonstrate real-world full-stack development and DevOps practices.
The application is deployed on a Google Kubernetes Engine (GKE) Standard cluster and exposed securely using NGINX Gateway API Fabric backed by a Google Cloud external Load Balancer, with DNS managed via Cloudflare.

This project focuses not just on features, but on how real production systems are built, deployed, monitored, and operated.

🚀 Features

JWT-based user authentication

Report waste issues with image uploads

Complaint lifecycle tracking
Pending → In Progress → Resolved

Admin dashboard for complaint management

Real-time updates using Socket.IO

Analytics dashboard

Pagination and role-based access control (RBAC)

🏗️ Architecture Overview

Frontend and backend are fully containerized

Deployed on GKE Standard (production-style cluster)

NGINX Gateway API Fabric handles ingress using Kubernetes Gateway API

Google Cloud provisions an external Load Balancer

Application domain is mapped via Cloudflare A record

Persistent storage for uploaded images using PVCs

CI/CD pipeline automates build, scan, and deployment

🧰 Tech Stack
Frontend

React (Vite)

Axios

Socket.IO Client

Backend

Node.js + Express

MySQL

Multer (image uploads)

Socket.IO

DevOps & Platform

Docker

Google Kubernetes Engine (GKE – Standard)

NGINX Gateway API Fabric

Google Cloud External Load Balancer

Cloudflare DNS

GitHub Actions (CI/CD)

SonarQube

Persistent Volumes & Claims (PVC)

🌐 Networking & Routing
NGINX Gateway API Fabric

Acts as the cluster ingress layer

Uses the Kubernetes Gateway API

Integrates natively with Google Cloud Load Balancer

Clean separation between frontend and backend traffic

HTTP Routing Rules
/api        → Backend Service
/uploads   → Backend Service
/           → Frontend Service

External Access

Google Cloud assigns a public Load Balancer IP

Cloudflare A record points the domain to the LB IP

HTTPS handled via:

Google-managed certificates or

Cert-Manager (optional)

No NodePorts exposed

No tunneling solutions used

🔄 CI/CD Pipeline

Implemented using GitHub Actions:

Triggered on every branch push

SonarQube scan with quality gate enforcement

Docker image build for frontend and backend

Images pushed to Docker Hub (:latest)

Kubernetes rollout via:

Deployment restart, or

Image tag update

This setup mirrors real production CI/CD workflows.

🩺 Health, Reliability & Resilience

/health endpoint for backend service

Kubernetes readiness & liveness probes

Graceful shutdown handling

Resilient Socket.IO connections

Persistent storage ensures uploads survive pod restarts

📊 Monitoring & Observability

Monitoring is implemented using Prometheus and Grafana.

Installation
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring

helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123

Verification
kubectl get pods -n monitoring

What’s Monitored

Node and cluster health

Pod CPU & memory usage

Application-level metrics

Custom Grafana dashboards