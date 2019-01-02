datacenter = "dc1"
data_dir = "/opt/consul"
encrypt = "${encrypt_key}"
advertise_addr = "${node_ip_address}"
retry_join = ["${node_1_ip_address}", "${node_2_ip_address}", "${node_3_ip_address}"]