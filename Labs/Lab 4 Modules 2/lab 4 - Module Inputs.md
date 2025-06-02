# Lab 4 - Module Inputs and outputs

This lab builds off of the previous lab.
- Just be sure you have no deployed resources left over from lab 3, specifically that you have run `terraform destroy`

***NOTE!!! This lab uses the names for the RGs as "Zippy_1" and "Zippy_2 You need to change these using the sample code to unique identifiers so your RG names are unique in the class***



## Part 1: Add the module variables file

- Upload the `variables.tf` file from the `modules/RG` lab directory to your `modules/RG` directory in the cloud shell.
- This file will specify the resource group name variable

```terraform
variable "RGName" {
    description = "Name for generated Resource Group"
    type = string
}
```

## Part 2: Add the modified module file

- Delete the existing `RG.tf` file in the RG module directory
- Upload the new `RG.tf` file and move it to the RG module directory


- This is the modified `RG.tf` file that replaces the hard coded name with a variable value

```terraform
resource "azurerm_resource_group" "resgrp" {
  name     = var.RGName
  location = "eastus"
  tags = {
      Sourcing = "Module Generated"
    }
}
```

Your RG module directory should look like this

```console
rod [ ~/modules/RG ]$ ls
RG.tf  variables.tf
```

## Part 3: Add the modified root file

- Delete the existing `root.tf` file in the project directory
- Upload the new `root.tf` file and move it to the project directory


- This is the new `root.tf` file

```terraform
module "RG1" {
    source = "../modules/RG"
    RGName = "Zippy_1"
}

module "RG2" {
    source = "../modules/RG"
    RGName = "Zippy_2"
}

```

- We are now making two calls to the module to create the resource groups.
- We have also added a line that assigns the variable `RGName` a value to be used in the module call

## Part 4: Terraform init.

- If you just run `terriform validate` the following error will occur

```console
rod [ ~/project ]$ terraform validate
╷
│ Error: Module not installed
│ 
│   on root.tf line 6:
│    6: module "RG2" {
│ 
│ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
```

- The Reason for this is that Terraform needs to resolve the new module reference to an actual module location.
- Run `terraform init` and the output should look like this:


```console
rod [ ~/project ]$ terraform init
Initializing the backend...
Initializing modules...
- RG2 in ../modules/RG
Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v4.31.0

Terraform has been successfully initialized!

```

- Note that in the output, Terraform resolved the second module call
- It didn't need to resolve the first once, since it already did the previous time you ran `terraform init`

## Part 5: Deploy

- Run `terraform apply` and note that two resource groups will be created

```console
rod [ ~/project ]$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.RG1.azurerm_resource_group.resgrp will be created
  + resource "azurerm_resource_group" "resgrp" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy_1"
      + tags     = {
          + "Sourcing" = "Module Generated"
        }
    }

  # module.RG2.azurerm_resource_group.resgrp will be created
  + resource "azurerm_resource_group" "resgrp" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy_2"
      + tags     = {
          + "Sourcing" = "Module Generated"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.

```

- Once you have created the resources, check in the GUI that they have been created

## Part 6: Tear down

- Run `terraform destroy` ensure you have no resources deployed.

## Part 7: Variables

- The problem with the deployment is that we are still hard coding the resource group name
- Upload the file `variables.tf` from the `project` directory 
- Move it into the `project` directory

- Upload and move the `terraform.tfvars` file into the `project` directory

- The `variables.tf` filw in the `project` directory  should look like this:

```terraform
variable SGnames {
    description = "List of names for the resource groups"
    type = list(string)
 }
```

- The `type` field says we are going to provide a list of strings.
- We can see this in the `terraform.tfvars` file

```terraform
SGnames = ["Zippy_1", "Zippy_2"]
```

- Now we set up the `root.tf` file to use the values passed into the root module instead of the hard-coded values
- Upload the file `root2.tf`
- Move it to the `project` directory
- Delete your old `root.tf` file
- Notice that we are passing the different components of the list of strings to the module variable.

```terraform
module "RG1" {
    source = "../modules/RG"
    RGName = var.SGnames[0]
}

module "RG2" {
    source = "../modules/RG"
    RGName = var.SGnames[1]
}
```

## Part 8: Deploy

- Run `terriform validate` to catch any errors.
- Run `terraform apply`

```console
rod [ ~/project ]$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # module.RG1.azurerm_resource_group.resgrp will be created
  + resource "azurerm_resource_group" "resgrp" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy_1"
      + tags     = {
          + "Sourcing" = "Module Generated"
        }
    }

  # module.RG2.azurerm_resource_group.resgrp will be created
  + resource "azurerm_resource_group" "resgrp" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "Zippy_2"
      + tags     = {
          + "Sourcing" = "Module Generated"
        }
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

- Confirm the deployment at the GUI


## PArt 9: Cleanup

- Run `terraform destroy` to remove your deployment
- Do not delete your source files, you will use them in the next two labs


## End Lab