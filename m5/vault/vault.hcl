 listener "tcp" {
    address          = "0.0.0.0:8200"
    cluster_address  = "0.0.0.0:8201"
    tls_cert_file = "/etc/vault/certs/vault_cert.crt"
    tls_key_file = "/etc/vault/certs/vault_cert.key"
  }

  storage "consul" {
    address = "127.0.0.1:8500"
    path    = "vault/"
  }

  api_addr =  "https://10.0.1.6:8200"
  cluster_addr = "https://10.0.1.6:8201"
  disable_mlock = true
