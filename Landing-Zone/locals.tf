locals {
  root_id = data.aws_organizations_organization.org.roots[0].id

  # Define top-level OUs
  top_level_ous = toset([
    "Core",
    "Workloads",
    "Security",
    "Infrastructure"
  ])

  # Map child OUs to their parent top-level OU
  child_ous = {
    "Prod"     = "Workloads"
    "Non-Prod" = "Workloads"
  }

  landing_zone_accounts = {
    "iam-governance" = {
      email        = "iam-governance@KhanMHKhotmail.onmicrosoft.com"
      parent_id    = aws_organizations_organizational_unit.top_level["Core"].id
      admin_user   = "aws-admin@KhanMHKhotmail.onmicrosoft.com"
      auditor_user = "aws-auditor@KhanMHKhotmail.onmicrosoft.com"
    },
    "security-tooling" = {
      email        = "security-tooling@KhanMHKhotmail.onmicrosoft.com"
      parent_id    = aws_organizations_organizational_unit.top_level["Security"].id
      admin_user   = "aws-admin@KhanMHKhotmail.onmicrosoft.com"
      auditor_user = "aws-auditor@KhanMHKhotmail.onmicrosoft.com"
    },
    "log-archive" = {
      email        = "logging-archive@KhanMHKhotmail.onmicrosoft.com"
      parent_id    = aws_organizations_organizational_unit.top_level["Security"].id
      admin_user   = "aws-admin@KhanMHKhotmail.onmicrosoft.com"
      auditor_user = "aws-auditor@KhanMHKhotmail.onmicrosoft.com"
    },
    "shared-services" = {
      email        = "shared-services@KhanMHKhotmail.onmicrosoft.com"
      parent_id    = aws_organizations_organizational_unit.top_level["Infrastructure"].id
      admin_user   = "aws-admin@KhanMHKhotmail.onmicrosoft.com"
      auditor_user = "aws-auditor@KhanMHKhotmail.onmicrosoft.com"
    },
    "network" = {
      email        = "network@KhanMHKhotmail.onmicrosoft.com"
      parent_id    = aws_organizations_organizational_unit.top_level["Infrastructure"].id
      admin_user   = "aws-admin@KhanMHKhotmail.onmicrosoft.com"
      auditor_user = "aws-auditor@KhanMHKhotmail.onmicrosoft.com"
    }
  }

  ## AWS returns these values as collections (specifically, sets) because it's technically possible to have multiple instances, though 99% of the time you only have one.
  # Because Terraform sets don't support index lookups like [0], tolist(...) converts that set into an ordered list.
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]



}