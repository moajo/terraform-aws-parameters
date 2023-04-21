output "parameters_accessor_policy" {
  value = aws_iam_policy.parameters_accessor
}

output "parameters_names" {
  value = concat(
    [
      for key, value in var.envs : {
        "valueFrom" : aws_ssm_parameter.envs[key].name,
        "name" : key,
      }
      ], [
      for key in var.secrets : {
        "valueFrom" : "/aws/reference/secretsmanager/${local.parameter_prefix}${key}",
        "name" : key,
      }
    ]
  )
}
