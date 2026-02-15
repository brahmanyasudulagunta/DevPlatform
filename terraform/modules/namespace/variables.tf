variable "name" {
  description = "Namespace name"
  type        = string
  
  validation {
    condition = can(
      regex(
        "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$",
        var.name
      )
    )
    error_message = "Namespace name must be lowercase RFC 1123 compliant (e.g. team-alpha)."
  }
}

variable "cpu_limit" {
  description = "Total CPU limit for the namespace"
  type        = string
  default     = "4"
}

variable "memory_limit" {
  description = "Total memory limit for the namespace"
  type        = string
  default     = "8Gi"
}

variable "max_pods" {
  description = "Maximum number of pods in the namespace"
  type        = number
  default     = 20
}
