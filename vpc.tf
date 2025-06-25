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

# Creation og elasticIP
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

# Creation of NAT gateway
resource "aws_nat_gateway" "main" {
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

# Creation of public route table
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

# Creation of private route table
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

# Creation of database route table
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

# Creating public routes
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id # Public subnet will connect ot ING through routes
}

# Creating private routes
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id # Private subnet connect ot the nat gateway through routes then NGW connects to the ING

}

# Creating database routes
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

# Creating association between route table and subnets
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidr)  #we have 2 subnets in public
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidr)  #we have 2 subnets in public
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidr)  #we have 2 subnets in public
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

