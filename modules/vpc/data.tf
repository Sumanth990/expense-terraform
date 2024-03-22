data "aws_vpc" "default" {
  default = true # For every region we will have only 1 default VPC, we can't configure two.
}