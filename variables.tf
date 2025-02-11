# Example variables

variable "org_url" {
  description = "The Azure DevOps organization URL"
  type        = string
}

variable "pat_token" {
  description = "The Azure DevOps personal access token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "The name of the Azure DevOps project"
  type        = string
}



