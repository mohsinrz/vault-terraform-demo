# Vault Terraform Demo

## Introduction

This demo will show you how to manage Vault using Terraform


## Installing Vault using Terraform

We will use Terraform to deploy Vault on Google Kubernetes Engine (GKE) using Terraform Helm provider.

1. Download and install [Terraform](https://www.terraform.io/).

2. Download, install, and configure the [Google Cloud SDK](https://cloud.google.com/sdk/). You will need
   to configure your default application credentials so Terraform can run.

3. Install the [kubernetes CLI](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (aka `kubectl`)

4. Run Terraform

    ```text
    $ terraform init
    $ terraform plan
    $ terraform apply
    ```

After these steps we will have a standalone Vault setup on GKE. We will verify the setup in the next section.

## Interacting with Vault

1. First make sure all Vault Pods are in running state (Note: Pods will not become ready untill Vault is initialized and unsealed):

   ```text
   $ gcloud container clusters get-credentials CLUSTER_NAME --region=REGION --project=PROJECT
   $ kubectl get all -n vault
   
   NAME          READY   STATUS    RESTARTS   AGE
   pod/vault-0   0/1     Running   0          39s

   NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)             AGE
   service/vault   ClusterIP   10.0.91.156   <none>        8200/TCP,8201/TCP   70s

   NAME                     READY   AGE
   statefulset.apps/vault   0/1     71s
   ```

2. Export environment variables:

   ```text
   # Make sure you're in the terraform/ directory
   # $ cd terraform/

   $ export VAULT_ADDR="https://$(terraform output vault_address)"
   ```
 
3. Initialize Vault:
 
   ```text
   $ kubectl exec POD_NAME -n vault -- vault operator init -key-shares=1 -key-threshold=1 -tls-skip-verify
   ```
   After initialization Vault will auto-unseal using Google KMS, to verify check vault status:
   
   ```text
   $ kubectl exec POD_NAME -n vault -- vault status -tls-skip-verify
   
   Key                      Value
   ---                      -----
   Recovery Seal Type       shamir
   Initialized              true
   Sealed                   false
   Total Recovery Shares    5
   Threshold                3
   Version                  1.2.4
   Cluster Name             vault-cluster-43c7e780
   Cluster ID               5d6f3b05-2f6d-f735-1f2c-49eaaa6933ac
   HA Enabled               true
   HA Cluster               https://10.0.94.9:8201
   HA Mode                  active
   ```

   ```
   $ kubectl get all -n vault

   NAME          READY   STATUS    RESTARTS   AGE
   pod/vault-0   1/1     Running   0          12m

   NAME            TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)             AGE
   service/vault   ClusterIP   10.0.91.156   <none>        8200/TCP,8201/TCP   12m

   NAME                     READY   AGE
   statefulset.apps/vault   1/1     12m
   ```

## Cleaning Up

   ```
   $ terraform destroy
   ```
 
