resource "aws_security_group" "web" {
  vpc_id = var.vpc_id
  name   = "${var.project}-web-sg"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "tls_private_key" "web_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "job-assignment-key"
  public_key = tls_private_key.web_key.public_key_openssh
}

resource "local_file" "web_key_pem" {
  filename = "${path.cwd}/job-assignment-key.pem"
  content  = tls_private_key.web_key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.public_subnet_ids, 0)
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  tags = {
    Name    = "${var.project}-web"
    Project = var.project
  }
}