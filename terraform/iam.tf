# IAM Role for CloudWatch Agent - use existing role
data "aws_iam_role" "existing_cloudwatch_agent_role" {
  name = "CloudWatchAgentRole"
}

# use existing role ARN
data "aws_iam_instance_profile" "existing_cloudwatch_agent_profile" {
  name = "CloudWatchAgentProfile"
}

# out instance profile name
output "cloudwatch_agent_profile_name" {
  value = data.aws_iam_instance_profile.existing_cloudwatch_agent_profile.name
}
