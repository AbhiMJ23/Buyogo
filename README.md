1. Dockerfile

Initially made use of 3.8-slim image and with the help of docker scout I made the image analysis and it showed that this image was having some kind of critical vulnerabilities.
So I have upgraded to the 3.12-slim image which was free from critical vulnerabilities. Used slim because the application was light and would not require the bigger images.
Also I have created a user and a user group in the dockerfile itself as by default docker will make use of root user which is not a good practice.
And instead of multiple run commands, I have combined all of them and hence resulting in the reduction of the layers of the image.



2.Pushing the image to Dockerhub Registry

Creating a Dockerfile --> Building the image - docker build -t Dockerhub_username/repo_name:tag . --> Docker login - username and password --> Pushing the image- docker push image_name


3.Flask Kubernetes

Created a namespace Flask in the cluster. Deployed all the resources like Deployment, Replicaset, Configmaps, Service-Nodeport, Secrets, HPA in this namespace.


4.MongoDB Kubernetes

Created a namespace MongoDB in the cluster. Deployed all the resources like Deployment, Statefulset, Configmaps, Service-Headless, Secrets in this namespace.
Stateful set because of the Stable network, all pods will be having their own Volumes, Ease of service discovery as they will be having the same names even after the recreation.
Can also make use of Taints and Tolerations here in order to make sure that The pods are getting deployed in the required nodes.
Standard DNS - pod_name.service_name.namespace.svc.cluster.local. This is how the DNS resolution works. 
Also created an user , password, and an Initial database in the deployment itself and hence enabling the authentication.
Made use of headless service, as each pods in the stateful set will be making use of their own DNS records. If we use cluster IP , each pod wont be getting their own DNS and hence making the pod intercommunication more difficult as their cluster ip keep on changing.

5.DNS Resolution between two pods

1. Pod and Headless service creation
2. Headless service makes sure that each pod will be getting their own DNS record
3. Configuration of the DNS by the CoreDNS or Kube-DNS
4. Communication - Request POD A --> DNS of POD B(FQDN - Fully qualified Domain Name- podb.service_name.namespace.svc.cluster.local) --> DNS Resolution of the POD BY by DNS service --> Returning of the IP pf POD B --> Sending of the request to POD B from POD B.

Pods need to communicate between each other because in Statefulset  - Secondary pods are being created from the primary pod.

Example Creating of two 3 pods from stateful set.(Stateful Set name - mongo)
1. Initially mongo-0. It will be created fom the reference of Stateful.yaml file. This'll b called as primary pod.
2. Now mongo-1 will be created for the reference of mongo-0. This pod will be having the same data as that of the mongo-0 pod. So all the data form the mongo-0 will get replicated in mongo-1 pod. So in order to have the replication the mongo-1 pod needs pod connect with the mongo-0 pod and will  make us of DNS resolution
3. mongo-2 will also follow the same procedure as above.



6. SET UP

Made use of nodeport service for Flask as it needed the connection from outside the cluster. It should be made accessible from the internet.
Made use of headless service as it should be only be made accessible within the cluster.
Created two name spaces for Flask and Database to avoid the confusion. Treated user name and password as secrets. 


7. Resource Requests and Limits.

With the help of these we can restrict the abrupt behaviour of a pod within a namespace. Suppose we have specified 10Gi as memory for a particular namespace with the help o a resource quota. Now 5 pods are mad to get deployed in the namespace. Now POD1 starts to behave abruptly having huge memory leaks due to an error a bug in the code an starts using 8Gi of memory.
This we forcefully terminate the other existing pos due to OOM Killed. In order to restrict that..a limit has to be set in order to decrease the blast radius.

We can d it by specifying the resource requests and limits in the deployment file itself



8. Autscaling

Made use of Locust as a load tester. Initially i sent the load bt autoscaling was not happening and most of my rquest were getig failed as no response was their due to overload as the hpa was unable to get the metrics of the cpu utilization.
Then I checked the list of pods present in the kube-system namespace. I found out that metrics-server pod was not present. Then I downloaded the respective metrics server in the kube-system namespace. Afterwards it was able to scarpe the metric of the hpa.Then I tried the same..autoscaling was working. 







