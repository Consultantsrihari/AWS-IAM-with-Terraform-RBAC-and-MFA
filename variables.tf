# Techcareerhubs-iam/variables.tf

variable "admin_users" {
  description = "List of users for the Admins group."
  type        = list(string)
  default     = ["John_Admin", "Lisa_Admin", "Raj_Admin"]
}

variable "developer_users" {
  description = "List of users for the Developers group."
  type        = list(string)
  default     = ["Alice_Dev", "Mark_Dev", "Priya_Dev", "Alex_DevOps"]
}

variable "test_users" {
  description = "List of users for the Test group."
  type        = list(string)
  default     = ["Sam_Test", "Nina_Test", "Carlos_Test", "Alex_DevOps"]
}
