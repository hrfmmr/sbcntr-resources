locals {
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["a", "c"]
  public_subnet_cidrs = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]
  private_subnet_container_cidrs = [
    "10.0.8.0/24",
    "10.0.9.0/24"
  ]
  private_subnet_db_cidrs = [
    "10.0.16.0/24",
    "10.0.17.0/24"
  ]
  private_subnet_vpce_cidrs = [
    "10.0.248.0/24",
    "10.0.249.0/24"
  ]
}
