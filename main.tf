#wiring terraform into k8s things
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

#specifies kubeconfig path and context for cluster authenticatio
provider "kubernetes" {
  config_path = var.kubeconfig_path
  config_context = var.chatty_kube_context
}

#labels that keep everything findable later
locals {
  app_labels = {
    "app.kubernetes.io/name" = var.app_name
    "app.kubernetes.io/component" = "web"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
#consistent labels make kubectl get pods way nicer

#isolates application resources from default namespace
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.vibe_environment_tag
    }
  }
}

#ConfigMap renders HTML template and stores it for nginx volum mount
resource "kubernetes_config_map" "static_site" {
  metadata {
    name = "${var.app_name}-content"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = local.app_labels
  }

  data = {
    "index.html" = templatefile("${path.module}/templates/index.html.tpl", {
      title = var.hero_card_title
      message = var.hero_card_message
      env = var.vibe_environment_tag
      accent = var.hero_accent_hex
      highlights = var.bragging_highlights
      bg_start = var.cozy_background_start
      bg_end = var.cozy_background_end
      shadow = var.glowy_shadow_blur_size
      cta_label = var.handy_button_label_text
      cta_url = var.handy_button_url_link
    })
  }
}
#any updates to those vars rerender html automatically on apply

#Deployment manages pod replicas and mounts ConfigMap as volume
resource "kubernetes_deployment" "app" {
  metadata {
    name= "${var.app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = local.app_labels
  }

  spec {
    #setting replica count here keeps kubernetes honest w/ how many pods we expect
    replicas = var.replicas

    selector {
      match_labels = local.app_labels
    }

    template {
      metadata {
        labels = local.app_labels
      }

      spec {
        container {
          #nginx hosts rendered html & these envs make debugging nicer
          name= var.app_name
          image = var.container_image

          port {
            name= "http"
            container_port = 80
          }

          env {
            name = "APP_MESSAGE"
            value = var.hero_card_message
          }

          resources {
            limits = {
              cpu = "250m"
              memory = "256Mi"
            }

            requests = {
              cpu = "150m"
              memory = "128Mi"
            }
          }

          liveness_probe {
            #HTTP GET probe: checks container health, triggers restart on failure
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds = 10
          }
          #readiness stays separate so port-forward waits for html to actually serve

          readiness_probe {
            #Readiness probe: determines when pod can receive traffic
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds = 5
          }

          volume_mount {
            name = "static-content"
            mount_path = "/usr/share/nginx/html"
            read_only = true
          }
        }

        volume {
          name = "static-content"

          config_map {
            name = kubernetes_config_map.static_site.metadata[0].name
          }
        }
      }
    }
  }
}

#Service exposes deployment pods via ClusterIP for internal acces
resource "kubernetes_service" "app" {
  metadata {
    name= "${var.app_name}-service"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels= local.app_labels
  }

  spec {
    #selector glues traffic to pods that share same labels
    selector = local.app_labels

    port {
      name = "http"
      port= 80
      target_port = "http"
    }

    #ClusterIP keeps things internal, perfect for kubectl portforwarding
    type = "ClusterIP"
  }
}
#stick a LoadBalancer here later if you move beyond local demos

