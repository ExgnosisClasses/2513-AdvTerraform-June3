# 1: Terraform Basics

Note:

To simplify terminology, the following terms are used
1. Terraform configuration: the Terraform code ing the `*tf` files that describes the Azure resources Terraform should create. Configuration files are kept locally.
2. Terraform deployment: the running Azure resources that have been created by applying a configuration

## Terraform as IaC

- Terraform is an _Infrastructure as Cde_ tool.
- It describes configurations of Azure resources using Terraform constructs
- When the configuration is deployed into the cloud environment:
  - Terraform is responsible for maintaining the configuration of the deployment
  - That means what is deployed matches what is described
- Terraform manages changes, updates and teardowns of deployed resources by users making changes in the corresponding configuration files and then apply Terraform operations

## The state file

- A Terraform deployment maintains a state file
- This matches the requested resource in the Terraform configuration file with the corresponding Azure resource
- The state file is never edited but is accessed and changed only by Terraform

## Terraform Providers

- The Terraform executable is cloud platform agnostic
- To use a specific platform, like Azure, the plugins for that platform need to be downloaded and installed locally.
- This is done by specifying the provider using the `terrform` block along with any other information that is required for that platform
- In these classes, we have been putting that information in the `provider.tf` file


```terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "f1a1xxxxxxxxxxxxxxxxxxxxxxxxxxd2886b"
}
```

## The Terraform operations

#### terraform init

- Looks for the `terraform` and `provider` blocks
- Downloads the plugins for that provider and initializes them
- Creates the working directories needed

#### terraform validate

- Ensures the Terraform configuration files are syntactically correct
- This is automatically run by `terraform plan`
- Useful for picking up errors without retrieving state from the cloud deployment

#### terraform plan

- Fetches a description of the currently deployed Azure resources it's managing
- Processes the `*tf` files to see if any changes in configuration have been made
- Update the specification in the state file of the resources that have been changed 
- Compares the state of the resource with the Terraform specification for that resources recorded in the state file.
- It then preforms the following analysis
  - If the resource doesn't exist in Azure, it writes a plan to create from the specification of that resource 
  - If the resource parameters differ from those specified in the state file, ir writes a plan to modify the resource or recreate it if it can't be modified
  - If a resource has been removed from the configuration, it writes a plan to remove the resource

#### terraform apply

- Executes `terraform plan`
- Write the CLI code to implement the changes
- Executes the code
- Errors may occur in this stage because of the existing resources in Azure
  - For example, trying to create a resource group when one already exists with the same name
  - Terraform cannot identify types of errors before execution

### terraform destroy

- Runs `terraform plan`
- For each item in the state file, it removes that item from the Azure deployment
- Executes the CLI tear-down code.


## The root module

- Every Terraform application has a root module
- This is the directory where the `*.tf` files exist
- The root module is also the directory where thr Terraform commands are executed
- And with local backends, where the state files are kept

### Compiling the source

- Done during the `terraform plan` operation
- Terraform merges all of the `*.tf` files
- All other files are ignored
- It then creates a DAG or dependency graph describing the order in which the resources should be created or modified
  - For example, ensuring a resource group is created before another resource that will be deployed to that resource group

```terraform 
resource "azurerm_resource_group" "myRG" {
  name     = "Zippy123Prod"
  location = "eastus"
  tags = {
      environment = "Prod Configuration"
      owner       = "Zippy"
      purpose     = "Used in prod workspace"
    }
}

```

- The variable `myRG` is local to the configuration file so Terraform can identify this specification in the configuration files
- Some properties are mandatory and must be specified in the configuration 
  - Like the name of the resource group
- Some are optional but are assigned default values
- Some are options, like the tags above, and are not created unless specified like in the example above.

## Terraform Variables

- Hard-coding properties is not a good Terraform practice
- Instead, we define variables that we can set to make the specification more generic
- A variable is defined in a variable block
- The values of the variables are set by using a `terraform.tfvars` file

```terraform
resource "azurerm_resource_group" "lab4" {
  name     = var.resource_group_name
  location = var.resource_group_location

  tags = {
    environment = "test environment"
    owner       = "The wonder lama"
    purpose     = "demonstrate stuff"
  }
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "resource_group_location" {
  description = "The Azure region where the resource group will be created."
  type        = string
}

```

And the variables are set in the `terraform.tfvars` file like this

```terraform
resource_group_name     = "Lab4"
resource_group_location = "eastus2"
```

- The Terraform root modules is like an application
- The variables define parameters that we can set when we call Terraform
- The `terraform.tfvars` file supplies the values of the variables at execution time


## Terraform Outputs

- A terraform module can also return values
- The return values are defined by the `output`
- For the previous example

```terraform
output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.lab5.id
}

output "resource_group_owner" {
  description = "The owner tag value of the resource group."
  value       = azurerm_resource_group.lab5.tags["owner"]
}
```

- These will be returned from the `terraform apply` command.
- Outputs usually return values created by Azure like resource ids

## End


