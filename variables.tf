variable "password_version" {
  description = "Tha password rotates when this value gets updated."
  type        = number
  default     = 0
}

variable "database_name" {
  description = "The name of the database that you want created."
  type        = string
  default     = null
}

variable "database_username" {
  description = "The username of the database that you want created."
  type        = string
  default     = null
}
