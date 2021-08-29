variable "org-name" {
  type    = string
  default = "OHDevOpsAug2021"
}

variable "githubidfile" {
  type    = string
  # file format:  one username per line, no label
  default = "githubids.csv"
}
variable "adminidfile" {
  type    = string
  # file format:  one username per line, no label
  default = "admins.csv"
}


variable "teamcount" {
  type    = number
  default = 12
}