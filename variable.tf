variable "cidr_block" {
    default = "10.0.0.0/16"
  
}

variable "project" {
    type = string
}

variable "environment" {
    type = string
}

variable "vpc_tags" {
    type = map(string)
    default = {} /* we you not provide this line then this variable becomes mandatory it means user should provide. so if we give default value as null so if users not proide the value also it will not throw the error */
}

variable "igw_tags" {
    type = map(string)
    default = {}
}

variable "public_subnet_tags" {
    type = map(string)
    default = {}
}

variable "private_subnet_tags" {
    type = map(string)
    default = {}
}

variable "database_subnet_tags" {
    type = map(string)
    default = {}
}


variable "public_subnet_cidr" {
    type = list(string)
  
}

variable "private_subnet_cidr" {
    type = list(string)
  
}

variable "database_subnet_cidr" {
    type = list(string)
  
}

variable "eip_tags" {
    type = map(string)
    default = {}
}

variable "nat_gateway_tags" {
    type = map(string)
    default = {}
}

variable "public_route_table_tags" {
    type = map(string)
    default = {}
}

variable "private_route_table_tags" {
    type = map(string)
    default = {}
}

variable "database_route_table_tags" {
    type = map(string)
    default = {}
}