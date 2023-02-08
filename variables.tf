variable "envs" {
  type        = map(string)
  description = "environment variables"
}

variable "secrets" {
  type        = list(string)
  description = "secret variable names"
}

variable "prefix" {
  type        = string
  description = "prefix for parameter names"
}
