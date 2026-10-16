# Account creation still happens in the Management Account (default provider)
resource "aws_organizations_account" "workloads" {
  for_each = var.workload_accounts

  name      = each.key
  email     = each.value.email
  parent_id = local.workload_ou_map[each.value.parent_key]
}

# Permission set assignment runs from the delegated governance account
resource "aws_ssoadmin_account_assignment" "workload_assignments" {
  provider = aws.iam_governance
  for_each = var.workload_accounts

  instance_arn       = local.instance_arn
  
  # CHANGE THIS LINE to use the data source ARN:
  permission_set_arn = data.aws_ssoadmin_permission_set.workload_perms[each.key].arn 

  principal_id       = data.aws_identitystore_user.workload_admins[each.key].user_id
  principal_type     = "USER"

  target_id          = aws_organizations_account.workloads[each.key].id
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_organizations_account.workloads
  ]
}