variable "datadog_api_key" {
  type    = string
  default = "2e9e6060d31c26a8dcb4a4f6cb91dd43"
}

variable "datadog_app_key" {
  type    = string
  default = "36ad1e9082f757d746a272c994cc54ae62f3393b"
}

variable "datadog_api_url" {
  type    = string
  default = "https://app.datadoghq.com/"
}

variable "application_name" {
  type        = string
  description = "Application Name"
  default     = "demo"
}

variable "datadog_site" {
  type        = string
  description = "Datadog Site Parameter"
  default     = "app.datadoghq.com"
}