# GitHub Actions Deployment Setup

## Required Secrets

Create these secrets in your repository settings (**Settings > Secrets and variables > Actions > Secrets**):

| Secret | Description | How to get it |
|--------|-------------|---------------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | Run: `az ad sp create-for-rbac --name "github-actions-sp" --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group} --json-auth` |
| `ACR_USERNAME` | Azure Container Registry admin username | Azure Portal > ACR > Access keys (enable Admin user) |
| `ACR_PASSWORD` | Azure Container Registry admin password | Azure Portal > ACR > Access keys |

## Required Variables

Create these variables in your repository settings (**Settings > Secrets and variables > Actions > Variables**):

| Variable | Description | Example |
|----------|-------------|---------|
| `AZURE_WEBAPP_NAME` | Name of the App Service | `app-zavastorevegangal-dev` |
| `ACR_LOGIN_SERVER` | ACR login server URL | `acrzavastorevegangaldev.azurecr.io` |

## Quick Setup Commands

```bash
# Get ACR credentials (enable admin first in portal or via CLI)
az acr update -n <acr-name> --admin-enabled true
az acr credential show -n <acr-name>

# Create service principal
az ad sp create-for-rbac --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/<resource-group> \
  --json-auth
```

Copy the entire JSON output from the service principal command as `AZURE_CREDENTIALS`.
