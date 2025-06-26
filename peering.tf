resource "aws_vpc_peering_connection" "foo" {
    #peer_owner_id = var.peer_owner_id # Here we are using our own account for both vpc's so owner is not required.
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id # Accepter tVPC
  vpc_id        = aws_vpc.main.id # Requestor

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  auto_accept = true #we are using vpc's from same account,region so we canuse auto accept option.

  tags = merge(
    var.aws_vpc_peering_tags,
    local.common_tags,{
      Name = "${var.project}-${var.environment}-default"
    }
  )
}

# Route from roboshop VPC to Default VPC
# FOr practice purpose we are creating route for all subnets
resource "aws_route" "public_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id 
  
}

resource "aws_route" "private_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id 
  
}

resource "aws_route" "database_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id 
  
}

# Route from default VPC to roboshp VPC

resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.id
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id 
  
}