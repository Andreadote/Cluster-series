
 A) PHASE 1: Infrastructure provisioning / configuration
=======================================================
a) Terraform security:
  - Don't commit the .tfstate file
  - Configure a backend { state locking / remote state storage}
  - Backup state file / versioning
  - Use one state per environment
  - Execute terraform in automated builds
  - Use variables
  - Use modules
  - Create IAM roles and attach them to resources.
  - Store secrets / sensitive data
b) Ansible security: configuration
  - Secrets / use ansible secret manager- ansible vault
  - don't expose sensitive data in ansible outputs
  - avoid single target login names - avoid using generic names eg admin
c) Host hardening:
   - Choice of your operating system
   - Non essential processes - /etc/init.d
   - Host based firewalling (SG, ACL, NACL)
   - Allow /open required ports
   - Default ports -Jenkins/8080 - reconfigure default port / use custom ports Jenkins /8031/8045
d) Private subnets: closing our resources to the public
   - run all our resources in private subnets
   - configure loadBalancer to direct or control traffic from the interrnet to resources
   - resources only accept traffic from the loadBalancer security groups
   - configure a single point of entry into our cluster / Infrastructure - bastion host / authentication /authorization
   - only authenticated and authorised users are able to access the cluster with least privileges / only required permissions


B) PHASE 2: Build time security - create/build software / development life cycle
================================================================================
a) Git / Git Hub DVCS:
  - make clean, single purpose commits. Keep commits small and focused for ease of roll back and tracking
  - write meaningful messages
  - commit early and commit often
  - Dont alter merged commits
  - Dont commit generated files
  - Use private repos - authentication/authorisation
  - Create organisations /provide credentials for users
  - Enabling watchers
  - Enable log events
  - prevent direct push to master / before merging use pull requests
b) Dealing with images:
  - Use official images
  - Choice of the base image - lightweight / minimum dependencies
  - Scan images to ensure applications do not have any known unpatched critical or major vulnerabilities 
     -> snyk, whitesource, trivy

           https://aquasecurity.github.io/trivy/v0.19.2/getting-started/installation/

  - checks the base image/ and packages against a database that tracks vulnerable packages
  - Privacy concern: find out where the logs /data generated from the scanning solutions is stored. Ensure that the 
    data is secure.
  - Images being delivered from the image registry must be checked for compromise.
  - Ensure that access to registry is controlled
  - When buiding containers, minimize software / packages that make up the base image./ only absolutely neccesary
    for the application to run.
    -> use alpine minimal images / distroless images- slimmed down linux distribution image
  - scan images after the build.

C) PHASE 3: Deploy time security
=========================================================================================
a) Host hardening:
  - Choice of your operating system
   - Non essential processes - /etc/init.d
   - Host based firewalling (SG, ACL, NACL)
   - Allow /open required ports
   - Default ports -Jenkins/8080 - reconfigure default port / use custom ports Jenkins /8031/8045

b) Cluster hardening:
  - review k8s cluster configurations to ensure that it aligns with security best practices
  - Build a trust model for various components of the cluster. Have a framework where you review a threat profile
    and define a mechanism to respond to that threat profile.
  - Secure K8S etcd / api server- use strong credentials, public key Infrastructure, TLS for data in transit encryption
  - configure SG/firewalls to control access
  - Encrypt K8s secrets at rest
  - Rotate credentials frequently
  >RBAC
   - Roles/rolebindings, ClusterRoles/ClusterRole binding
   - Use namespaces for isolation
   - Restricting cloud metadata API access
   - Enable auditing
   - Restrict access to alpha of beta features
   - Upgrade k8s frequently
   - Use managed K8s service

c) Secret management:
  - etcd to store secrets / encrypted
  - secret management service
    -> avoid secret sprawl - have a centralised secret manager
    -> Data encryption rest/transit
    -> use automated secret rotation
    -> enable log auditing
    -> Use CA- Certificate Authority
d) CI/CD Pipeline:
  - scan images be registry scanning service.
  - Scan the image after the build 
  - Inline scanning - SonarQube/ code quality/vulnerabilities
   -> Secure CI/CD
     - Zero trust policy for CI/CD environment
     - Secure secrets- passwords, access tokens, ssh keys, encryption keys
     - Access control - 2 factor authentication enabled
     - Auditing / monitoring - excessive access, access deprecation
     - organization policies- call out access requirements, separation of responsibilities, secret management, logging
     and monitoring requirements, audit policies

D) PHASE 4: Run time security
===========================================
a) Pod Security Policies (PSPs):
  - Pod security polocies
  - PSP capabilities
  - Pod Security context
  - Limitations of PSP
b) Process and Application monitoring:
  - Logging - stream logs to an external location with append-only access from within the cluster. This ensures
  that your logs will not be tampered with even in the case of a total cluster compromise.
  -APM - NewRelic, Prometheus / Grafana / ELK
C) Network security control:
    -> Observability: - the ability to derive actionable insights about the state of K8s from the metrics collected
       - Network Traffic visibility
       - DNS activity logs
       - Application Traffic visibility - response codes, rare or known malicious HTTP HEADERS
       - K8S activity logs - denied logs, SA creation/modification, ns creation/modification
       - machine language and anomaly detection - deviation from derived patterns from data over a period of time.
       - enterprise security controls- leverage the data collected from observability strategy to build reports 
       needed to help with compliance standards e.g HIPPA, PCI
 d) Threat defence:
   - ability to look at malicious activity in the cluster and then defend the cluster from it.
      -> exploit insecure configurations
      -> exploit vulnerability in the application traffic
      -> vulnerability in the code
  - consider both intrusion detection and intrusion prevention
  -> the key to intrusion detection is OBSERVABILITY.
e) Security framework:
   https://attack.mitre.org/matrices/enterprise/cloud/aws/

https://www.microsoft.com/
security/blog/2021/03/23/secure-containerized-environments-with-updated-threatmatrix-for-kubernetes/?_lrsc=2215f5af-27b7-4d0b-abd2-ad3fbd998797

 =======================================================================================================================================================================================

 #1. data.tf

data "aws_eks_cluster" "my-cluster" {
  name = "demo"
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

# IAM Policy for OIDC provider

data "aws_iam_policy_document" "test_oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:aws-test"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

#2. oidc.tf

resource "aws_iam_role" "test_oidc" {
  assume_role_policy = data.aws_iam_policy_document.test_oidc_assume_role_policy.json
  name               = "test-oidc"
}

resource "aws_iam_policy" "test-policy" {
  name = "test-policy"

  policy = jsonencode({
    Statement = [{
      Action = [
        "s3:List*"
      ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.test_oidc.name
  policy_arn = aws_iam_policy.test-policy.arn
}

#3. pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: aws-cli
  namespace: default
spec:
  serviceAccountName: aws-test
  containers:
    - name: aws-cli
      image: amazon/aws-cli
      command: [ "/bin/bash", "-c", "--" ]
      args: [ "while true; do sleep 30; done;" ]
  tolerations:
    - operator: Exists
      effect: NoSchedule

#4. sa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-test
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: <>



