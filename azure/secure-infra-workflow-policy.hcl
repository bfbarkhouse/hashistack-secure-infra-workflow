path "kv/*" {
  capabilities = ["create", "update", "list", "read", "delete"]
}
path "auth/token/create" {
  capabilities = ["create", "update", "sudo"]
}
path "auth/token/lookup-accessor" {
  capabilities = ["update"]
}
path "auth/token/revoke-accessor" {
  capabilities = ["update"]
}
path "auth/token/lookup-self" {
  capabilities = ["read"]
}