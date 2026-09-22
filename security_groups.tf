# Security Group for Web Servers
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Security group for web servers in public subnets"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-web-sg"
  }
}

# Web Server Inbound: Allow HTTP from anywhere
resource "aws_security_group_rule" "web_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

# Web Server Inbound: Allow HTTPS from anywhere
resource "aws_security_group_rule" "web_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

# Web Server Inbound: Allow SSH from your IP only
resource "aws_security_group_rule" "web_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.your_ip}"]
  security_group_id = aws_security_group.web.id
}

# Web Server Outbound: Allow all traffic
resource "aws_security_group_rule" "web_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

# Security Group for RDS Database
resource "aws_security_group" "database" {
  name        = "${var.environment}-database-sg"
  description = "Security group for RDS database in private subnets"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-database-sg"
  }
}

# Database Inbound: Allow MySQL from web servers only
resource "aws_security_group_rule" "database_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web.id
  security_group_id        = aws_security_group.database.id
}

# Database Outbound: Allow all traffic
resource "aws_security_group_rule" "database_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database.id
}