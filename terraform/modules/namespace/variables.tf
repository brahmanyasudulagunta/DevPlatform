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
