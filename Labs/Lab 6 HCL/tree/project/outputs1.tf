output "rg_names" {
  value = [for rg in module.RG : rg.rg_id]
}