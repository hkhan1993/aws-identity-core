# 1. Get your overall organization details (including the Root ID)
data "aws_organizations_organization" "org" {}

# 2. Look up the parent "Workloads" OU under the organization root
data "aws_organizations_organizational_unit" "workloads_parent" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
  name      = "Workloads" 
}

# 3. Look up the target environment OU (e.g., "Prod") inside the Workloads OU
data "aws_organizations_organizational_unit" "prod" {
  parent_id = data.aws_organizations_organizational_unit.workloads_parent.id
  name      = var.workload_environment
}

# Identity Center data sources now target the delegated governance account
data "aws_ssoadmin_instances" "current" {
  provider = aws.iam_governance
}

# Look up the permission set ARN dynamically from its friendly name
data "aws_ssoadmin_permission_set" "workload_perms" {
  provider     = aws.iam_governance
  for_each     = var.workload_accounts
  instance_arn = data.aws_ssoadmin_instances.current.arns[0]
  name         = each.value.perm_set
}

data "aws_identitystore_user" "workload_admins" {
  provider          = aws.iam_governance
  for_each          = var.workload_accounts
  identity_store_id = data.aws_ssoadmin_instances.current.identity_store_ids[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName" 
      attribute_value = each.value.admin_user 
    }
  }
}