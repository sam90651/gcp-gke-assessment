# Design decisions

The assessment asked for two regions, a mesh, Cloud Armor, private nodes, and more. Guidance I got back was to implement the core path, and write down the rest instead of deploying every paid piece. That is what I did.

## Built

**Zonal clusters, not regional.** I tried a regional cluster in the console and hit CPU / IP quota. I kept `gke-primary` as one `e2-medium` in `us-central1-a`. `gke-secondary` is the same shape in `us-east1-b`. GKE’s free-tier note covers the management fee for one zonal cluster; the second cluster still bills a management fee plus its node.

**Public nodes.** Nodes have external IPs so they can pull images without Cloud NAT. NAT is only for outbound from private VMs. In production I would use private nodes and NAT.

**Same VPC.** Both clusters are on `gke-vpc`. Cluster 2 is subnet `gke-secondary-subnet` in `us-east1`.

**DNS and cert.** Domain is `web-lab-app.org`. Cloud DNS holds the A records. TLS is Google-managed.

**Multi Cluster Ingress.** YAML is on `gke-primary` only. Cluster 2 runs the Deployment and Service.

**App image in Artifact Registry.** Image is `us-central1-docker.pkg.dev/project-f0424c60-4a52-470d-b10/web-a/web-a:1.0.0`. ConfigMap holds the hello message and version. Secret holds the API key. CPU request is `20m` so two replicas fit on one `e2-medium` next to system pods (and Grafana on cluster 1).

**HPA** is applied (2–4, 50% CPU).

**Grafana / BigQuery.** Error rate and events panels are real logs. Latency and CPU/memory panels were filled from sample JSON lines I wrote with a busybox pod, because this app does not log those fields.

## Not deployed

- **Cloud Armor** : would attach to the existing backend service.
- **Service mesh** : sidecars on the web-a pods for east-west mTLS..
- **Private cluster + Cloud NAT** : In production space we would do a private cluster with cloud NAT for egress traffic.
- **Binary Authorization, Cloud SQL, Memorystore** : private IP in gke-vpc if the app grew a database or a cache.

## Terraform

`terraform/` can recreate the VPC, both clusters, the static IP, Cloud DNS records, BigQuery, and sinks. Fleet membership and MCI enablement were done with gcloud.
This lab keeps state local. In production the backend would be a GCS bucket so terraform.tfstate is remote, versioned, and locked. I would not commit the state file.