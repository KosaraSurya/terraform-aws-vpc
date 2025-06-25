# VPC +tag name was creating as roboshop-dev

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
        var.vpc_tags, # if user provide then those tags will appear
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
  
}

#IGW roboshop dev
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id #association with VPC

  tags =  merge(
        var.igw_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}

# display the name as roboshop-dev-us-east-1a
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index] 
    #we will get all available zone name but if we want only starting 2 availability zone then we have to use slice function, in slice syntax 1 value is inclusive 2 value is exclusive. slice use index to fetch the value here 0 index is inclusive and 2 index is exclusive.
    map_public_ip_on_launch = true #it means the instance launched in this subnet should assigned a pulic IP

    tags =  merge(
        var.public_subnet_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
        }
    )
}

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index] 
    tags =  merge(
        var.private_subnet_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
        }
    )
}

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidr)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.database_subnet_cidr[count.index]
    availability_zone = local.az_names[count.index] 
    tags =  merge(
        var.database_subnet_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
        }
    )
}

resource "aws_eip" "nat" {
  domain   = "vpc"
  tags =  merge(
        var.eip_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )

}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id #we have 2 public subnets in that we are taking 1st subnet.

  tags = merge(
        var.nat_gateway_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  # nat gateway depends on internet gateway
  depends_on = [aws_internet_gateway.main]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
        var.public_route_table_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-public"
        }
    )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
        var.private_route_table_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-private"
        }
    )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
        var.database_route_table_tags,
        local.common_tags,
        {
            Name = "${var.project}-${var.environment}-database"
        }
    )
}
