# Techcareerhubs-iam/main.tf

# Combine all user lists into a single set for user creation
locals {
  all_users = toset(concat(var.admin_users, var.developer_users, var.test_users))
}

#----------------------------------------------------
# Create all IAM Users
#----------------------------------------------------
resource "aws_iam_user" "users" {
  for_each = local.all_users
  name     = each.key
  path     = "/users/"

  # NOTE: Forcing destroy is useful for dev/test but should be avoided in production.
  # This allows you to easily delete users with attached policies during cleanup.
  force_destroy = true
}

#----------------------------------------------------
# Create IAM Groups
#----------------------------------------------------
resource "aws_iam_group" "admins" {
  name = "Admins"
  path = "/groups/"
}

resource "aws_iam_group" "developers" {
  name = "Developers"
  path = "/groups/"
}

resource "aws_iam_group" "test" {
  name = "Test"
  path = "/groups/"
}

#----------------------------------------------------
# Create Custom IAM Policies
#----------------------------------------------------

# 1. ForceMFA Policy for the Admins group
resource "aws_iam_policy" "force_mfa" {
  name        = "ForceMFA"
  description = "Denies all actions if MFA is not present."
  policy      = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowAllActionsWithMFA",
        Effect   = "Allow",
        Action   = "*",
        Resource = "*",
        Condition = {
          Bool = { "aws:MultiFactorAuthPresent" = "true" }
        }
      },
      {
        Sid      = "DenyAllActionsWithoutMFA",
        Effect   = "Deny",
        Action   = "*",
        Resource = "*",
        Condition = {
          BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" }
        }
      }
    ]
  })
}

# 2. Inline Policy for the Test group (attached directly)
resource "aws_iam_group_policy" "test_env_actions" {
  name  = "TestEnvironmentActions"
  group = aws_iam_group.test.name
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:StartInstances",
          "ec2:StopInstances"
        ],
        Resource = "arn:aws:ec2:*:*:instance/*",
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Environment" = "Test"
          }
        }
      }
    ]
  })
}

#----------------------------------------------------
# Attach Policies to Groups
#----------------------------------------------------

# Admins Group Policies
resource "aws_iam_group_policy_attachment" "admins_admin_access" {
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_group_policy_attachment" "admins_force_mfa" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

# Developers Group Policies
resource "aws_iam_group_policy_attachment" "developers_ec2" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_group_policy_attachment" "developers_s3" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_group_policy_attachment" "developers_rds" {
  group      = aws_iam_group.developers.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

# Test Group Policies
resource "aws_iam_group_policy_attachment" "test_read_only" {
  group      = aws_iam_group.test.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
# The inline policy is already attached via the `aws_iam_group_policy` resource above.

#----------------------------------------------------
# Add Users to Groups
#----------------------------------------------------
resource "aws_iam_group_membership" "admins" {
  name  = "AdminsGroupMembership"
  users = var.admin_users
  group = aws_iam_group.admins.name
}

resource "aws_iam_group_membership" "developers" {
  name  = "DevelopersGroupMembership"
  users = var.developer_users
  group = aws_iam_group.developers.name
}

resource "aws_iam_group_membership" "test" {
  name  = "TestGroupMembership"
  users = var.test_users
  group = aws_iam_group.test.name
}
