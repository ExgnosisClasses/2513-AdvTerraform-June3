module "RG" {
  for_each = toset(var.SGnames)

  source  = "../modules/RG"
  RGName  = each.value
}
