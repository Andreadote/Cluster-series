EKS CLUSTER WITH CUSTOM VPC
Read! EKS: Requirements
VPC:

Must have a minimun of 2-4 subnets in differentAZs 2 public, 2 private - VPC must be tagged
Subnet:

Subnets have to be tagged for alb
tags = { Name = "public" "kubernetes.io/role/elb" = "1" "kubernete.io/cluster/demo" = "owned" or "shared" }

VPC needs DNS host name support
VPC needs DNS resolution

=======================================================================================================================================================================================

Cluster IAM roles:
EKS makes api calls to other services, Iam with AmazonEKSClusterPolicy is attached.
The role needs to have the principal as eks.amazonaws.com service to assume it.
resource "aws_iam_role" "demo" { name = "eks-cluster-demo"

assume_role_policy = <<POLICY { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Principal": { "Service": "eks.amazonaws.com" }, "Action": "sts:AssumeRole" } ] } POLICY } 
2 other policies need to be attached to this role.
The policies must be amazon managed policies and not customer managed policies.
resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" { policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy" role = aws_iam_role.demo.name }

resource "aws_iam_role_policy_attachment" "main-cluster-AmazonEKSServicePolicy" { policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy" role = aws_iam_role.demo.name } 

=======================================================================================================================================================================================

Node groups:
Role for creating nodes with permissions policies attached to the role MUST be amazon managed policies. The principal to assume the role must be ec2.amazonaws.com as a service.
Policies must be attached to the role.
resource "aws_iam_role" "nodes" { name = "eks-nodes-demo"


assume_role_policy = <<POLICY { "Version": "2012-10-17", "Statement": [ { "Effect": "Allow", "Principal": { "Service": "ec2.amazonaws.com" }, "Action": "sts:AssumeRole" } ] } POLICY }

esource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" { policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy" role = aws_iam_role.nodes.name }

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" { policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" role = aws_iam_role.nodes.name }

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" { policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" role = aws_iam_role.nodes.name }

resource "aws_iam_role_policy_attachment" "main-node-AmazonEC2FullAccess" { policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess" role = aws_iam_role.nodes.name } 
The credentials used to provision the EKS are the authorized credentials to modify or edit the configMap. aws-auth cm

=======================================================================================================================================================================================

# docker.yml
---
- hosts: localhost
  become: true

  tasks:
    - block:
        - name: Install aptitude using apt
          apt: name=aptitude state=latest update_cache=yes force_apt_get=yes

        - name: Install required system packages
          apt: name={{ item }} state=latest update_cache=yes
          loop: [ 'apt-transport-https', 'ca-certificates', 'curl', 'software-properties-common', 'python3-pip', 'virtualenv', 'python3-setuptools']

        - name: Add Docker GPG apt Key
          apt_key:
             url: https://download.docker.com/linux/ubuntu/gpg
             state: present

        - name: Add Docker Repository
          apt_repository:
             repo: deb https://download.docker.com/linux/ubuntu bionic stable
             state: present

        - name: Update apt and install docker-ce
          apt: update_cache=yes name=docker-ce state=latest

        - name: Install Docker Module for Python
          pip:
            name: docker

        - name: Docker group
          shell: |
                 sudo groupadd docker
                 sudo usermod -aG docker $USER
                 sudo systemctl enable docker

      rescue:
        - name: You need to recover
          debug:
            msg: "It looks like PIP is not installed. You will need to install it"

        - name: Recovery block
          shell: |
            sudo apt update
            sudo apt install python3-pip

=======================================================================================================================================================================================
# Create node group in the created vpc using created node role
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = ""

  subnet_ids = []

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "devops"
  }
  # This tags are important if we are going to use an auto-scaler
  tags = {
    "k8s.io/cluster-autoscaler/demo"    = "owned"
    "k8s.io/cluster-autoscaler/enabled" = true
  }
}


=======================================================================================================================================================================================

# Data block to read local vpc terraform.tfstate file

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = ""
  }
}

=======================================================================================================================================================================================

Creating and adding users to EKS:
1. Create a clusterrole and clussterrolebinding
    - reader
    - deploy,cm,pods,secrets,services = resources
    - verbs - get,list,watch
2. Go to aws IAM, create a role and policies to be attached to a group.
3. Create a group called developer and attache the role to the group.
4. Create a user called developer1 and add the user to the developer group.
5. Generate IAM credentials for the user (secret/access) = aws configure --profile developer1
- Update kubeconfig file => 
aws eks update-kubeconfig --region us-east-1 --name demo --profile developer1

6. Modify the aws-auth cm in the kube-system ns.
  mapUsers: |
      - userarn: arn:aws:iam::<>:user/developer1
        username: developer1
        groups:
         - reader

  kubectl auth can-i get *

  =======================================================================================================================================================================================

  