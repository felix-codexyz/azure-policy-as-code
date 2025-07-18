# Azure Policy as Code - Setup Guide (Terraform Cloud)

This comprehensive guide will walk you through the complete setup process for implementing Azure Policy as Code with Terraform Cloud and GitHub Actions. As someone new to Azure, this guide provides detailed, step-by-step instructions to ensure successful implementation.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Azure Environment Setup](#azure-environment-setup)
3. [Service Principal Creation](#service-principal-creation)
4. [Terraform Cloud Setup](#terraform-cloud-setup)
5. [GitHub Repository Setup](#github-repository-setup)
6. [GitHub Secrets Configuration](#github-secrets-configuration)
7. [Repository Structure Setup](#repository-structure-setup)
8. [Testing the Implementation](#testing-the-implementation)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

Before beginning this implementation, ensure you have the following tools and access:

### Required Tools
- **Azure CLI**: Download and install from [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Terraform CLI**: Download from [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)
- **Git**: Download from [https://git-scm.com/downloads](https://git-scm.com/downloads)
- **Text Editor**: Visual Studio Code or any preferred editor

### Required Access
- **Azure Subscription**: Active Azure subscription with Owner or Contributor permissions
- **GitHub Account**: Personal or organizational GitHub account
- **Terraform Cloud Account**: Free account at [https://app.terraform.io/](https://app.terraform.io/)
- **Command Line Access**: Terminal (Linux/macOS) or PowerShell/Command Prompt (Windows)

## Azure Environment Setup

### Step 1: Install and Configure Azure CLI

First, verify that Azure CLI is properly installed:

```bash
az --version
```

If not installed, follow the installation instructions for your operating system from the Azure CLI documentation.

### Step 2: Login to Azure

Login to your Azure account using the CLI:

```bash
az login
```

This command will open a web browser for authentication. Complete the login process and return to your terminal.

### Step 3: Set Your Default Subscription

List your available subscriptions:

```bash
az account list --output table
```

Set your default subscription (replace `<subscription-id>` with your actual subscription ID):

```bash
az account set --subscription "<subscription-id>"
```

Verify the correct subscription is selected:

```bash
az account show
```

## Service Principal Creation

A Service Principal is required for GitHub Actions to authenticate with Azure. This section provides detailed steps to create and configure the Service Principal with appropriate permissions.

### Step 1: Create the Service Principal

Create a Service Principal with Contributor role at the subscription level:

```bash
az ad sp create-for-rbac --name "sp-azure-policy-demo" --role contributor --scopes /subscriptions/<your-subscription-id> --sdk-auth
```

**Important**: Replace `<your-subscription-id>` with your actual Azure subscription ID.

The output will look similar to this:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

**Security Note**: Save this output securely as you'll need these values for GitHub Secrets configuration. The `clientSecret` cannot be retrieved again after creation.

### Step 2: Verify Service Principal Permissions

Verify that the Service Principal has the correct permissions:

```bash
az role assignment list --assignee <clientId> --output table
```

You should see a Contributor role assignment at the subscription scope.

## Terraform Cloud Setup

### Step 1: Create a Terraform Cloud Account

1. Navigate to [https://app.terraform.io/](https://app.terraform.io/)
2. Sign up for a free account or log in if you already have one
3. Complete the account verification process

### Step 2: Create an Organization

1. After logging in, click "Create Organization"
2. Enter a unique organization name (e.g., "your-company-azure-policy")
3. Enter your email address
4. Click "Create organization"

**Important**: Remember your organization name as you'll need it in the Terraform configuration files.

### Step 3: Create Workspaces

Create two workspaces for the project:

#### Workspace 1: Azure Policy Module
1. Click "New workspace"
2. Choose "CLI-driven workflow"
3. Enter workspace name: `azure-policy-module`
4. Click "Create workspace"

#### Workspace 2: Azure Storage Module
1. Click "New workspace"
2. Choose "CLI-driven workflow"
3. Enter workspace name: `azure-storage-module`
4. Click "Create workspace"

### Step 4: Configure Workspace Variables

For both workspaces, you need to configure Azure authentication variables:

1. Go to each workspace
2. Click on "Variables" tab
3. Add the following environment variables (mark as sensitive):

| Variable Name | Value | Sensitive |
|---------------|-------|-----------|
| `ARM_CLIENT_ID` | Your Service Principal Client ID | No |
| `ARM_CLIENT_SECRET` | Your Service Principal Client Secret | Yes |
| `ARM_SUBSCRIPTION_ID` | Your Azure Subscription ID | No |
| `ARM_TENANT_ID` | Your Azure Tenant ID | No |

### Step 5: Generate API Token

1. Click on your profile icon in the top right
2. Select "User Settings"
3. Click on "Tokens" in the left sidebar
4. Click "Create an API token"
5. Enter a description (e.g., "GitHub Actions Integration")
6. Click "Create API token"
7. **Important**: Copy and save the token securely - it won't be shown again

## GitHub Repository Setup

### Step 1: Create a New GitHub Repository

1. Navigate to [GitHub](https://github.com) and sign in to your account
2. Click the "+" icon in the top right corner and select "New repository"
3. Name your repository (e.g., `azure-policy-as-code`)
4. Set the repository to **Public** or **Private** based on your preference
5. Initialize with a README (optional, as we'll be adding our own)
6. Click "Create repository"

### Step 2: Clone the Repository Locally

Clone your newly created repository to your local machine:

```bash
git clone https://github.com/<your-username>/azure-policy-as-code.git
cd azure-policy-as-code
```

## GitHub Secrets Configuration

GitHub Secrets are used to securely store sensitive information like Azure credentials and Terraform Cloud API tokens. These secrets will be used by GitHub Actions workflows to authenticate with Azure and Terraform Cloud.

### Step 1: Navigate to Repository Settings

1. Go to your GitHub repository
2. Click on the "Settings" tab
3. In the left sidebar, click on "Secrets and variables"
4. Click on "Actions"

### Step 2: Add Required Secrets

Add the following secrets using the values from your Service Principal creation and Terraform Cloud setup:

| Secret Name | Value | Description |
|-------------|-------|-------------|
| `AZURE_CLIENT_ID` | `clientId` from Service Principal output | Application (client) ID |
| `AZURE_CLIENT_SECRET` | `clientSecret` from Service Principal output | Client secret value |
| `AZURE_SUBSCRIPTION_ID` | `subscriptionId` from Service Principal output | Azure subscription ID |
| `AZURE_TENANT_ID` | `tenantId` from Service Principal output | Directory (tenant) ID |
| `TF_API_TOKEN` | API token from Terraform Cloud | Terraform Cloud API token |

To add each secret:
1. Click "New repository secret"
2. Enter the secret name (exactly as shown in the table)
3. Enter the corresponding value
4. Click "Add secret"

### Step 3: Verify Secrets Configuration

After adding all secrets, you should see five secrets listed in your repository's Actions secrets section.

## Repository Structure Setup

### Step 1: Create Directory Structure

Create the required directory structure in your local repository:

```bash
mkdir -p .github/workflows
mkdir -p policy-module
mkdir -p terraform-storage-module
mkdir -p docs
```

### Step 2: Update Terraform Configuration Files

Before copying the project files, you need to update the Terraform Cloud organization name in the configuration files:

1. Open `policy-module/main.tf`
2. Replace `your-terraform-cloud-organization` with your actual Terraform Cloud organization name
3. Open `terraform-storage-module/providers.tf`
4. Replace `your-terraform-cloud-organization` with your actual Terraform Cloud organization name

### Step 3: Update GitHub Actions Workflows

Update the GitHub Actions workflow files to use your Terraform Cloud organization:

1. Open each file in `.github/workflows/`
2. Replace `your-terraform-cloud-organization` with your actual Terraform Cloud organization name

### Step 4: Add Project Files

Copy all the project files from this repository to your local repository, maintaining the same directory structure:

- Copy all files from `policy-module/` to your `policy-module/` directory
- Copy all files from `terraform-storage-module/` to your `terraform-storage-module/` directory
- Copy all files from `.github/workflows/` to your `.github/workflows/` directory
- Copy all files from `docs/` to your `docs/` directory
- Copy the main `README.md` file

### Step 5: Commit and Push Changes

Add, commit, and push all files to your GitHub repository:

```bash
git add .
git commit -m "Initial commit: Add Azure Policy as Code implementation with Terraform Cloud"
git push origin main
```

## Testing the Implementation

### Step 1: Verify Terraform Cloud Workspaces

1. Log in to Terraform Cloud
2. Navigate to your organization
3. Verify that both workspaces (`azure-policy-module` and `azure-storage-module`) are created
4. Check that environment variables are properly configured in both workspaces

### Step 2: Create a Feature Branch

Create a feature branch to test the workflow:

```bash
git checkout -b feature/test-policy-implementation
```

### Step 3: Make a Small Change

Make a minor change to trigger the workflows. For example, update a comment in `terraform-storage-module/main.tf`:

```bash
# Add a comment or modify an existing one
echo "# Test change for workflow trigger" >> terraform-storage-module/main.tf
```

### Step 4: Commit and Push the Feature Branch

```bash
git add .
git commit -m "Test: Trigger workflow with minor change"
git push origin feature/test-policy-implementation
```

### Step 5: Create a Pull Request

1. Go to your GitHub repository
2. You should see a prompt to create a Pull Request for your feature branch
3. Click "Compare & pull request"
4. Add a title and description
5. Click "Create pull request"

This will trigger the PR validation workflow.

### Step 6: Merge to Main Branch

After the PR validation completes:
1. Merge the Pull Request to the main branch
2. This will trigger both the Azure Policy deployment and the Terraform storage deployment workflows

### Step 7: Monitor Workflow Execution

1. Go to the "Actions" tab in your GitHub repository
2. Monitor the workflow executions
3. The Azure Policy workflow should complete successfully
4. The Terraform Storage workflow should **fail** when attempting to deploy to Australia East

### Step 8: Monitor Terraform Cloud Runs

1. Log in to Terraform Cloud
2. Navigate to your workspaces
3. Monitor the runs triggered by GitHub Actions
4. You can see detailed logs and plan outputs in the Terraform Cloud UI

## Expected Results

### Successful Azure Policy Deployment

The Azure Policy workflow should complete successfully and create:
- A custom policy definition restricting resources to East US
- A policy assignment at the subscription level

### Failed Terraform Storage Deployment

The Terraform Storage workflow should fail with an error similar to:

```
Error: creating Storage Account "stdemopolicytest001" (Resource Group "rg-storage-demo"): 
storage.AccountsClient#Create: Failure responding to request: StatusCode=403 -- 
Original Error: autorest/azure: Service returned an error. 
Status=403 Code="RequestDisallowedByPolicy" 
Message="Resource 'stdemopolicytest001' was disallowed by policy."
```

This failure confirms that the Azure Policy is working correctly and preventing resource creation outside the allowed region.

## Verification Steps

### Step 1: Verify Policy Creation in Azure Portal

1. Login to the [Azure Portal](https://portal.azure.com)
2. Navigate to "Policy" service
3. Click on "Definitions" in the left menu
4. Filter by "Custom" type
5. You should see your "Restrict Resource Creation to East US Region Only" policy

### Step 2: Verify Policy Assignment

1. In the Azure Portal Policy service
2. Click on "Assignments" in the left menu
3. You should see the policy assignment at your subscription scope

### Step 3: Verify Terraform Cloud State

1. Log in to Terraform Cloud
2. Navigate to your workspaces
3. Check the state files to see the created resources
4. Review run history and logs

### Step 4: Test Policy Manually (Optional)

You can manually test the policy by attempting to create a resource in a non-allowed region:

```bash
# This should fail due to the policy
az storage account create \
  --name teststoragepolicy001 \
  --resource-group test-rg \
  --location "Australia East" \
  --sku Standard_LRS
```

## Cleanup Instructions

When you're finished testing, you may want to clean up the resources:

### Step 1: Destroy Resources via Terraform Cloud

1. Log in to Terraform Cloud
2. Navigate to each workspace
3. Queue a destroy plan
4. Apply the destroy plan to remove resources

### Step 2: Remove Policy Assignment (Alternative)

```bash
az policy assignment delete --name "restrict-resources-to-east-us-assignment"
```

### Step 3: Remove Policy Definition (Alternative)

```bash
az policy definition delete --name "restrict-resources-to-east-us"
```

### Step 4: Remove Service Principal

```bash
az ad sp delete --id <clientId>
```

### Step 5: Clean Up Terraform Cloud

1. Delete the workspaces in Terraform Cloud
2. Revoke the API token if no longer needed

## Next Steps

After successful implementation, consider these enhancements:

1. **Multiple Environments**: Create separate workspaces for development, staging, and production environments
2. **Policy Exemptions**: Implement policy exemptions for specific resource groups or resources
3. **Advanced Policies**: Create additional policies for other compliance requirements
4. **Monitoring**: Set up Azure Monitor alerts for policy violations
5. **Reporting**: Implement automated compliance reporting
6. **Terraform Cloud Features**: Explore advanced Terraform Cloud features like Sentinel policies, cost estimation, and team management

## Security Best Practices

1. **Least Privilege**: Regularly review and minimize Service Principal permissions
2. **Secret Rotation**: Implement regular rotation of Service Principal secrets and API tokens
3. **Branch Protection**: Enable branch protection rules on your main branch
4. **Code Review**: Require code reviews for all policy and infrastructure changes
5. **Audit Logging**: Enable audit logging for all policy and resource changes
6. **Terraform Cloud Security**: Enable two-factor authentication and review team access regularly

## Terraform Cloud Benefits

Using Terraform Cloud provides several advantages over local Terraform execution:

1. **Remote State Management**: Automatic state file management with locking and encryption
2. **Collaboration**: Team-based workflows with role-based access control
3. **Audit Trail**: Complete history of all infrastructure changes
4. **Cost Estimation**: Automatic cost estimates for infrastructure changes
5. **Policy as Code**: Sentinel policies for additional governance (paid feature)
6. **Private Registry**: Host and share Terraform modules privately
7. **Notifications**: Integration with Slack, email, and webhooks for run notifications

---

This setup guide provides a comprehensive foundation for implementing Azure Policy as Code with Terraform Cloud. For additional support or troubleshooting, refer to the troubleshooting guide or consult the Azure, Terraform, and Terraform Cloud documentation.

*Authored by Manus AI*

