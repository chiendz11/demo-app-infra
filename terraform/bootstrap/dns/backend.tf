terraform {
  backend "s3" {
    bucket       = "demo-app-infra-tfstate-980794397912-ap-southeast-1"
    key          = "bootstrap/dns.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

