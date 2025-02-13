provider "azurerm" {
  features {}
}

provider "azuredevops" {
  org_service_url       = var.org_url
  personal_access_token = var.pat_token
}

# Reference an existing Azure DevOps project
data "azuredevops_project" "existing_project" {
  name = var.project_name
}

# Reference an existing Azure DevOps repository
data "azuredevops_git_repository" "existing_repo" {
  project_id = data.azuredevops_project.existing_project.id
  name       = "fabric"
}

#   First Pipeline - Capacity Pipeline
resource "azuredevops_build_definition" "capacity_pipeline" {
  project_id = data.azuredevops_project.existing_project.id
  name       = "capacity-pipeline"
  path       = "\\"

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.existing_repo.id
    branch_name = "main"
    yml_path    = "pipelines/capacity-pipeline.yaml"
  }

  ci_trigger {
    use_yaml = false
  }
}

#   Second Pipeline - Workspace Pipeline (Triggered by Capacity)
resource "azuredevops_build_definition" "workspace_pipeline" {
  project_id = data.azuredevops_project.existing_project.id
  name       = "workspace-pipeline"
  path       = "\\"

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.existing_repo.id
    branch_name = "main"
    yml_path    = "pipelines/workspace-pipeline.yaml"
  }

  ci_trigger {
    use_yaml = true
  }

  # Automatically triggers after Capacity Pipeline completes
  build_completion_trigger {
    build_definition_id = azuredevops_build_definition.capacity_pipeline.id
    branch_filter {
      include = ["main"]
    }
  }
}

