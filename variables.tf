#This file is variables dashboard
#keeping kube access details up top so no one hunts for them later

variable "kubeconfig_path" {
  description = "absolute path to kubeconfig file for kind cluster, otherwise terraform just shrugs."
  type = string
  default = "~/.kube/config"
}

variable "kube_context" {
  description = "kube context we want terraform & kubectl provider thing to poke."
  type= string
  default = "kind-cloudcomp-cluster"
}

variable "namespace" {
  description = "namespace where all goodies live"
  type = string
  default= "cloudcomp-app"
}
#handy to rename if you want different namespaces

variable "app_name" {
  description = "base name that becomes part of labels, services, deployments etc."
  type = string
  default = "static-site"
}

variable "environment_tag" {
  description = "quick little environment tag so dashboards look more organizd."
  type = string
  default = "dev"
}

variable "replicas" {
  description = "how many pods we kick off with before we think about autoscaling."
  type = number
  default = 2
}
#kind nodes appreciate it when we dont start with too many replicas

variable "container_image" {
  description = "nginx image that ends up serving our html."
  type = string
  default = "nginx:1.27-alpine"
}
#swap this if you wanna use httpd or caddy or whatever

variable "card_title" {
  description = "giant heading text at top of card."
  type = string
  default = "Cloud Computing Project - Kubernetes"
}

variable "card_message" {
  description = "friendly subtitle that also ends up as APP_MESSAGE env var"
  type = string
  default = "Hello from Terraform-managed Kubernetes Cluster!"
}

variable "accent_hex" {
  description = "primary accent hex color used for pills, button, etc"
  type = string
  default = "#2563eb"
}

variable "highlights" {
  description = "list of phrases that render as little rounded capsules"
  type = list(string)
  default = [
    "Terraform-managed infrastructure",
    "kind-powered local Kubernetes",
    "Zero-image updates via ConfigMap",
  ]
}

variable "background_start" {
  description = "first color stop in big background gradient behind card"
  type = string
  default = "#f8fafc"
}

variable "background_end" {
  description = "second gradient color stop so background dosnt look flat"
  type = string
  default = "#e0f2fe"
}

variable "glowy_shadow_blur_size" {
  description = "how blurry drop shadow glow should feel"
  type = string
  default = "30px"
}

variable "handy_button_label_text" {
  description = "text that shows inside little call to action button"
  type = string
  default= "Open kind docs"
}
#empty string here hides button without touching template

variable "handy_button_url_link" {
  description = "link CTA opens in new tab, ideally https so browsers dont panic"
  type= string
  default= "https://kind.sigs.k8s.io/"
}

