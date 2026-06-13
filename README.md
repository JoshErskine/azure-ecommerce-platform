# Azure E-Commerce Platform

This project demonstrates cloud-native architecture on Microsoft Azure - including event-driven systems, secrets management, observability, and fully automated infrastructure provisioning via Terraform and GitHub Actions. This was built alongside my studies for the AZ-204 exam and covers real architectural patterns used in enterprise systems.

## Architecture
<img width="561" height="558" alt="Azure E-Commerce Architecture Diagram" src="https://github.com/user-attachments/assets/b1a77ec8-d606-49af-9d24-b5f1e255371a" />

The system is divided into six layers. Each layer has a single responsibility and communicates with adjacent layers through well-defined interfaces.
 
| Layer | Services | Responsibility |
|---|---|---|
| API Gateway | API Management | Rate limiting, auth policies, public surface |
| Compute | App Service (.NET 10) | REST API — products and orders |
| Data | Cosmos DB, Azure SQL | Product catalogue (NoSQL), order records (relational) |
| Event Pipeline | Service Bus, Azure Functions, Blob Storage | Async order processing, invoice generation |
| Security | Key Vault, Managed Identity | Secrets management — no credentials in code |
| Observability | Application Insights | Telemetry, custom events, dead-letter alerting |
 
### Request Flows
 
**Synchronous (product/order reads and writes)**
1. Client sends HTTPS request to the APIM gateway
2. APIM validates and proxies to App Service
3. App Service reads products from Cosmos DB or writes orders to Azure SQL
4. Response returned to client

**Asynchronous (order processing pipeline)**
1. Order saved to Azure SQL — event published to Service Bus
2. Service Bus triggers the `ProcessOrder` Azure Function
3. Function generates an invoice and writes it to Blob Storage
4. On failure after 3 attempts, message moves to the dead-letter queue
---


## Tech Stack
- Language: C# / .NET 8
- Cloud: Microsoft Azure
- IaC: Terraform
