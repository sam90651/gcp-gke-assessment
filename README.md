# gcp-gke-assessment

Working URL: **https://www.web-lab-app.org** (also https://web-lab-app.org)

I built two zonal GKE clusters behind one global load balancer, with logs in BigQuery and Grafana on cluster 1. The page is a small Python app. The image is in Artifact Registry. A ConfigMap sets the message and version; a Secret holds an API key.

If the response says `Hello world from cluster 1` you landed on `gke-primary`. `Hello world from cluster 2` is `gke-secondary`.

| | |
| --- | --- |
| Project | `project-f0424c60-4a52-470d-b10` |
| Domain | `web-lab-app.org` (registered at IONOS, DNS in Cloud DNS zone `my-web-app`) |
| VPC | `gke-vpc` |
| Cluster 1 | `gke-primary`, `us-central1-a` — config cluster for Multi Cluster Ingress, Grafana |
| Cluster 2 | `gke-secondary`, `us-east1-b` — same app|
| IP | `web-a-ip` = `136.81.187.221` |
| Logs | BigQuery dataset `gke_logs` |

Grafana JSON is in `grafana/`. and grafana screenshots under `docs/screenshots/`.

## How traffic works

Cloud DNS points the name at the reserved IP. I applied MultiClusterIngress and MultiClusterService on gke-primary That creates one HTTPS load balancer with backends in both zones. Cluster 2 only runs the app Deployment and Service.

The load balancer terminates TLS with a Google-managed certificate.

Things I did not deploy (Cloud Armor, private nodes, NAT, mesh, Cloud SQL, etc.) are in [docs/design-decisions.md](docs/design-decisions.md). IAM roles I would use in production are in [docs/iam.md](docs/iam.md).

## Failover

On `gke-primary`:

```bash
kubectl -n web scale deploy/web-a --replicas=0
curl -s https://www.web-lab-app.org
# should show Hello world from cluster 2
kubectl -n web scale deploy/web-a --replicas=2
```

## Files

- `app/` — `server.py` and Dockerfile
- `k8s/` — app, HPA, MCS/MCI, Grafana
- `terraform/` — VPC, both clusters, Artifact Registry, Cloud DNS, log sinks
- `bigquery/queries.sql` — dashboard queries
- `docs/architecture.md` — request path
- `docs/troubleshooting.md` — issues I actually hit