# Kubernetes Terraform Project

This repo spins up a tiny static site on a local kind cluster (https://kind.sigs.k8s.io/). Terraform handles namespace, configmap, deployment, & service while HTML template keeps UI looking sleek & modern for the project

## What is needed

- Terraform ≥ 1.5
- kind cluster already running (the sample context is kind-cloudcomp-cluster)
- kubectl pointed at that cluster so Terraform’s Kubernetes provider can reach it

## Included in this project

- `main.tf` - wires Terraform to Kubernetes, renders the template, deploys it, exposes it
- `variables.tf` - all input variables for website
- `terraform.tfvars` - default values
- `templates/index.html.tpl` - the UI w/ gradient background, highlight pills, CTA
- `outputs.tf` - handy copy/paste snippets (namespace & port-forward command)

## How to run it

1. Open terraform.tfvars & set values like pals_kubeconfig_path, chill_app_name, & hero_card_title
2. Run:
   ```powershell
   terraform init
   terraform fmt #Optional but necessary
   terraform validate
   terraform apply
   ```
3. Port-forward service so browser can hit it:
   ```powershell
   kubectl port-forward -n cloudcomp-app svc/static-site-service 8080:80
   ```
4. Visit http://localhost:8080
   rerun terraform apply, and the HTML updates without rebuilding images.

## Enhancements

- **ConfigMap content** - Terraform fills in templates/index.html.tpl
  using whatever values chosen for hero_card_title, hero_card_message, and the list of blurbs. Updating the varfiables will update the pages automatically.

- **Accent & highlight chips** - hero_accent_hex and bragging_highlights
  control the pills without touching CSS.

- **Gradient aura & glow** - cozy_background_start, cozy_background_end,
  and glowy_shadow_blur_size helps to design and fine-tine the background mood

- **CTA button** - handy_button_label_text & handy_button_url_link drop a
  nice call to action button for pointing towards documentation or other things.

## Getting rid of Everything

```powershell
terraform destroy #the powershell command for destroying the terraform initialization
```
