data "google_client_config" "current" {
}

variable "helm_version" {
  default = "v2.15.2"
}

provider "kubernetes" {
  load_config_file = false
  host             = google_container_cluster.demo-cluster.endpoint

  cluster_ca_certificate = base64decode(
    google_container_cluster.demo-cluster.master_auth[0].cluster_ca_certificate,
  )
  token = data.google_client_config.current.access_token
}

resource "kubernetes_service_account" "helm_account" {
  depends_on = [
    "google_container_cluster.demo-cluster",
  ]
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "helm_role_binding" {
  metadata {
    name = kubernetes_service_account.helm_account.metadata.0.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.helm_account.metadata.0.name
    namespace = "kube-system"
  }

  provisioner "local-exec" {
    command = "sleep 15"
  }
}


provider "helm" {
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:${var.helm_version}"
  service_account = kubernetes_service_account.helm_account.metadata.0.name

  kubernetes {
    host                   = google_container_cluster.demo-cluster.endpoint
    token                  = data.google_client_config.current.access_token
    client_certificate     = "${base64decode(google_container_cluster.demo-cluster.master_auth.0.client_certificate)}"
    client_key             = "${base64decode(google_container_cluster.demo-cluster.master_auth.0.client_key)}"
    cluster_ca_certificate = "${base64decode(google_container_cluster.demo-cluster.master_auth.0.cluster_ca_certificate)}"
  }
}

resource "kubernetes_namespace" "demo" {
  metadata {
    name = "demo"
  }
}

resource "helm_release" "vault" {
  name          = "vault"
  chart         = "./helm/vault-helm"
  namespace     = kubernetes_namespace.demo.metadata.0.name
}


