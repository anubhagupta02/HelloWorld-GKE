Here are the step-by-step instructions to deploy your Spring Boot application to Google Cloud GKE. I've created a Dockerfile and deployment.yaml for you in the project root. Make sure to replace YOUR_PROJECT_ID in deployment.yaml with your actual Google Cloud Project ID.
Prerequisites
Google Cloud account with billing enabled.
gcloud CLI installed and authenticated (gcloud auth login).
kubectl installed.
Docker installed.
A GKE cluster (create one if needed).

Step 1: Build the Application JAR
First, build the JAR file for your Spring Boot app.
* cd /Users/anubha/IdeaProjects/HelloWorld
* ./gradlew bootJar
* 
Step 2: Build the Docker Image
Use the provided Dockerfile to build the Docker image.
* docker build -t gcr.io/YOUR_PROJECT_ID/helloworld:latest .
With compatible platform 
* docker build --platform linux/amd64 -t gcr.io/gen-lang-client-0016379173/helloworld:latest .

Step 3: Push the Image to Google Container Registry (GCR)
Authenticate Docker with GCR and push the image.
* gcloud auth configure-docker
* docker push gcr.io/YOUR_PROJECT_ID/helloworld:latest

Step 4: Create or Select a GKE Cluster
If you don't have a GKE cluster, create one: 
first enable the Kubernetes Engine API:
* gcloud services enable container.googleapis.com
Check if there is any cluster available:
* gcloud container clusters list --project=gen-lang-client-0016379173
If you don't have a GKE cluster, create a new cluster:
* gcloud container clusters create helloworld-cluster --zone us-central1-a --num-nodes=3

Install the gke-gcloud-auth-plugin to authenticate kubectl with GKE:
* gcloud components install gke-gcloud-auth-plugin

Then, get credentials for kubectl:
* 
* gcloud container clusters get-credentials helloworld-cluster --zone us-central1-a

Step 5: Deploy to GKE
Use kubectl to apply the deployment and service.
* kubectl apply -f deployment.yaml

Step 6: Check the Deployment
Monitor the deployment status:
* kubectl get pods
* kubectl get services

Once the LoadBalancer service is ready, get the external IP:
* kubectl get service helloworld-service

* Access your app at http://EXTERNAL_IP/test.

* Additional Notes
The deployment uses 3 replicas for high availability.
The service is of type LoadBalancer, which provisions an external IP.
For production, consider using Ingress for better routing and SSL.
Clean up resources when done: kubectl delete -f deployment.yaml and gcloud container clusters delete helloworld-cluster.

rollout the new image to GKE:
Rebuild for x86-64 (linux/amd64)
docker build --platform linux/amd64 -t gcr.io/gen-lang-client-0016379173/helloworld:latest .
# Push to GCR
docker push gcr.io/gen-lang-client-0016379173/helloworld:latest
# Then rollout the new image to GKE:
kubectl set image deployment/helloworld-deployment helloworld=gcr.io/gen-lang-client-0016379173/helloworld:latest

# Force restart pods to pull the new image
kubectl rollout restart deployment helloworld-deployment