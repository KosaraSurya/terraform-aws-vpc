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