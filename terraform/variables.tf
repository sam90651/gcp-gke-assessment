variable "project_id" {
  description = "Existing lab project."
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

variable "region_east" {
  type    = string
  default = "us-east1"
}

variable "zone_east" {
  type    = string
  default = "us-east1-b"
}

