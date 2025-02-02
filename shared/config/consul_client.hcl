# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

ui_config {
  enabled = true
}
log_level      = "INFO"
data_dir       = "/opt/consul/data"
bind_addr      = "0.0.0.0"
client_addr    = "0.0.0.0"
advertise_addr = "IP_ADDRESS"
retry_join     = ["RETRY_JOIN"]
ports = {
  grpc = 8502
}