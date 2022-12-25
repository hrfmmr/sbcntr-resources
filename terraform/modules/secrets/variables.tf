variable "db_credentials" {
  type = object({
    username = string,
    password = string
  })
}
