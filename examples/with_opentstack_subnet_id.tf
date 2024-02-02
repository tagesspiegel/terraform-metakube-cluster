module "with_opentstack_subnet_id" {
  source = "../"

  cluster_name                            = "example-cluster"
  openstack_application_credential_id     = "abc"
  openstack_application_credential_secret = "abc"

  openstack_network_config = {
    network_name = "example"
    subnet_id    = "example"
  }

  cluster_rbac = {
    "name" = [{
      kind = "value"
      name = "value"
    }]
  }

  syseleven_auth_realm = "example"

  metakube_project_id = "example"

  node_pools = {
    "example" = {
      node_config = {
        flavor          = "example"
        use_floating_ip = false
      }
      os_config = {
        auto_update = false
        image       = "example"
      }
      replicas = {
        max = 0
        min = 0
      }
    }
  }
}
