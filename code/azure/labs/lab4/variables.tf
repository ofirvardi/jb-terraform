variable "environment" {
  description = "Define the environment type: dev, staging, or prod"
  type        = string
  default     = "prod"
}

variable "high_availability" {
  description = "Whether to enable high availability (true or false)"
  type        = bool
  default     = true
}

variable "create_database" {
  description = "mock database should be created"
  type        = bool
  default     = true
}