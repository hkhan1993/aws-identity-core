data "aws_organizations_organization" "org" {}

data "aws_ssoadmin_instances" "this" {}

# 1. Look up each individual admin user synced from Entra ID via SCIM
data "aws_identitystore_user" "account_admins" {
  for_each = local.landing_zone_accounts

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.admin_user
    }
  }
}

# 2. Look up each individual auditor user synced from Entra ID via SCIM
data "aws_identitystore_user" "account_auditors" {
  for_each = local.landing_zone_accounts

  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.auditor_user
    }
  }
}

