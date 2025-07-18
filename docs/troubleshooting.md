# Troubleshooting Guide - Azure Policy as Code (Terraform Cloud)

This guide provides solutions to common issues you may encounter while implementing Azure Policy as Code with Terraform Cloud and GitHub Actions.

## Table of Contents

1. [Authentication Issues](#authentication-issues)
2. [Terraform Cloud Issues](#terraform-cloud-issues)
3. [GitHub Actions Issues](#github-actions-issues)
4. [Azure Policy Issues](#azure-policy-issues)
5. [Permission Issues](#permission-issues)
6. [Common Error Messages](#common-error-messages)

## Authentication Issues

### Issue: "Error: building AzureRM Client: obtain subscription() from Azure CLI"

**Symptoms:**
- Terraform commands fail with authentication errors in Terraform Cloud
- Azure CLI commands work locally but fail in Terraform Cloud runs

**Solution:**
1. Verify that all required environment variables are configured in Terraform Cloud workspaces:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

2. Check that the Service Principal still exists and has valid credentials:
   ```bash
   az ad sp show --id <client-id>
   ```

3. Verify the Service Principal has the correct role assignments:
   ```bash
   az role assignment list --assignee <client-id> --output table
   ```

### Issue: "Error: Invalid API token"

**Symptoms:**
- GitHub Actions fails with Terraform Cloud authentication errors
- Error message mentions invalid or expired API token

**Solution:**
1. Verify the `TF_API_TOKEN` secret is correctly configured in GitHub
2. Check if the API token has expired in Terraform Cloud:
   - Go to User Settings > Tokens in Terraform Cloud
   - Verify the token is still active
3. Generate a new API token if needed and update the GitHub secret

### Issue: "Error: Insufficient privileges to complete the operation"

**Symptoms:**
- Authentication succeeds but operations fail with privilege errors

**Solution:**
1. Ensure the Service Principal has Contributor role at the subscription level
2. For policy operations, the Service Principal may need additional permissions:
   ```bash
   az role assignment create \
     --assignee <client-id> \
     --role "Resource Policy Contributor" \
     --scope /subscriptions/<subscription-id>
   ```

## Terraform Cloud Issues

### Issue: "Error: Workspace not found"

**Symptoms:**
- Terraform init fails with workspace not found error
- GitHub Actions cannot connect to Terraform Cloud workspace

**Solution:**
1. Verify the workspace name in the Terraform configuration matches the actual workspace name in Terraform Cloud
2. Check the organization name in the `cloud` block:
   ```hcl
   cloud {
     organization = "your-actual-organization-name"
     workspaces {
       name = "azure-policy-module"
     }
   }
   ```
3. Ensure the API token has access to the specified workspace

### Issue: "Error: Run is already planning/applying"

**Symptoms:**
- Multiple GitHub Actions runs trigger simultaneously
- Terraform Cloud shows concurrent runs error

**Solution:**
1. Wait for the current run to complete before triggering another
2. Configure run triggers in Terraform Cloud to prevent concurrent executions
3. Use GitHub Actions concurrency controls:
   ```yaml
   concurrency:
     group: terraform-${{ github.ref }}
     cancel-in-progress: true
   ```

### Issue: "Error: Variables not set"

**Symptoms:**
- Terraform plan fails due to missing variables
- Required variables are not available in Terraform Cloud

**Solution:**
1. Check that all required variables are set in the Terraform Cloud workspace
2. Verify variable names match exactly (case-sensitive)
3. For Azure authentication, ensure environment variables are set:
   - `ARM_CLIENT_ID`
   - `ARM_CLIENT_SECRET`
   - `ARM_SUBSCRIPTION_ID`
   - `ARM_TENANT_ID`

### Issue: "Error: State lock timeout"

**Symptoms:**
- Terraform operations timeout waiting for state lock
- Multiple operations attempting to modify state simultaneously

**Solution:**
1. Wait for current operations to complete
2. In Terraform Cloud, go to the workspace and check for any stuck runs
3. Force unlock the state if necessary (use with caution):
   - Go to workspace Settings > Destruction and Deletion
   - Use "Force unlock" if available

## GitHub Actions Issues

### Issue: Workflow not triggering

**Symptoms:**
- Push or pull request doesn't trigger the expected workflow

**Solution:**
1. Check the workflow trigger configuration in `.github/workflows/*.yml`
2. Verify the file paths in the `paths` filter match your changes
3. Ensure the branch names match your repository's default branch
4. Check the Actions tab for any workflow run errors

### Issue: "Error: The process '/usr/bin/git' failed with exit code 128"

**Symptoms:**
- GitHub Actions fails during checkout step

**Solution:**
1. Update the checkout action to the latest version:
   ```yaml
   - name: Checkout code
     uses: actions/checkout@v4
   ```

2. Ensure the repository is accessible and the token has appropriate permissions

### Issue: "Error: Failed to setup Terraform"

**Symptoms:**
- GitHub Actions fails when setting up Terraform CLI

**Solution:**
1. Verify the Terraform setup action configuration:
   ```yaml
   - name: Set up Terraform
     uses: hashicorp/setup-terraform@v3
     with:
       terraform_version: 1.x
       cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}
   ```

2. Check that the `TF_API_TOKEN` secret is properly configured

### Issue: "Error: terraform init failed"

**Symptoms:**
- Terraform initialization fails in GitHub Actions

**Solution:**
1. Verify the backend configuration in your Terraform files
2. Check that the Terraform Cloud organization and workspace names are correct
3. Ensure the API token has access to the specified workspace
4. Verify network connectivity between GitHub Actions and Terraform Cloud

## Azure Policy Issues

### Issue: Policy not enforcing as expected

**Symptoms:**
- Resources can still be created in restricted regions
- Policy violations are not being blocked

**Solution:**
1. Check the policy effect is set to "Deny":
   ```hcl
   variable "policy_effect" {
     default = "Deny"
   }
   ```

2. Verify the policy assignment scope covers the target resources
3. Check for policy exemptions that might override the restriction
4. Allow time for policy propagation (can take up to 30 minutes)
5. Check the policy assignment in Terraform Cloud state

### Issue: "Error: Policy assignment already exists"

**Symptoms:**
- Terraform fails when trying to create a policy assignment that already exists

**Solution:**
1. Import the existing policy assignment into Terraform Cloud:
   ```bash
   terraform import azurerm_subscription_policy_assignment.restrict_region /subscriptions/<subscription-id>/providers/Microsoft.Authorization/policyAssignments/<assignment-name>
   ```

2. Or delete the existing assignment and let Terraform recreate it:
   ```bash
   az policy assignment delete --name <assignment-name>
   ```

### Issue: "Error: Policy definition not found"

**Symptoms:**
- Terraform fails to find the policy definition during plan or apply

**Solution:**
1. Ensure the policy module is deployed before the storage module
2. Check that the policy definition JSON file exists and is valid
3. Verify the file path in the Terraform configuration:
   ```hcl
   policy_rule = file("${path.module}/policy_definition.json")
   ```
4. Check the Terraform Cloud workspace for the policy module

## Permission Issues

### Issue: "Error: Authorization failed for user"

**Symptoms:**
- Operations fail with authorization errors despite having Contributor role

**Solution:**
1. Verify the Service Principal has the required roles:
   ```bash
   az role assignment list --assignee <client-id> --all --output table
   ```

2. Add specific roles for policy operations:
   ```bash
   # For policy definitions
   az role assignment create \
     --assignee <client-id> \
     --role "Resource Policy Contributor" \
     --scope /subscriptions/<subscription-id>
   
   # For policy assignments
   az role assignment create \
     --assignee <client-id> \
     --role "Policy Insights Data Writer (Preview)" \
     --scope /subscriptions/<subscription-id>
   ```

### Issue: Cannot create resources in East US

**Symptoms:**
- Even allowed regions are being blocked by the policy

**Solution:**
1. Check the policy definition for correct region names:
   ```json
   "defaultValue": [
     "eastus"
   ]
   ```

2. Verify the region name format matches Azure's naming convention:
   - Use lowercase
   - No spaces (use "eastus" not "East US")

3. Test with Azure CLI to confirm region name:
   ```bash
   az account list-locations --query "[?displayName=='East US'].name" -o tsv
   ```

## Common Error Messages

### "RequestDisallowedByPolicy"

**Error Message:**
```
Resource 'resourcename' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"restrict-resources-to-east-us-assignment","id":"/subscriptions/.../policyAssignments/restrict-resources-to-east-us-assignment"},"policyDefinition":{"name":"restrict-resources-to-east-us","id":"/subscriptions/.../policyDefinitions/restrict-resources-to-east-us"}}]'
```

**Meaning:** This is the expected behavior! The policy is working correctly and blocking resource creation in non-allowed regions.

**Action:** No action needed if this occurs during the storage module deployment to Australia East.

### "InvalidTemplateDeployment"

**Error Message:**
```
The template deployment failed because of policy violation. Please see details for more information.
```

**Meaning:** A policy is preventing the deployment.

**Action:** 
1. Check which policy is being violated
2. Verify if this is expected behavior
3. Adjust the resource configuration or policy as needed

### "WorkspaceNotFound"

**Error Message:**
```
Workspace "workspace-name" not found in organization "organization-name"
```

**Meaning:** The specified Terraform Cloud workspace doesn't exist or isn't accessible.

**Action:**
1. Verify the workspace name and organization name in your Terraform configuration
2. Check that the workspace exists in Terraform Cloud
3. Ensure the API token has access to the workspace

### "RunAlreadyInProgress"

**Error Message:**
```
A run is already in progress for this workspace
```

**Meaning:** Another Terraform operation is currently running in the workspace.

**Action:**
1. Wait for the current run to complete
2. Check the Terraform Cloud UI for run status
3. Cancel the current run if it's stuck (use with caution)

## Debugging Steps

### Step 1: Enable Detailed Logging

Add debug logging to your GitHub Actions workflows:

```yaml
env:
  TF_LOG: DEBUG
  ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
```

### Step 2: Check Terraform Cloud Logs

1. Log in to Terraform Cloud
2. Navigate to the affected workspace
3. Click on the failed run
4. Review the detailed logs and plan output

### Step 3: Test Locally with Terraform Cloud

Test the configuration locally while using Terraform Cloud backend:

```bash
# Set environment variables
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"

# Login to Terraform Cloud
terraform login

# Test Terraform commands
cd policy-module
terraform init
terraform plan
```

### Step 4: Check Azure Activity Log

1. Go to Azure Portal
2. Navigate to "Activity log"
3. Filter by time range and resource type
4. Look for failed operations and their error details

### Step 5: Validate Policy Syntax

Use Azure CLI to validate policy definitions:

```bash
az policy definition create \
  --name "test-policy" \
  --rules @policy_definition.json \
  --mode All \
  --display-name "Test Policy" \
  --description "Test policy validation" \
  --dry-run
```

### Step 6: Check Terraform Cloud Workspace Settings

1. Verify environment variables are set correctly
2. Check workspace permissions and team access
3. Review workspace settings and execution mode
4. Ensure the workspace is not locked

## Getting Help

If you continue to experience issues:

1. **Check Service Status**: 
   - [Azure Status](https://status.azure.com/) for Azure service outages
   - [Terraform Cloud Status](https://status.hashicorp.com/) for Terraform Cloud issues
2. **Review Documentation**: 
   - [Azure Policy Documentation](https://docs.microsoft.com/en-us/azure/governance/policy/)
   - [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
   - [Terraform Cloud Documentation](https://www.terraform.io/cloud-docs)
   - [GitHub Actions Documentation](https://docs.github.com/en/actions)
3. **Community Support**:
   - [Azure Community Support](https://docs.microsoft.com/en-us/answers/products/azure)
   - [Terraform Community](https://discuss.hashicorp.com/c/terraform-core)
   - [GitHub Community](https://github.community/)

## Preventive Measures

To avoid common issues:

1. **Regular Testing**: Test your workflows regularly in a development environment
2. **Version Pinning**: Pin specific versions of actions and providers
3. **Monitoring**: Set up monitoring and alerting for policy violations and failed runs
4. **Documentation**: Keep your documentation updated with any customizations
5. **Backup**: Terraform Cloud automatically manages state backups, but ensure you have access to your workspaces
6. **Team Training**: Ensure team members understand Terraform Cloud workflows and best practices

## Terraform Cloud Specific Tips

1. **Workspace Organization**: Use consistent naming conventions for workspaces
2. **Variable Management**: Use workspace-specific variables for environment differences
3. **Run Triggers**: Configure run triggers carefully to avoid unnecessary executions
4. **Team Access**: Regularly review and update team access permissions
5. **Cost Monitoring**: Use Terraform Cloud's cost estimation features to monitor infrastructure costs
6. **Notifications**: Set up notifications for run failures and policy violations

---

This troubleshooting guide covers the most common issues encountered during implementation with Terraform Cloud. For specific error messages not covered here, consult the official documentation or community forums.

*Authored by Manus AI*

