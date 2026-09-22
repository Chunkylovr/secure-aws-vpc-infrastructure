# Get the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu's AWS account)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Web Server in Public Subnet 1a
resource "aws_instance" "web_1a" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_1a.id

  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "${var.environment}-web-server-1a"
  }
}

# Web Server in Public Subnet 1b
resource "aws_instance" "web_1b" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_1b.id

  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "${var.environment}-web-server-1b"
  }
}

