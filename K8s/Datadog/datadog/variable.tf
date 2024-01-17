variable "datadog_api_key" {
  type    = string
  default = "2e9e6060d31c26a8dcb4a4f6cb91dd43"
}

variable "datadog_app_key" {
  type    = string
  default = "db523f377d03ef8eb3a9d789868bbaaba409d63a"
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
  default     = "us5.datadoghq.com"
}