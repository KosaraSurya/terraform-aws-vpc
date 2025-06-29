output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws.subnet.public[*].id  
}

output "private_subnet_ids" {
    value = aws.subnet.private[*].id  
}

output "database_subnet_ids" {
    value = aws.subnet.databasae[*].id  
}