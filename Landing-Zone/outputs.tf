# Outputs for future reference
output "all_ou_ids" {
  description = "Map of all created OU names to their IDs"
  value = merge(
    { for k, v in aws_organizations_organizational_unit.top_level : k => v.id },
    { for k, v in aws_organizations_organizational_unit.child : k => v.id }
  )
}