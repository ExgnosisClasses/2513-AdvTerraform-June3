
module "RG1" {
    source = "../modules/RG"
    RGName = var.SGnames[0]
}

module "RG2" {
    source = "../modules/RG"
    RGName = var.SGnames[1]
}