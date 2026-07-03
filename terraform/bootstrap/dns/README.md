# DNS bootstrap

This root module creates the Route 53 public hosted zone for the registered
domain. Domain registration and delegation at the external registrar remain
manual because the registrar is outside AWS.

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan
terraform output name_servers
```

Copy all four values from `name_servers` to the registrar's custom name server
configuration. Verify delegation before applying the production environment:

```bash
dig NS <root-domain> +short
```

