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

variable "target_repo_name" {
  description = "The name of the target repository"
  type        = string
}

variable "location" {
  description = "The Azure location"
  type        = string
}


variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "source_repo_url" {
  description = "URL of the source repository to import"
  type        = string
}

variable "prefix" {
  description = "Prefix for naming convention"
  type        = string
}
