output "vpc_id" {
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    value = aws.subneet.public[*].id  
}

output "private_subnet_ids" {
    value = aws.subneet.private[*].id  
}

output "database_subnet_ids" {
    value = aws.subneet.databasae[*].id  
}