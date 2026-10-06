# Architecture

Two GKE clusters share VPC `gke-vpc`. The public name is `web-lab-app.org`. A global HTTPS load balancer sends traffic to pods in `us-central1-a` and `us-east1-b`.

```
browser
  -> Cloud DNS (zone my-web-app)
  -> 136.81.187.221 (address web-a-ip)
  -> Google HTTPS proxy 
  -> backend / NEGs
        |-- us-central1-a  web-a on gke-primary
        |-- us-east1-b     web-a on gke-secondary

container logs -> Cloud Logging sinks -> BigQuery gke_logs
                                       -> Grafana (only on gke-primary)
```

gke-primary is the config cluster. I applied `MultiClusterIngress` and `MultiClusterService` there (k8s/web-a-mci.yaml, k8s/web-a-mcs.yaml). The ingress controller reads those objects and creates one global HTTPS load balancer with NEGs in both zones. Cluster 2 only runs the app Deployment and Service.

If pods on cluster 1 are down, health checks fail and the LB uses cluster 2. 

## DNS / TLS

I registered the domain at IONOS and created Cloud DNS zone `my-web-app`. Apex and `www` are A records to `136.81.187.221`. IONOS nameservers were switched to Google nameservers. 

The load balancer terminates HTTPS with a Google-managed certificate for `web-lab-app.org` and `www.web-lab-app.org`

## Network

- VPC: `gke-vpc`
- `gke-primary-subnet` in `us-central1` — `10.10.0.0/22`
- `gke-secondary-subnet` in `us-east1` — `10.11.0.0/22`
- Pod secondary ranges in Terraform: `10.20.0.0/16` and `10.21.0.0/16`
- Private Google Access on

## Identity

Workload Identity is on for both clusters.Fleet registration required that. Without it, gke-secondary could not join and Multi Cluster Ingress would not run.

Nodes still authenticate as the Compute Engine default service account. That account has artifactregistry.reader so kubelet can pull web-a:1.0.0, and bigquery.dataViewer / bigquery.jobUser so Grafana can query logs. 

## Observability
GKE writes container and cluster logs to Cloud Logging. Two sinks copy them into BigQuery dataset gke_logs (us-central1):

gke-app-logs — k8s_container in namespace web on both clusters
gke-cluster-logs — node, pod, and control-plane events on both clusters

Grafana is self-hosted on gke-primary only.It is not on the public URL. I open it with kubectl port-forward The BigQuery plugin (grafana-bigquery-datasource) runs the queries in bigquery/queries.sql. Dashboard JSON is in grafana folder.

## App

Namespace `web` on both clusters. Image comes from Artifact Registry (`web-a/web-a:1.0.0`). ConfigMap holds the hello message and `1.0.0`. Secret holds `api-key`. Each pod requests `20m` CPU / `64Mi` so two replicas fit on one `e2-medium`. HPA 2–4 at 50% CPU. Grafana is in `default` on cluster 1 only, with no PVC. The node service account can pull from the repo (`artifactregistry.reader`).
