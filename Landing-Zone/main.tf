## create top level OUs
resource "aws_organizations_organizational_unit" "top_level" {
  for_each  = local.top_level_ous
  name      = each.value
  parent_id = local.root_id
}

## create child OUs
resource "aws_organizations_organizational_unit" "child" {
  for_each  = local.child_ous
  name      = each.key
  parent_id = aws_organizations_organizational_unit.top_level[each.value].id
}

## assign accounts to OUs
resource "aws_organizations_account" "landing_zone" {
  for_each = local.landing_zone_accounts

  name      = each.key
  email     = each.value.email
  parent_id = each.value.parent_id
}

# Create the AdministratorAccess permission set from scratch
resource "aws_ssoadmin_permission_set" "administrator" {
  name             = "AdministratorAccess"
  description      = "Provides full access to AWS services and resources."
  instance_arn     = local.instance_arn
  session_duration = "PT8H" # 8-hour session length
}

# Attach the official AWS managed AdministratorAccess policy to the permission set
resource "aws_ssoadmin_managed_policy_attachment" "admin_policy" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Bind your user directly to each landing zone account using the new permission set
resource "aws_ssoadmin_account_assignment" "landing_zone_assignments" {
  for_each = local.landing_zone_accounts

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator.arn

  principal_id   = data.aws_identitystore_user.account_admins[each.key].user_id
  principal_type = "USER"

  target_id   = aws_organizations_account.landing_zone[each.key].id
  target_type = "AWS_ACCOUNT"

  # Ensures the permission set is fully created/attached before assignments attempt to bind
  depends_on = [
    aws_ssoadmin_managed_policy_attachment.admin_policy
  ]
}

#  ReadOnly permission set
resource "aws_ssoadmin_permission_set" "readonly" {
  name             = "ReadOnlyAccess"
  description      = "Provides read-only access to AWS services and resources."
  instance_arn     = local.instance_arn
  session_duration = "PT8H" # 8-hour session length
}

#Attach the official AWS managed ReadOnlyAccess policy
resource "aws_ssoadmin_managed_policy_attachment" "readonly_policy" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


# 3. Bind your read-only user/group to each landing zone account
resource "aws_ssoadmin_account_assignment" "readonly_assignments" {
  for_each = local.landing_zone_accounts

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.readonly.arn

  # Swap this data source or variable to target your read-only user/group
  principal_id   = data.aws_identitystore_user.account_auditors[each.key].user_id
  principal_type = "USER" # Or "GROUP" if assigning an entire audit team group

  target_id   = aws_organizations_account.landing_zone[each.key].id
  target_type = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_managed_policy_attachment.readonly_policy
  ]
}


# Log Archive Account Delegations (CloudTrail)
resource "aws_organizations_delegated_administrator" "cloudtrail" {
  account_id        = aws_organizations_account.landing_zone["log-archive"].id
  service_principal = "cloudtrail.amazonaws.com"
}

# Security Tooling Account Delegations
resource "aws_organizations_delegated_administrator" "security_hub" {
  account_id        = aws_organizations_account.landing_zone["security-tooling"].id
  service_principal = "securityhub.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "guardduty" {
  account_id        = aws_organizations_account.landing_zone["security-tooling"].id
  service_principal = "guardduty.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "config" {
  account_id        = aws_organizations_account.landing_zone["security-tooling"].id
  service_principal = "config.amazonaws.com"
}

# IAM Governance Account Delegations
resource "aws_organizations_delegated_administrator" "access_analyzer" {
  account_id        = aws_organizations_account.landing_zone["iam-governance"].id
  service_principal = "access-analyzer.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "aws_sso" {
  account_id        = aws_organizations_account.landing_zone["iam-governance"].id
  service_principal = "sso.amazonaws.com"
}

# Shared Services Account Delegations (StackSets & Backup)
resource "aws_organizations_delegated_administrator" "stacksets" {
  account_id        = aws_organizations_account.landing_zone["shared-services"].id
  service_principal = "member.org.stacksets.cloudformation.amazonaws.com"
}

resource "aws_organizations_delegated_administrator" "backup" {
  account_id        = aws_organizations_account.landing_zone["shared-services"].id
  service_principal = "backup.amazonaws.com"
}
