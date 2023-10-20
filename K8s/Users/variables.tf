variable "username" {
  type    = list(any)
  default = ["Andre_Adote_Messavussu", "manager", "daniel_pope", "Tome_phile", "Andre_Messavussu"]
}
/*
variable "developers" {
  type    = list(string)
  description = "List of developer usernames"
}
variable "admins" {
  type    = list(string)
  description = "List of admin usernames"
}
*/

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