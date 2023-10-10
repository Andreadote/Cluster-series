variable "username" {
  type    = list(any)
  default = ["Andre_Adote_Messavussu", "manager"]
}

variable "env" {
  type    = list(any)
  default = ["Development", "Production"]
}

variable "tags" {
  type = map(string)
  default = {
    Env = "Production"
  }
}