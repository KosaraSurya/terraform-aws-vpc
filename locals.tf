locals {
  common_tags = {
    project = var.project
    environment = var.environment
    Terraform = "true"
  }

  az_names = slice(data.aws_availability_zones.available.names, 0,2)
/*   we will get all available zone name but if we want only starting 2 availability zone then we have to use slice function, in slice syntax 1 value is inclusive 2 value is exclusive. slice use index to fetch the value here 0 index is inclusive and 2 index is exclusive.
 */
 }