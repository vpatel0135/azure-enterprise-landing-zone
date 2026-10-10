run "readable_resource_group_name" {
  command = plan

  variables {
    resource_type    = "rg"
    region_code      = "eus2"
    environment_code = "p"
    workload_code    = "wed"
    instance         = "01"
  }

  assert {
    condition     = output.name == "rg-eus2p-wed-01"
    error_message = "The readable naming pattern changed unexpectedly."
  }
}

run "restricted_storage_name" {
  command = plan

  variables {
    resource_type    = "st"
    region_code      = "eus2"
    environment_code = "p"
    workload_code    = "wed"
    instance         = "01"
    use_hyphens      = false
  }

  assert {
    condition     = output.name == "steus2pwed01"
    error_message = "The restricted naming pattern changed unexpectedly."
  }
}
