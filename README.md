# Terraform module for deploying EKS and sample applications

This solution deploys the [paulbouwer/hello-kubernetes](https://hub.docker.com/r/paulbouwer/hello-kubernetes) container into an AWS EKS cluster, while creating necessary VPC and security settings


## Justification:
**Networking and Security:**  
This module uses the official Terraform AWS VPC and EKS modules to provision a secure environment for kubernetes clusters. Worker nodes are placed in private subnets, making them inaccessible directly from the internet, while public subnets are used only for load balancer endpoints. A NAT Gateway is deployed to allow nodes to access the internet for updates and image pulls without exposing them publicly. Security groups and IAM roles are automatically managed by the modules to follow AWS and Kubernetes best practices, minimizing manual configuration and reducing the risk of misconfiguration.

**Kubernetes Deployment:**  
The Kubernetes resources (namespace, deployment, and service) are provisioned using the Terraform Kubernetes provider. The deployment runs a single replica of the container image (`paulbouwer/hello-kubernetes:1.7` in this example) and exposes it via a Kubernetes LoadBalancer service. An external Elastic Load Balancer (ELB) routes traffic to the private worker nodes, allowing for secure access to the application while keeping the application pods themselves in private subnets.

---

## AWS Authentication

Before running Terraform, you need to have proper authentication and access to AWS:

1. **Configure aws cli credentials**
   ```sh
   aws configure
   ```
   Or set the following environment variables:
   ```sh
   export AWS_ACCESS_KEY_ID=your-access-key-id
   export AWS_SECRET_ACCESS_KEY=your-secret-access-key
   export AWS_DEFAULT_REGION=ca-central-1
   ```

2. **Test your authentication:**
   ```sh
   aws sts get-caller-identity
   ```
   This should return your AWS account and user/role info.

---

## Step-by-step Instructions



### 1. Initialize Terraform

```sh
terraform init
```

### 2. Review and optionally customize variables

- Change `region`, `cluster_name`, etc. in `variables.tf`

### 3. Plan the deployment

```sh
terraform plan
```

### 4. Apply the deployment

```sh
terraform apply
```
- Approve when prompted.

**Provisioning will take several minutes.**

---

## Accessing the Kubernetes Cluster

After `terraform apply` completes:

### 1. Configure `kubectl` access

#### Option 1: Use the kubeconfig output from Terraform

```sh
terraform output -raw kubeconfig > kubeconfig.yaml
export KUBECONFIG=$PWD/kubeconfig.yaml
```

#### Option 2: Use AWS CLI to update your kubeconfig

```sh
aws eks update-kubeconfig --region <region> --name <cluster_name>
```
Replace `<region>` and `<cluster_name>` with your values, or use the Terraform outputs.

---

## Checking Your Deployment

### 2. Get the external URL for your app

```sh
terraform output service_external_hostname
```

Copy the hostname and open it in your browser.  
You should see the Hello Kubernetes page.

### 3. Inspect with kubectl

- Get all pods:
  ```sh
  kubectl get pods -A
  ```
- Get services:
  ```sh
  kubectl get svc -A
  ```
- Describe deployment:
  ```sh
  kubectl describe deployment hello-kubernetes
  ```
- View logs:
  ```sh
  kubectl logs deployment/hello-kubernetes
  ```

---


## Notes

- The default deployment uses one t3.medium node. Adjust in `main.tf` if needed.
- All networking, IAM, and security groups are created for you by the module vpc and eks.