# CatCar - Database & Secrets Infrastructure (`catcar-database-infra`)

Terraform Infrastructure as Code (IaC) repository provisioning managed PostgreSQL Flexible Server, Azure Key Vault, Private DNS zones, and connection string secrets for the CatCar platform.

---

## Provisioned Infrastructure

- **Relational Database**: Azure Database for PostgreSQL Flexible Server with automated backups, custom storage configuration, and strict SSL enforcement.
- **Database Networking**: Delegated Subnet (`snet-postgresql`), Private DNS Zone (`private.postgres.database.azure.com`), and VNet Link to ensure isolated private communication.
- **Key Vault & Secrets**: Azure Key Vault with Azure RBAC authorization, Private Endpoint (`pe-kv-*`), Private DNS Zone (`privatelink.vaultcore.azure.net`), and automated secret storage for:
  - `postgres-connection-string`: Primary connection string for CatCar API.
  - `postgres-auth-readonly-connection-string`: Read-only connection string for CatCar Auth Function.
- **Cross-Stack Decoupling**: Dynamically discovers the private endpoint subnet (`snet-private-endpoints`) provisioned by `catcar-kubernetes-infra` via Terraform data sources without output dependencies.

---

## Repository Structure

```
.
├── main.tf                    # PostgreSQL Flexible Server, Key Vault, and DNS resources
├── variables.tf               # Input parameters and defaults
├── outputs.tf                 # Server FQDN, database ID, and Key Vault URI
└── .github/workflows/ci-cd.yml # Automated lint, validation, and multi-environment apply
```

---

## Local Validation

```bash
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
```

---

## CI/CD Pipeline

- **Pull Requests**: Runs `terraform fmt` and `terraform validate`.
- **Push to `develop`**: Applies changes to **Homologation** environment with state key `homolog-catcar-database.tfstate`.
- **Push to `main`**: Applies changes to **Production** environment with state key `catcar-database.tfstate`.
