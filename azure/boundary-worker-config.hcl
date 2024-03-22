disable_mlock = true

#hcp_boundary_cluster_id = "083e8b02-a6dd-4b6b-99c5-f28d3625d1c1"
hcp_boundary_cluster_id = "env://HCP_BOUNDARY_CLUSTER_ID"

listener "tcp" {
  address = "127.0.0.1:9202"
  purpose = "proxy"
}

worker {
  auth_storage_path = "/boundary/worker"
  tags {
    type = ["azure", "worker"]
  }
  recording_storage_path = "/boundary/session-storage"
}
