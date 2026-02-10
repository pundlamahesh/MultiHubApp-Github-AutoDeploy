provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "github" {
  key_name   = "github-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "aws_security_group" "web_sg" {
  name = "web-sg1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.github.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "html-web-server"
  }
}
output "ec2_private_key" {
  value     = tls_private_key.ssh.private_key_pem
  sensitive = true
}
