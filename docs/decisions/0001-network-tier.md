# Choose network tier

## Context and Problem Statement

We need to choose GCP network tier for GKE gateways.

## Considered Options

- Premium network tier. Stack:
  - global external Application Load Balancer,
  - global IP address,
  - supports Google-managed SSL certificates.

> Premium Tier delivers traffic from external systems to Google Cloud resources by using Google's low latency, highly reliable global network. This network consists of an extensive private fiber network with over 100 points of presence (PoPs) around the globe.

- Standard network tier. Stack:
  - regional external Application Load Balancer,
  - regional IP address,
  - requires additional tool for SSL certificates management (e.g. [cert-manager](https://cert-manager.io/)).

> Standard Tier delivers traffic from external systems to Google Cloud resources by routing it over the internet.

## Decision Outcome

Chosen standard network tier, because it's cheaper option. Global routing is not needed at this moment.

Use [this Terraform code](0001-network-tier/premium-network-tier.txt) to move back to premium network tier in the future (if needed).
