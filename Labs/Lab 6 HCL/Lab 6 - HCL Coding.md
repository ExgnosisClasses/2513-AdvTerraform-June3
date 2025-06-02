# Lab 6: HCL Coding

In this lab, you will work with some HCL code constructs

***NOTE!!! This lab uses the names for the RGs as "Zippy_1" and "Zippy_2 You need to change these using the sample code to unique identifiers so your RG names are unique in the class***


## Part 1: Set up

- For this section, we will use the same module setup as the last lab
- Create a `modules/RG` folder under the main directory
- Create a `project` folder under the main directory
- Upload the three files in the RG directory in the lab folder into the corresponding directory in your Azure shell
- These will remain the same throughout the lab

## Part 2: No Loops

- Edit the `terraform.tfvars` file in the `tree/project` directory
- Replace the strings "Zippy_1" and "Zippy_2" with unique names like this
- Otherwise it will conflict with other student names

```terraform
SGnames = ["alabama34333", "grease99987"]
```

- Upload your `providers.tf` file and move it to the `project` directory
  - Upload the following file from the `tree/project` directory in the lab, and move them to your `project` directory
    - `outputs.tf`
    - `root.tf`
    - `terraform.tfvars`
    - `variables.tf`
  
- Your `project` directory should look like this

```console
rod [ ~ ]$ ls project
outputs.tf  providers.tf  root.tf  terraform.tfvars  variables.tf
```

#### The root.tf file

- This creates two modules like you did before

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

#### The variables, outputs and vars file.

- The `variables.tf`

```terraform
variable SGnames {
    description = "List of names for the resource groups"
    type = list(string)
 }
```

- The `terraform.tfvars` file, but it should have your unique names

```terraform
SGnames = ["Zippy_1", "Zippy_2"]
```

- The `root.tf` file

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

### Run the config

- Execute `terraform init`
- You should see the module call initialization

```console
rod [ ~/project ]$ terraform init
Initializing the backend...
Initializing modules...
- RG1 in ../modules/RG
- RG2 in ../modules/RG
Initializing provider plugins...
- Finding latest version of hashicorp/azurerm...
- Installing hashicorp/azurerm v4.31.0...
- Installed hashicorp/azurerm v4.31.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

- Now run `terraform apply` and confirm the outputs show the two created resources

```console
Outputs:

RG1_id = "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxd2886b/resourceGroups/Zippy_1"
RG2_id = "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxxx886b/resourceGroups/Zippy_2"
```

- Now run `terraform destroy` and remove the resources

### Part 3: Using count

- Replace the exising `root.tf` file with the `root1.tf` file from the lab repo

```terraform
module "RG" {
  count   = length(var.SGnames)
  source  = "../modules/RG"
  RGName  = var.SGnames[count.index]
}
```

- Since the "RG" module is called more than once, the resulting resource groups can be reference as `RG[0]` and `RG[1]`

- This means replacing the existing `outputs.tf` file with the `outputs1.tf` file
- Notice that we make use of the fir `for` construct to loop though the array of resources

```terraform
output "rg_names" {
  value = [for rg in module.RG : rg.rg_id]
}
```

- Because we have changed the module calls, rerun `terrafrom init`


```console
od [ ~/project ]$ terraform init
Initializing the backend...
Initializing modules...
- RG in ../modules/RG
Initializing provider plugins...
- Reusing previous version of hashicorp/azurerm from the dependency lock file
- Using previously-installed hashicorp/azurerm v4.31.0

Terraform has been successfully initialized!

```

- Now run `terraform apply` and confirm the output

```console
module.RG[1].azurerm_resource_group.resgrp: Creating...
module.RG[0].azurerm_resource_group.resgrp: Creating...
module.RG[0].azurerm_resource_group.resgrp: Still creating... [10s elapsed]
module.RG[1].azurerm_resource_group.resgrp: Still creating... [10s elapsed]
module.RG[0].azurerm_resource_group.resgrp: Creation complete after 11s 


Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

rg_names = [
  "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxx4d2886b/resourceGroups/Zippy_1",
  "/subscriptions/f1a14xxxxxxxxxxxxxxxxxxxxxxxxxd2886b/resourceGroups/Zippy_2",
]
```

- Run `terraform destroy` to remove the deployment

## Part 4: Using `foreach`

- This uses a map with the keyvalues being given but the input values
- Delete the `root1.tf` file from project
- Upload the `root2.tf` file and move it to the project directory
- In this case, you can create a duplicate entry as well in the `terraform.tfvars` file
- Like this

```terraform
SGnames = ["Zippy_1", "Zippy_2", "Zippy_1"]
```

- The `root2.tf` file looks like this

```terraform
module "RG" {
  for_each = toset(var.SGnames)

  source  = "../modules/RG"
  RGName  = each.value
}
```

- The list of string is converted to a set to remove duplicate
- Execute `terraform init`
- Execute `terraform apply`
- Note that the RG map is indexed by the name

```console
module.RG["Zippy_1"].azurerm_resource_group.resgrp: Creating...
module.RG["Zippy_2"].azurerm_resource_group.resgrp: Creating...
```

## Clean up

- Run `terraform destroy`