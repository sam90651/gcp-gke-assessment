variable "project_id" {
  description = "Existing lab project. Display name is My First Project."
  type        = string
  default     = "project-f0424c60-4a52-470d-b10"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "dev_group" {
  description = "Google Group email for developers. Empty skips the binding."
  type        = string
  default     = ""
}

variable "ops_group" {
  description = "Google Group email for ops. Empty skips the binding."
  type        = string
  default     = ""
}

variable "sre_group" {
  description = "Google Group email for SRE. Empty skips the binding."
  type        = string
  default     = ""
}

variable "create_cicd_sa" {
  description = "Create the cicd-deployer service account and its project roles."
  type        = bool
  default     = false
}