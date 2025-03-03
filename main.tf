terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-7"
}

resource "aws_vpc" "lab_vpc" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "lab_subnet" {
  vpc_id     = aws_vpc.lab_vpc.id
  cidr_block = "172.16.10.0/24"
}

resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id
}

resource "aws_route_table" "lab_route_table" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.lab_subnet.id
  route_table_id = aws_route_table.lab_route_table.id
}

resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.lab_vpc.id
  name        = "app_security_group"
  description = "Allow incoming traffic on ports 22, 3000 and 8080"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "ailab_server" {
  ami           = "ami-019a40287c6e93276" # Ubuntu Server 24.04 LTS (HVM),EBS General Purpose (SSD) Volume Type
  instance_type = "t3.medium"
  key_name      = "bkrbybk-test"
  # security_groups = [aws_security_group.app_sg.name] ### TEST
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = aws_subnet.lab_subnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
  }

  # Docker engine installation
  # REF: https://docs.docker.com/engine/install/ubuntu/
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
              sudo mkdir -p /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
              echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              newgrp docker
              curl -O https://gist.githubusercontent.com/bankierubybank/d8bc415b3ccb9e1713ebc8389228f0cd/raw/dcc0d269e1af6c7021cfdc39c4d6d59f05c45a9f/docker-compose.yml
              docker compose up -d
              docker exec -it ollama ollama run deepseek-r1:1.5b
              docker exec -it ollama ollama run llama3.2:1b
              EOF
}

# sudo apt update -y
# sudo apt install -y python3 
# sudo apt install -y python3-pip
# sudo apt install -y python3.12-venv
# curl -fsSL https://ollama.com/install.sh | sh
# ollama -v
# ollama run deepseek-r1:1.5b
# ollama ps
# ollama list
# python3 -m venv open-webui
# source open-webui/bin/activate
# pip install open-webui
# open-webui serve
