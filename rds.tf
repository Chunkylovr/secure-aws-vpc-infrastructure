# DB Subnet Group (tells RDS which subnets to use)
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = [aws_subnet.private_1a.id, aws_subnet.private_1b.id]

  tags = {
    Name = "${var.environment}-db-subnet-group"
  }
}

# RDS MySQL Database
resource "aws_db_instance" "main" {
  identifier     = "${var.environment}-database"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t2.micro"

  allocated_storage = "20"
  storage_type      = "gp2"

  db_name  = "projectdb"
  username = "admin"
  password = var.db_password

  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = [aws_security_group.database.id]
  publicly_accessible             = false
  multi_az                        = true
  storage_encrypted               = true
  backup_retention_period         = 7

  skip_final_snapshot = true

  tags = {
    Name = "${var.environment}-database"
  }
}

# Output the database endpoint (you'll use this to connect)
output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS database address (hostname only)"
  value       = aws_db_instance.main.address
}