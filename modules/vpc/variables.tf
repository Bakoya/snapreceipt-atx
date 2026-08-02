variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR Block"
}

variable "azs" {
  type        = list(string)
  description = "The list of AZs to use"
}

variable "database_subnets" {
  type        = list(string)
  description = "The CIDR range of database subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "The CIDR range of private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "The CIDR range of public subnets"
}

variable "enable_nat_gateway" {
  type        = bool
  description = "This option allows enabling nat gateway"
}

variable "create_igw" {
  type        = bool
  description = "This option allows enabling internet gateway"
}

variable "tags" {
  type        = any
  description = "This allows definition of tags"
}

variable "single_nat_gateway" {
  description = "To deploy a single NAT gateway"
}
