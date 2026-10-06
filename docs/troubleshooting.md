# Troubleshooting

## ACCESS_TOKEN_SCOPE_INSUFFICIENT

I deployed Grafana on gke-primary and added BigQuery as a data source for dataset gke_logs. When I tried saving and testing on the Grafana dashboard, it failed with 403 ACCESS_TOKEN_SCOPE_INSUFFICIENT.IAM looked fine the node service account already had roles/bigquery.dataViewer and roles/bigquery.jobUser.

The token was still missing BigQuery. GKE default node pools only allow logging, monitoring, and storage. Those OAuth scopes are a second gate on the VM, and they cannot be edited in place. I created pool-2 with scopes cloud-platform, then moved the pods, and deleted default-pool. after testing it worked after that.

Fix: node pool with `scopes cloud-platform`, then delete `default-pool`.

## Empty BigQuery plugin page

while installing bigquery plugin on grafana i was getting origin error, after some research understood plugin 3.4.2 needs Grafana >= 11.6.11. The pod was 11.6.0. so I moved the image to `grafana/grafana:latest`.

## Ingress: no IP, then 503, then 404

On this cluster, `ingressClassName: gce` was ignored until I also set annotation `kubernetes.io/ingress.class: gce`. Empty address and 503 meant no forwarding rule yet. 404 from Google meant the URL map existed but `/` was not routed. It started working after a few minutes.

## Insufficient cpu / Pending on one e2-medium

When I rolled the Artifact Registry image, the second web-a pod stuck in Pending. kubectl describe said 0/1 nodes are available: 1 Insufficient cpu. The node is one e2-medium (~940m allocatable). kube-system and Grafana were already sitting on most of that, and two new replicas at 50m each would not fit next to the old pods.

I dropped the request to 20m, set HPA minReplicas to 1 so it would not scale me back up, scaled the Deployment to 1, and deleted the leftover Pending pods. After that replica was Running I scaled back to 2. Both came up. HPA is still 2–4.