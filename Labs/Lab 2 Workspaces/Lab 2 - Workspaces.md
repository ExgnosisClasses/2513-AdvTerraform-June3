# Lab 2: Workspaces

In this lab, you will create and deploy Terraform configuration from two workspaces `prod` and `dev`
- Two different version of the same resource will be created.


## Terraform setup

- Ensure that your resources from lab 1 have been cleaned up
- If you look in your directory, you will see the state file created when you created the deployment.
- If you didn't create the deployment in lab one, then you won't see the files `terraform.tfstate` or `terraform.tfstate.backup`
- In any case, these files do not play any role in this lab, so it doesn't matter if they exist or not.

```console
rod [ ~ ]$ ls -l
total 20
-rw-r--r-- 1 rod rod  104 Jun  1 15:45 main.tf
-rw-r--r-- 1 rod rod  197 Jun  1 13:41 providers.tf
-rw-r--r-- 1 rod rod  181 Jun  1 15:49 terraform.tfstate
-rw-r--r-- 1 rod rod  959 Jun  1 15:49 terraform.tfstate.backup
drwxr-xr-x 2 rod rod 4096 Jun  1 15:46 terraform.tfstate.d
```

**Delete the lab1 `main.tf` file, but leave the `providers.tf` file**


## Create the Terraform workspaces

- First, list the existing workspaces with `terraform workspace list`

```console
rod [ ~ ]$ terraform workspace list
* default

rod [ ~ ]$ terraform workspace show
default
```

- Create the `prod` workspace with `terraform workspace new prod`
- Note that Terraform automatically makes it the default workspace

```console
rod [ ~ ]$ terraform workspace new prod
Created and switched to workspace "prod"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

- Create the `dev` workspace the same way with `terraform workspace new dev`

```console
rod [ ~ ]$ terraform workspace new dev
Created and switched to workspace "dev"!

You're now on a new, empty workspace. Workspaces isolate their state,
so if you run "terraform plan" Terraform will not see any existing state
for this configuration.
```

- Confirm the workspaces are created using `terraform workspace list`

```console
rod [ ~ ]$ terraform workspace list
  default
* dev
  prod
```

- Confirm that the directories for the workspaces' state files exist. 
- Since you haven't created a deployment, the actual state files in those directories don't exist yet.

```console
rod [ ~ ]$ ls -l terraform.tfstate.d
total 8
drwxr-xr-x 2 rod rod 4096 Jun  1 16:04 dev
drwxr-xr-x 2 rod rod 4096 Jun  1 16:03 prod

rod [ ~ ]$ ls -l terraform.tfstate.d/dev
total 0

```

## Upload the Files


- Normally, we would use git or another SCV system to save the different configurations
- In the interests of time, will just swap different `main.tf` files in and out
- We are going to leverage the fact that Terraform will ignore all files without the `*tf` extension
  - **THIS IS NOT A RECOMMENDED PRACTICE!!**

- The files are `main.dev` and `main.prod`
- Each file contains a variant of a resource group.
- Again, like in lab 1, use a unique name you can change in each variant

-  Use the same `providers.tf` file you used in the last lab

- Here is the provided `main.prod` file

```terraform
# Lab 2 Prod file
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

And here is the `main.dev` file

```terraform
# Lab 2 dev file
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

- Confirm they are in your directory

```console
rod [ ~ ]$ ls -l
total 24
-rw-r--r-- 1 rod rod  257 Jun  1 16:32 main.dev
-rw-r--r-- 1 rod rod  244 Jun  1 16:32 main.prod
-rw-r--r-- 1 rod rod  197 Jun  1 13:41 providers.tf
-rw-r--r-- 1 rod rod  181 Jun  1 15:49 terraform.tfstate
-rw-r--r-- 1 rod rod  959 Jun  1 15:49 terraform.tfstate.backup
drwxr-xr-x 4 rod rod 4096 Jun  1 16:04 terraform.tfstate.d
```

## Create the Production deployment

- Switch to the `prod` workspace using `terraform workspace select prod`
- Confirm it is the active workspace `terrafrom workspace show`

```console
rod [ ~ ]$ terraform workspace select prod
Switched to workspace "prod".

rod [ ~ ]$ terraform workspace show
prod

