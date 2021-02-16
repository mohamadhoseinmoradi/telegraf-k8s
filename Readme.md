to get informed about the service design , traffic flow and the basic functionalities of this service please see the [wiki](https://git.cafebazaar.ir/network/k8s-manifests/telegraf-k8s/-/wikis/telegraf-k8s) .

# Dockerfile

the default telegraf image does not contain MTR Package which is a nessecary tool for our measurements . to install the MTR package into the 
container image we used a Dockerfile and installed MTR package into it .
after the first pilot , we encountered a huge zombie processes caused by "Exec MTR" module and made the k8s worker nodes to operate faulty and disrupt some services like CNI and etc.
so we had to use a PID 1 to fulfil the lack of init in container and we prefered to use "Tini" as the PID 1 to control zombie reaping caused by "Exec MTR".

to rebuild your custom image you can also use `registry.cafebazaar.ir` as a local image repository intead of docker hub.

# Secret

for credentials , ingress authentication and ingress TLS

influxDB secrets:
if you are using influxdb as the output plugin to store and process metrics for this secrets file use :
`kubectl apply -f telegraf-influxdb-secret.yml` or `kubectl create secret generic telegraf-influxdb-secret --from-file=secret.yml`
verify the secrets with ==> `kubectl get secrets` .

ingress basic authentication:
install `apache2-utils` and create a username and password file called auth using htpasswd ==> `htpasswd -C auth telegraf`
then create a secret called telegraf-basicauth from that file ==> `kubectl create secret generic telegraf-basicauth --from-file=auth`
verify the secrets with ==> `kubectl get secrets` .

ingress TLS:
create a secret type TLS from your certificates for using in ingress: 
`kubectl create secret tls "your-desired-name" --cert "your-cert-or-chain" --key "your-cert-private-key"`
you can also use `ClusterIssuer` for certificates.
verify the secrets with ==> `kubectl get secrets`

# configmap

we used some input plugins specific to our needs like ping,http-respone,exec_mtr . we used prometheus as the output plugin and then used 
histogram aggregator plugin to create buckets for out ping measurements for service levels .
for configmap , update the configmap file according to your needs (destinations,hostname,prom metric-path and ...) and attach the configmap to the pod while deploying it .
to create a configmap resource use:
`kubectl create configmap "configmap_name" --from-file=telegraf.conf`

# services
we prefered to use the ClusterIP type of the service and then use ingress to route the traffic to backends . we also could use the NodePort service type
to expose the metrics . the shortcomings of this service type was that the NodePort type in our k8s cluster only listens on private ips of the 
worker nodes and are whitlisted by some specific source ip addresses . the other issue was that we could not specify a single worker ip address
because of the SPOF side of the issue . eventually we decided to expose the service via CluserIP and then ingress for exposing .
to create a service resource use:
`kubectl apply -f telegraf-svc-cip.yml`

# deployment
to deploy a telegraf pod on k8s you can use `kubectl apply -f telegraf-deployment.yml`



# ingress

to expose metrics from pods we have to create an ingress resource with basic authentication and TLS enabled .
for basic authentication and TLS you have to use some annotations which are present in the ingress file sample .
then we create backends for each pod and route the traffic to desired backend pods using ingress(nginx) rules .
we use `ntw-k8s-telegraf.net.roo.cloud` domain in ingress and for this project .
to create an ingress resource use:
`kubectl apply -f teleraf-ingress.yml`