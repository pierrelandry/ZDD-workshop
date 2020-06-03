resource "aws_vpc" "default" {
  cidr_block = "11.0.0.0/16"
  tags = {
    Name = "asa-zdd-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "asa-zdd-igw"
  }

  depends_on = [
      aws_vpc.default
  ]
}

resource "aws_subnet" "subnet_zone_a" {
  vpc_id               = aws_vpc.default.id
  cidr_block           = "11.0.1.0/24"
  availability_zone_id = "euw1-az1"

  tags = {
    Name = "asa-zdd-subnet-b"
  }

  depends_on = [
      aws_vpc.default
  ]
}

resource "aws_subnet" "subnet_zone_b" {
  vpc_id               = aws_vpc.default.id
  cidr_block           = "11.0.2.0/24"
  availability_zone_id = "euw1-az2"

  tags = {
    Name = "asa-zdd-subnet-b"
  }

  depends_on = [
      aws_vpc.default
  ]
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name = "asa-zdd-route-table"
  }
}

resource "aws_route_table_association" "table_route_with_subnet_zone_1" {
  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.subnet_zone_a.id
}

resource "aws_route_table_association" "table_route_with_subnet_zone_b" {
  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.subnet_zone_b.id
}


# data "aws_subnet_ids" "default" {
#   vpc_id = aws_vpc.default.id

#   tags = {
#     "Name" = "asa-subnet-*"
#   }
# }

resource "aws_db_subnet_group" "default" {
  name       = "asa-zdd-subnet-group"
  subnet_ids = [aws_subnet.subnet_zone_a.id, aws_subnet.subnet_zone_b.id]

  depends_on = [
      aws_subnet.subnet_zone_a,
      aws_subnet.subnet_zone_b,
  ]
}

resource "aws_db_instance" "database" {
  engine         = "postgres"
  engine_version = "10.12"

  allocated_storage    = 20
  storage_type         = "gp2"
  instance_class       = "db.t2.micro"
  name                 = "plane_tracker"
  username             = "captain"
  password             = "captainsully"
  parameter_group_name = "default.postgres10"
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.default.name
}

output "database_endpoint" {
  value = aws_db_instance.database.endpoint
}
