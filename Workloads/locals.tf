locals {
  workload_ou_map = {
    "${var.workload_environment}" = data.aws_organizations_organizational_unit.prod.id
  }
  
 # Extract the instance ARN and clean suffix for permission set bindings
  instance_arn        = data.aws_ssoadmin_instances.current.arns[0]
  instance_arn_suffix = replace(local.instance_arn, "arn:aws:sso:::instance/", "")
  


  
}