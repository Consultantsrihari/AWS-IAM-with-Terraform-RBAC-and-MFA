# Techcareerhubs-iam/outputs.tf

output "all_users_created" {
  description = "List of all IAM users created."
  value       = keys(aws_iam_user.users)
}

output "admin_group_arn" {
  description = "The ARN of the Admins group."
  value       = aws_iam_group.admins.arn
}

output "developer_group_arn" {
  description = "The ARN of the Developers group."
  value       = aws_iam_group.developers.arn
}

output "test_group_arn" {
  description = "The ARN of the Test group."
  value       = aws_iam_group.test.arn
}

output "force_mfa_policy_arn" {
  description = "The ARN of the custom ForceMFA policy."
  value       = aws_iam_policy.force_mfa.arn
}
