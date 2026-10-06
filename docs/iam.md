# IAM (design)

The ask was for a separate Dev / Ops / SRE / CI roles. I did not create those groups. Below is how I would split it in production.


| Who | Roles |
| --- | --- |
| Dev | `container.developer`, `logging.viewer`, `artifactregistry.writer`, plus a Kubernetes Role in namespace `web` only |
| Ops | `container.admin`, `compute.networkAdmin`, `logging.configWriter`, `iam.serviceAccountUser` |
| SRE | `container.viewer`, `logging.viewer`, `monitoring.editor`, `bigquery.dataViewer`, `bigquery.jobUser` |
