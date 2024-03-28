disable_mlock = true

hcp_boundary_cluster_id = "env://HCP_BOUNDARY_CLUSTER_ID"

listener "tcp" {
  address = "127.0.0.1:9202"
  purpose = "proxy"
}

worker {
  auth_storage_path = "/boundary/worker"
  controller_generated_activiation_token = "env://WORKER_ACTV_TOKEN"
  tags {
    type = ["azure", "worker"]
  }
  recording_storage_path = "/boundary/session-storage"
}
