#install ArgoCD in k8s
kubectl create namespace argocd 
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# access ArgoCD UI
kubectl get svc -n argocd
kubectl port-forward svc/argocd-server 8080:443 -n argocd

#login with admin user and below token (as in documentation):
# Log in with the admin user and initial password:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo

#You can change and delete the initial password in the ArgoCD UI.
#Switch to the ArgoCD namespace:

kubectl config set-context --current --namespace=argocd

## Modify the application.yaml with your git repository and apply to the cluster.

kubectl apply -f application.yaml

#Apply the secret in your cluster. In place of password, use token
kubectl apply -f secrets.yaml

#7. Push your manifest files to your Git repository:

#  a) Push deployment and service to your repository deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: andreadote/spring-boot-mongo:latest
        ports:
        - containerPort: 8080

        # service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
    - port: 8080
      protocol: TCP
      targetPort: 8080


 # Application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp-argo-application
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/Andreadote/Argocd.git
    targetRevision: HEAD
    path: dev
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp
syncPolicy:
  syncOptions:
    CreateNamespace: true
  automated:
    selfHeal: true
    prune: true


    # secret.yaml
 apiVersion: v1
kind: Secret
metadata:
  name: argocd-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/Andreadote/Argocd.git
  password: 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
  username: andreadote
   

