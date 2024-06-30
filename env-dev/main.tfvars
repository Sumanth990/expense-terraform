env = "dev"
project_name = "expense"

vpc = {
  main = {
    cidr_block  = "10.10.0.0/21"
    subnet_cidr = ["10.10.1.0/25", "10.10.1.128/25"]
    az          = ["us-east-1a", "us-east-1b"]
  }
}