
locals {
  backends = [
    {
      name     = "a"
      duration = "12s"
    },
    {
      name     = "b"
      duration = "14s"
    },
    # {
    #   name     = "c"
    #   duration = "16s"
    # },
  ]
  backends_map = { for backend in local.backends : backend.name => backend }
}

module "service" {
  source = "./backend_service"
  bucket = var.bucket_name
  content = jsonencode([
    for k, mod in module.t4 :
    {
      name     = k,
      duration = mod.duration,
    }
  ])
}

module "t4" {
  for_each = local.backends_map
  source   = "./backend"
  name     = each.key
  duration = each.value.duration
}
