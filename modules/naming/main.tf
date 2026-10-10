locals {
  region_environment = "${var.region_code}${var.environment_code}"
  components         = [var.resource_type, local.region_environment, var.workload_code, var.instance]
}
