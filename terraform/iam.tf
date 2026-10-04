# Design only until group emails are set. See docs/iam.md.
# Empty defaults create no IAM bindings.

locals {
  persona_roles = {
    dev = {
      member = var.dev_group == "" ? "" : "group:${var.dev_group}"
      roles = [
        "roles/container.developer",
        "roles/logging.viewer",
        "roles/artifactregistry.writer",
      ]
    }
    ops = {
      member = var.ops_group == "" ? "" : "group:${var.ops_group}"
      roles = [
        "roles/container.admin",
        "roles/compute.networkAdmin",
        "roles/logging.configWriter",
        "roles/iam.serviceAccountUser",
      ]
    }
    sre = {
      member = var.sre_group == "" ? "" : "group:${var.sre_group}"
      roles = [
        "roles/container.viewer",
        "roles/logging.viewer",
        "roles/monitoring.editor",
        "roles/bigquery.dataViewer",
        "roles/bigquery.jobUser",
        "roles/cloudtrace.user",
      ]
    }
  }

  persona_bindings = {
    for binding in flatten([
      for persona, cfg in local.persona_roles : [
        for role in cfg.roles : {
          key    = "${persona}-${replace(role, "/", "-")}"
          member = cfg.member
          role   = role
        }
      ] if cfg.member != ""
    ]) : binding.key => binding
  }
}

resource "google_project_iam_member" "persona" {
  for_each = local.persona_bindings

  project = var.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_service_account" "cicd" {
  count = var.create_cicd_sa ? 1 : 0

  account_id   = "cicd-deployer"
  display_name = "CI/CD deployer"
}

resource "google_project_iam_member" "cicd" {
  for_each = var.create_cicd_sa ? toset([
    "roles/container.developer",
    "roles/artifactregistry.writer",
  ]) : toset([])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.cicd[0].email}"
}