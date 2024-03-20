variable "vault_approle_roleid" {
  type = string
}
variable "vault_approle_secretid" {
  type = string
  sensitive = true
}
variable "vault_addr" {
  type = string
}
variable "resource_group" {
    type = string
}
variable "az_location" {
  type = string
}
variable "vm_name" {
  type = string
}
variable "vm_admin" {
  type = string
}
variable "image_name" {
  type = string
}
variable "boundary_addr" {
  type = string
}
variable "boundary_authmethod" {
  type = string
}
variable "boundary_user" {
  type = string
}
variable "boundary_password" {
  type = string
  sensitive = true
}
variable "hcp_client_id" {
  type = string
}
variable "hcp_client_secret" {
  type = string
  sensitive = true
}
variable "packer_bucket_name" {
  type = string
}
variable "packer_channel_name" {
  type = string
}
variable "packer_platform" {
  type = string
}
variable "packer_region" {
  type = string
}
