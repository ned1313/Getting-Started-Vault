path "devkv/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "devkv/appId*" {
  capabilities = ["create", "read", "update", "delete", "list"]

  allowed_parameters = {
    "api-key" = []
    "environment" = ["dev", "qa","staging","production"]
    "description" = []
  }
}

path "secret/data/{{identity.entity.id}}/*" {
  capabilities = ["create", "update", "read", "delete"]
}

path "secret/metadata/{{identity.entity.id}}/*" {
  capabilities = ["list"]
}