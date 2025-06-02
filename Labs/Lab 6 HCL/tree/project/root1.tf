module "RG" {
  count   = length(var.SGnames)
  source  = "../modules/RG"
  RGName  = var.SGnames[count.index]
}