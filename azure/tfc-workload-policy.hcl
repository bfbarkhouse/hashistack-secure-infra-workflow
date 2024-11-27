path "kv/+/ssh/*" {
  capabilities = ["create", "update", "read", "list", "delete"]
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
path "sys/leases/revoke" {
  capabilities = ["update"]
}