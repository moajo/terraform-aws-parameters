terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.0.0"
    }
  }
}

locals {
  parameter_prefix = var.prefix == "" ? "/" : "/${var.prefix}/"
}

resource "aws_ssm_parameter" "envs" {
  for_each = var.envs
  name     = "${local.parameter_prefix}${each.key}"
  type     = "String"
  value    = each.value
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each = toset(var.secrets)
  name     = "${local.parameter_prefix}${each.key}"
}

resource "aws_iam_policy" "parameters_accessor" {
  name        = "${var.prefix}-parameters-accessor"
  path        = "/"
  description = "for read secrets"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue"
        ],
        "Resource" : concat(
          [
            for key, value in aws_ssm_parameter.envs : value.arn
          ],
          flatten([
            for key, value in aws_secretsmanager_secret.secrets : [
              value.arn,
              "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/aws/reference/secretsmanager/${key}",
            ]
          ])
        )
      }
    ]
  })
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
