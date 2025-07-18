# Azure Policy as Code with Terraform and GitHub Actions

This project demonstrates the implementation of Azure Policy as Code to enforce region restrictions and showcases policy-driven failure during a Terraform deployment, all managed through source control and CI/CD using GitHub Actions and **Terraform Cloud**.

## Project Objective

The primary goal of this project is to establish a robust and automated mechanism for enforcing Azure governance policies, specifically region restrictions, and to validate its effectiveness through a controlled failure scenario during infrastructure deployment. This setup ensures that only resources in approved regions can be provisioned, thereby enhancing compliance and security.

## Project Components

This repository is structured into three main components:

1.  **Azure Policy Definition & Deployment**: A custom Azure Policy that restricts resource creation to the \'East US\' region only. The policy definition and its assignment are managed as code and deployed via a dedicated CI/CD pipeline.
2.  **Terraform Module for Azure Storage**: A reusable Terraform module designed to deploy an Azure Storage Account. This module is intentionally configured to deploy resources in the \'Australia East\' region to demonstrate the policy\'s enforcement.
3.  **GitHub Actions CI/CD Workflows**: Automated pipelines that handle the deployment of both the Azure Policy and the Terraform-managed infrastructure. These workflows ensure that changes are validated, policies are applied, and infrastructure deployments adhere to defined governance rules.

## Expected Outcome

Upon successful setup and execution of the CI/CD pipelines, the Terraform Apply job for the Azure Storage Account module is expected to **fail**. This failure will occur because the Azure Policy, restricting resource creation to \'East US\', will prevent the deployment of the storage account in \'Australia East\'. This outcome serves as a clear demonstration that the policy is effectively enforcing compliance and that the end-to-end CI/CD setup is functional.

## Repository Structure

```
azure-policy-as-code/
├── .github/
│   └── workflows/             # GitHub Actions workflow definitions
│       ├── azure-policy-ci.yml
│       ├── terraform-storage-ci.yml
│       └── pr-validation.yml
├── policy-module/             # Azure Policy definition and assignment Terraform code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── policy_definition.json
├── terraform-storage-module/  # Terraform module for Azure Storage Account
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── example.tf
└── docs/                      # Additional documentation and guides
    └── setup-guide.md
    └── troubleshooting.md
```

## Getting Started

Follow the detailed setup guide in `docs/setup-guide.md` to configure your Azure environment, GitHub repository, and deploy the project components.

## Prerequisites

Before you begin, ensure you have the following:

*   An Azure Subscription
*   Azure CLI installed and configured
*   Terraform CLI installed
*   A GitHub account and a new repository created for this project
*   A Terraform Cloud account and organization
*   Service Principal with Contributor role on your Azure Subscription (for GitHub Actions)

## Security Considerations

*   **Service Principal**: Ensure your Azure Service Principal has the minimum necessary permissions. For this project, Contributor role at the subscription level is required for both policy deployment and resource creation.
*   **GitHub Secrets**: Store all sensitive credentials (Azure Client ID, Client Secret, Subscription ID, Tenant ID, **Terraform Cloud API Token**) as GitHub Encrypted Secrets.
*   **Policy Enforcement**: The policy is set to `Deny` by default. Be aware that this will prevent any resource creation outside \'East US\' in the assigned scope. Adjust the `effect` parameter in `policy-module/variables.tf` to `Audit` if you wish to only monitor violations without blocking deployments.

## Contributing

Contributions are welcome! Please refer to the `CONTRIBUTING.md` (to be created) for guidelines.

## License

This project is licensed under the MIT License. See the `LICENSE` (to be created) file for details.

---


