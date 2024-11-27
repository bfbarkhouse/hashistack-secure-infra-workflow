variable "vault_addr" {
  type = string
}
variable "vault_namespace" {
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
variable "vm_size" {
  type = string
}
variable "vm_admin_username" {
  type = string
}
variable "boundary_addr" {
  type = string
}
variable "boundary_scope_id" {
  type = string
}
variable "boundary_project_name" {
  type = string
}
variable "hcp_boundary_cluster_id" {
  type = string
}
variable "boundary_authmethod" {
  type = string
}
variable "boundary_user" {
  type = string
}
variable "boundary_password" {
  type      = string
  sensitive = true
}
variable "boundary_session_bucket" {
  type = string
}
variable "boundary_egress_filter" {
  type = string
}
variable "hcp_client_id" {
  type = string
}
variable "hcp_client_secret" {
  type      = string
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
