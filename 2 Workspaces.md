# 2 Workspaces

## Default Workspace

- When initially installed, Terraform starts with a default workspace.
- Since Terraform needs a workspace and module to operate, a default root module and default workspace are created at installation time.

## Why Workspaces?

- It may happen that several different configurations need to be maintained at the same time
  - For example, a development configuration and a production configuration
- Workspaces allow multiple configurations to be supported from the same working environment
- A good analogy for workspaces is git branches
  - The prod workspace would correspond to the main branch
  - The dev workspace would correspond to a dev branch

### Workspace Caveat

- Workspaces should be used **only** with non overlapping resources
- More than one workspace managing the same resource will eventually result in corruption of the cloud environment.
 
Corruption example:
- The production environment has created a resource group named "AppRg"
- The development environment also tries to create a resources named "AppRG"
- The state of the RG is kept in the prod workspace
- There is no record of the RG in the dev workspace
- The dev workspace tries to create it and fails because it already exists


## The Workspace Command

- The `terraform workspace` command has a set of sub-commands to manage workspaces

```console
rod [ ~ ]$  terraform workspace
Usage: terraform [global options] workspace

  new, list, show, select and delete Terraform workspaces.

Subcommands:
    delete    Delete a workspace
    list      List Workspaces
    new       Create a new workspace
    select    Select a workspace
    show      Show the name of the current workspace
```

## Creating a Workspace

- In the following example, a `prod` workspace is created.
- In this example, there is no default state file since there was no initial terraform configuration executed with `terraform apply`
  - Recall the state file is only created when a terraform plan or apply command executes


```console
rod [ ~ ]$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

- To ensure that each of the workspaces has isolation of its deployed state, a directory for each workspace is created in the `terraform.tfstate.d` directory


```console
rod [ ~ ]$ ls
providers.tf  terraform.tfstate.d

rod [ ~ ]$ ls terraform.tfstate.d
prod
rod [ ~ ]$ 
```

- Now a second workspace is created and given its own directory

```console
rod [ ~ ]$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

The directory has been created:

```console
rod [ ~ ]$ ls terraform.tfstate.d
dev  prod
```

## Workspace show and list

- List the workspaces. Note that the current workspace is flagged with `*`

```console
rod [ ~ ]$ terraform workspace list
  default
* dev
  prod
```

## Create a deployment

- Because terraform merges ALL of the`*tf` files in a directory, we need to version our file to ensure that our Terraform source code is versioned in a corresponding way using git or something similar
- Terraform will keep different versions of the state file, one for each of the workspaces
- Switching between workspaces will tell Terraform to "check out" the workspace's version of the state file

**State file should NEVER be put into a repository like git**
- That would make it possible to check out a different version of a state file that doesn't correspond to the running deployment 
  - That never ends well
- You can store historical state files in a version repository as long as they will never be used actively again
  - This is often useful for audit and other investigations into historical deployments

## Versioned configurations

- The accepted best practice is to put the Terraform configuration files under version control
- Each workspace has a corresponding branch
- For example, we would create `prod` and `dev` branches in git to correspond to the `prod` and `dev` workspaces.
- It would be up to us to ensure we are using the right branch with each workspace
  - Otherwise, we could wind up with deployment errors

## Deleting Workspaces

- You can delete a workspace using the `terraform workspace delete` command
- Terraform will try to ensure you don't delete the state files for active deployments


```console
rod [ ~ ]$ terraform workspace delete prod
╷
│ Error: Workspace is not empty
│ 
│ Workspace "prod" is currently tracking the following resource instances:
│   - azurerm_resource_group.lab2
│ 
│ Deleting this workspace would cause Terraform to lose track of any associated remote objects, which would then require you to delete them manually outside of Terraform. You should destroy these objects with
│ Terraform before deleting the workspace.
│ 
│ If you want to delete this workspace anyway, and have Terraform forget about these managed objects, use the -force option to disable this safety check.
```


## Use of Locals

- Terraform supports local variables
- One specific use case is to use locals to configure a Terraform file for different workspaces
- For example, we may want to deploy to different versions of a resource group, the `prod` version is shown here

```terraform
resource "azurerm_resource_group" "lab2" {
  name     = "Zippy123Prod"
  location = "eastus"
  tags = {
      environment = "Prod Configuration"
      owner       = "Zippy"
      purpose     = "Used in prod workspace"
    }
}
```

- And the `dev` version is shown here


```terraform
resource "azurerm_resource_group" "lab2" {
  name     = "Zippy123Dev"
  location = "eastus"
  tags = {
      environment = "Dev Configuration"
      owner       = "Feddy the Wonder Llama"
      purpose     = "Used in dev workspace"
    }
}
```

- However, a far more efficient way is to parameterize the values we customize in each workspace and populate those with a `locals.tf` file

- The `main.tf` file is now:

```terraform
resource "azurerm_resource_group" "lab2" {
  name     = local.resource_group_name
  location = "eastus"
  tags     = local.resource_group_tags
}

```

- The `dev` workspace uses this `locals.tf` file

```terraform
locals {
  resource_group_name = "Zippy123Dev"

  resource_group_tags = {
    environment  = "Dev Configuration"
      owner       = "Feddy the Wonder Llama"
      purpose     = "Used in dev workspace"
  }
}
```

- And `prod` uses this version of the `locals.tf`

```terraform
locals {
  resource_group_name = "Zippy123Prod"

  resource_group_tags = {
    environment = "Prod Configuration"
    owner       = "Zippy"
    purpose     = "Used in prod workspace"
  }
}
```

- In this small example, the benefits are not immediately obvious
- But if we had to make this configuration change over a number of resources, this is the mose effective way to do it.


## When Not to Use Multiple Workspaces

- Workspaces are designed to allow switching between multiple instances of a single configuration within its single backend. 
  - Often good for experimentation 
- On larger systems, this does not scale well
- Instead, the different configurations should be separated by environmental boundaries within the system. 
  - There should be a development environment and production development for example
  - Each should have its own backend state files
  - This allows more isolation of work artifacts for teams
  - Insulates against propagation of errors
 
- The best practice is to create a strong separation between multiple deployments of the same infrastructure serving different development stages or different internal teams. 
  - Backends for different deployment often have different credentials and access controls. 
  - These are difficult and dangerous to manage using multiple workspaces in the same backend

## End 