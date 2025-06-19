variable "db_instance_name" {}
variable "db_name" {}
variable "db_engine_version" { default = "15.4" }
variable "db_instance_class" { default = "db.t3.micro" }
variable "db_allocated_storage" { default = 20 }

variable "db_username" {}
variable "db_password" {}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_security_group_ids" {
  type = list(string)
}