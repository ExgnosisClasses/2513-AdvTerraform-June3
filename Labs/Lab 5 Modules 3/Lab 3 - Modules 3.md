# Lab 5: Outputs

This is an add-on to the previous lab.

If you are not set up from the previous lab, you can use the files in the `tree directory` to populate you shell

If you are set up in the previous lab, just upload the two `outputs.tf` files to the approriate locatiosn

`outputs.tf` for the RC module
 
```terraform
output "rg_id" {
  value = azurerm_resource_group.resgrp.id
  description = "The ID of the created resource group resource group"
}
```

`outputs.tf` for the project module

```terraform
output "RG1_id" {
  value       = module.RG1.rg_id
  description = "ID of Resource Group RG1"
}

output "RG2_id" {
  value       = module.RG2.rg_id
  description = "ID of Resource Group RG2"
}
```

Then:
1. Run `terraform init`
2. Run `terraform apply`
3. Observe the variable output
4. Run `terraform destory`