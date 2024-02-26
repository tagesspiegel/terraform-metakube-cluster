module "with_openstack_subnet_cidr" {
  source = "../"

  cluster_name                            = "example-cluster"
  openstack_application_credential_id     = "abc"
  openstack_application_credential_secret = "abc"

  openstack_network_config = {
    subnet_cidr = "10.0.0.0/24"
  }

  cluster_rbac = {
    "name" = [ {
      kind = "value"
      name = "value"
    } ]
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