```

- Rename the `main.prod` file to `main.prod.tf`

```console
mv main.prod main.prod.tf
```

### Run the configuration

- Run `terraform apply`
- You should note at the end of the plan; it will confirm it is using the `prod` workspace

```console
rod [ ~ ]$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab2 will be created
  + resource "azurerm_resource_group" "lab2" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy123Prod"
      + tags     = {
          + "environment" = "Prod Configuration"
          + "owner"       = "Zippy"
          + "purpose"     = "Used in prod workspace"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "prod"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```

- Confirm that there is now a state file in the `prod` directory

```console
rod [ ~ ]$ ls terraform.tfstate.d/prod
terraform.tfstate
```


## Create Development deployment

### Change configuration

- Rename the `main.prod.tf` file to `main.prod`
- Rename the `main.dev` file to `main.dev.tf`
- This has the effect of defining a new configuration for deployment
- Confirm with `ls`

```console
rod [ ~ ]$ mv main.prod.tf main.prod
rod [ ~ ]$ mv main.dev main.dev.tf
rod [ ~ ]$ ls -l
total 24
-rw-r--r-- 1 rod rod  257 Jun  1 16:32 main.dev.tf
-rw-r--r-- 1 rod rod  244 Jun  1 16:32 main.prod
-rw-r--r-- 1 rod rod  197 Jun  1 13:41 providers.tf
-rw-r--r-- 1 rod rod  181 Jun  1 15:49 terraform.tfstate
-rw-r--r-- 1 rod rod  959 Jun  1 15:49 terraform.tfstate.backup
drwxr-xr-x 4 rod rod 4096 Jun  1 16:04 terraform.tfstate.d
```

### Change Workspaces

- Switch to the `dev` workspace with `terraform workspace select dev`
- Confirm you are in the correct workspace with `terraform workspace show`

```console
rod [ ~ ]$ terraform workspace select dev
Switched to workspace "dev".
rod [ ~ ]$ terraform workspace show
dev
```

### Run the configuration

- Just like you did for `prod`, run `terraform apply`
- Notice that the plan states it will execute in workspace `dev`

```console
rod [ ~ ]$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.lab2 will be created
  + resource "azurerm_resource_group" "lab2" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy123Dev"
      + tags     = {
          + "environment" = "Dev Configuration"
          + "owner"       = "Feddy the Wonder Llama"
          + "purpose"     = "Used in dev workspace"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions in workspace "dev"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
```

- Confirm the new `dev`state file exists

```console
rod [ ~ ]$ ls terraform.tfstate.d/dev
terraform.tfstate
```

- Confirm in the GUI that both resources exist.

## Cleanup

### Destroy the Development deployment

- Make sure you are in the `dev` workspace and use `terraform destroy`


```console
rod [ ~ ]$ terraform workspace show
dev
rod [ ~ ]$ terraform destroy
azurerm_resource_group.lab2: Refreshing state... [id=/subscriptions/f1a145f5-f75d-4170-a316-576364d2886b/resourceGroups/Zippy123Dev]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_resource_group.lab2 will be destroyed
  - resource "azurerm_resource_group" "lab2" {
      - id         = "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxx4d2886b/resourceGroups/Zippy123Dev" -> null
      - location   = "eastus" -> null
      - name       = "Zippy123Dev" -> null
      - tags       = {
          - "environment" = "Dev Configuration"
          - "owner"       = "Feddy the Wonder Llama"
          - "purpose"     = "Used in dev workspace"
        } -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources in workspace "dev"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.
```

### Destroy the Production deployment

- Swap the files so you are using the right version of the configuration file
- `main.dev.tf` -> `main.dev`
- `main.prod` -> `main.prod.tf`
  

```console
rod [ ~ ]$ mv main.dev.tf man.dev
rod [ ~ ]$ mv main.prod main.prod.tf
rod [ ~ ]$ ls -l
total 24
-rw-r--r-- 1 rod rod  244 Jun  1 16:32 main.prod.tf
-rw-r--r-- 1 rod rod  257 Jun  1 16:32 man.dev
-rw-r--r-- 1 rod rod  197 Jun  1 13:41 providers.tf
-rw-r--r-- 1 rod rod  181 Jun  1 15:49 terraform.tfstate
-rw-r--r-- 1 rod rod  959 Jun  1 15:49 terraform.tfstate.backup
drwxr-xr-x 4 rod rod 4096 Jun  1 16:04 terraform.tfstate.d

```

- Switch to the `prod` workspace with the command `terraform workspace select prod`

```console
rod [ ~ ]$ terraform workspace select prod
Switched to workspace "prod".

rod [ ~ ]$ terraform workspace show
prod

```

- Execute `terraform destroy`

```console
terraform destroy
azurerm_resource_group.lab2: Refreshing state... [id=/subscriptions/f1a145f5-f75d-4170-a316-576364d2886b/resourceGroups/Zippy123Prod]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_resource_group.lab2 will be destroyed
  - resource "azurerm_resource_group" "lab2" {
      - id         = "/subscriptions/f1axxxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Zippy123Prod" -> null
      - location   = "eastus" -> null
      - name       = "Zippy123Prod" -> null
      - tags       = {
          - "environment" = "Prod Configuration"
          - "owner"       = "Zippy"
          - "purpose"     = "Used in prod workspace"
        } -> null
        # (1 unchanged attribute hidden)
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources in workspace "prod"?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.
```

## Delete the workspaces

- Since you cannot delete a workspace that you are currently working in, switch to the default workspace

```console
rod [ ~ ]$ terraform workspace select default
Switched to workspace "default".
```

- Delete the `dev` and `prod` workspaces with `terraform workspace delete`
- List the workspaces to ensure they are deleted

```console
rod [ ~ ]$ terraform workspace delete dev
Deleted workspace "dev"!

rod [ ~ ]$ terraform workspace delete prod
Deleted workspace "prod"!

rod [ ~ ]$ terraform workspace list
* default
```

- Check to see that the workspace directories are also deleted

```console
rod [ ~ ]$ ls terraform.tfstate.d/
rod [ ~ ]$ 

```


## End Lab