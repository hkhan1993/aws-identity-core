variable "workload_accounts" {
  type = map(object({
    email      = string
    parent_key = string # References your child OU key (e.g., "Dev", "Prod")
    admin_user = string
    perm_set   = string
  }))
  description = "Map of application workload accounts to provision under the Workloads OU."
  default     = {}
}

variable workload_environment {
  type        = string
  description = "The environment for the workload accounts (e.g., 'Pre-Prod', 'Prod')."
  default     = "Pre-Prod"

validation {
    condition     = contains(["Pre-Prod", "Prod"], var.workload_environment)
    error_message = "Invalid workload environment. Must be either 'Pre-Prod' or 'Prod'."
  }

}