# Vault Terraform Demo

## Introduction

This demo will show you how to manage Vault using Terraform


## Installing Vault using Terraform

We will use Terraform to deploy Vault on Google Kubernetes Engine (GKE) using Terraform Helm provider. The code will first deploy a cluster on GKE and then Vault will be deployed on the cluster using Helm provider.

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

After these steps we will have Vault running on GKE in dev mode. In dev mode everything is in memory and nothing is stored to disk so it's useful if you are experimenting with Vault. 

## Interacting with Vault

1. First make sure Vault Pods are in running state.

    ```text
    $ gcloud container clusters get-credentials CLUSTER_NAME --region=REGION --project=PROJECT
    $ kubectl get all -n demo

    NAME                                        READY   STATUS    RESTARTS   AGE
    pod/vault-0                                 1/1     Running   0          67s
    pod/vault-agent-injector-85bf45d6d7-4tfb5   1/1     Running   0          67s

    NAME                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
    service/vault                      ClusterIP   10.15.254.145   <none>        8200/TCP,8201/TCP   68s
    service/vault-agent-injector-svc   ClusterIP   10.15.251.162   <none>        443/TCP             68s

    NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/vault-agent-injector   1/1     1            1           68s

    NAME                                              DESIRED   CURRENT   READY   AGE
    replicaset.apps/vault-agent-injector-85bf45d6d7   1         1         1       68s

    NAME                     READY   AGE
    statefulset.apps/vault   1/1     68s
    ```
 
2. Check Vault status.

    ```
    $ kubectl exec -it vault-0 -n demo -- vault status

    Key             Value
    ---             -----
    Seal Type       shamir
    Initialized     true
    Sealed          false
    Total Shares    1
    Threshold       1
    Version         1.3.1
    Cluster Name    vault-cluster-c2db055c
    Cluster ID      b7104198-59cf-5337-9b1e-5ae2bcc97391
    HA Enabled      false
    ```

    As we are running Vault in dev mode so it's already initialized and unsealed.

## Vault Policies using Terraform

In this section we will use Terraform to create Vault policies. As a sample scenario we will create policies for two types of users `admin` and `provisioner`: 

`admin` is a type of user empowered with managing a Vault infrastructure for a team or organizations. Empowered with sudo, the Administrator is focused on configuring and maintaining the health of Vault cluster(s) as well as providing bespoke support to Vault users.

admin must be able to:

    Enable and manage auth methods broadly across Vault
    Enable and manage the key/value secrets engine at secret/ path
    Create and manage ACL policies broadly across Vault
    Read system health check

`provisioner` is a type of user or service that will be used by an automated tool (e.g. Terraform) to provision and configure a namespace within a Vault secrets engine for a new Vault user to access and write secrets.

provisioner must be able to:

    Enable and manage auth methods
    Enable and manage the key/value secrets engine at secret/ path
    Create and manage ACL policies

Additionaly we will also create two KV stores for two different teams (Dev-A and Dev-B) and add a policy so that the users of each team will have only `create` and `update` permissions in their respective KV stores.
   
1. Login to Vault using root token

    ```
    $ export VAULT_ADDR="https://127.0.0.1:8200"
    $ vault login
    ```

    Note: In dev mode the root token is "root"

2. Run Terraform:

    ```
    terraform init
    terraform plan
    terraform apply
    ```

## Verification steps

```
# enable the userpass auth method
$ vault auth enable userpass

# create an admin user
$ vault write auth/userpass/users/mohsin \
    password=test123 \
    policies=admin-policy
 
# create a user for team Dev-A
$ vault write auth/userpass/users/usera1 \
    password=test123 \
    policies=deva-policy

# Login with user
$ vault login --tls-skip-verify -method=userpass username=usera1 password=test123

# Create secret
$ vault kv put --tls-skip-verify dev-A/mysecret hello=world

# Try to delete the secret which should fail with user (usera1)
$ vault kv delete --tls-skip-verify dev-A/mysecret

# Try to create secret in other team's KV store which should also fail as per policy
$ vault kv put --tls-skip-verify dev-B/mysecret hello=world


```

## Cleaning Up

   ```
   $ terraform destroy
   ```
 
