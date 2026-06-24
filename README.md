# Azure E-Commerce Platform
<img width="500" height="300" alt="Image" src="https://github.com/user-attachments/assets/31511987-3776-4869-993e-90deac4154d8" />

<img width="500" height="300" alt="Image" src="https://github.com/user-attachments/assets/5594d4ff-ea92-4243-8f25-057e44213fe1" />

<img width="500" height="300" alt="Image" src="https://github.com/user-attachments/assets/167b022b-dcd5-4359-b554-d5892f4af998" />

<img width="500" height="300" alt="Image" src="https://github.com/user-attachments/assets/d46bbaa9-7620-4576-8b1a-d0ace1949181" />

## Overview

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

## Key Design Decisions

**Why Cosmos DB for products but Azure SQL for orders?**
Products have variable schemas - different categories have different attributes. Cosmos DB's schemaless model handles this cleanly and its partition key (`/category`) makes category-scoped queries fast. Orders are relational by nature - a fixed schema with foreign key relationships - so Azure SQL and Entity Framework Core was the choice.
 
**Why Service Bus instead of calling the Function directly?**
Decoupling. The API doesn't need to know how order processing works - it publishes an event and moves on. If the Function has a bug, orders aren't lost - they queue up. The dead-letter queue captures failures after 3 retry attempts so nothing disappears silently.
 
---
 
## Project Structure
 
```
azure-ecommerce-platform/
├── src/
│   ├── api/                    # .NET 10 REST API (App Service)
│   │   └── EcommerceApi/
│   │       ├── Controllers/    # Products and Orders endpoints
│   │       ├── Models/         # Product, Order domain models
│   │       └── Data/           # EF Core DbContext
│   └── functions/              # Azure Functions
│       └── OrderProcessor/     # ProcessOrder + DeadLetterMonitor
├── infra/
│   └── terraform/              # Full IaC — all Azure resources
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── modules/            # Cosmos, SQL, Key Vault, APIM etc.
└── 
```
 
---


## Tech Stack

| | Technology |
|---|---|
| **Language** | C# / .NET 10 |
| **API** | ASP.NET Core, Entity Framework Core |
| **Cloud** | Microsoft Azure |
| **Databases** | Azure Cosmos DB (NoSQL), Azure SQL (relational) |
| **Messaging** | Azure Service Bus |
| **Compute** | Azure App Service, Azure Functions |
| **Storage** | Azure Blob Storage |
| **Security** | Azure Key Vault, Managed Identity |
| **Observability** | Application Insights |
| **Gateway** | Azure API Management |
| **IaC** | Terraform (HCL) |


## Estimated Running Cost
 
| Service | SKU | ~£/month |
|---|---|---|
| App Service | B1 Linux | £10 |
| Azure SQL | Basic | £4 |
| Cosmos DB | 400 RU/s | £20 |
| Service Bus | Standard | £7 |
| Azure Functions | Consumption | £0 |
| Blob Storage | Standard LRS | £1 |
| Application Insights | Pay-per-use | £0–3 |
| API Management | Consumption | £0 |
| **Total** | | **~£42–45** |
 
When not actively developing, the resource group is destroyed and reprovisioned from Terraform — cost drops to zero between sessions.
 
---
