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

#this provider basically grabs our kubeconfig & context so terraform knows who to talk to
provider "kubernetes" {
  config_path = var.pals_kubeconfig_path
  config_context = var.chatty_kube_context
}

#labels that keep everything findable later
locals {
  app_labels = {
    "app.kubernetes.io/name" = var.chill_app_name
    "app.kubernetes.io/component" = "web"
    "app.kubernetes.io/managed-by" = "terraform"
  }
}
#seriously, consistent labels make kubectl get pods way nicer

#create the namespace home so all the other objects dont crash into default
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.comfy_namespace_name
    labels = {
      environment = var.vibe_environment_tag
    }
  }
}

#render html template & stash it in configmap so nginx can just mount files
resource "kubernetes_config_map" "static_site" {
  metadata {
    name = "${var.chill_app_name}-content"
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

#deployment keeps pods alive & injects configmap as static content
resource "kubernetes_deployment" "app" {
  metadata {
    name= "${var.chill_app_name}-deployment"
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = local.app_labels
  }

  spec {
    #setting replica count here keeps kubernetes honest w/ how many pods we expect
    replicas = var.starter_pod_count

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
          name= var.chill_app_name
          image = var.web_server_image_name

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
            #tiny health check so kind restarts pod if nginx is not working correctly
            http_get {
              path = "/"
              port = "http"
            }
            initial_delay_seconds = 10
            period_seconds = 10
          }
          #readiness stays separate so port-forward waits for html to actually serve

          readiness_probe {
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

#service exposes pods via stable cluster ip so we can portforward easily
resource "kubernetes_service" "app" {
  metadata {
    name= "${var.chill_app_name}-service"
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

