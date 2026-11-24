# =============================================================================
# TERRAFORM AWS: DOODLE-DASH CLOUD DEPLOYMENT
# =============================================================================

# 1. Official Canonical Ubuntu 24.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# 2. Security Group (Opens ports 22, 80, 3001, 5000, 8085)
resource "aws_security_group" "letsdraw_sg" {
  name        = "doodledash-devops-sg"
  description = "Security group for Doodle-Dash multiplayer game, DevOps stack and monitoring"

  dynamic "ingress" {
    for_each = [22, 80, 3001, 5000, 8085]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "doodledash-sg"
  }
}

# 3. AWS Key Pair (Registered using shridhar_key.pub)
resource "aws_key_pair" "shridhar" {
  key_name   = var.key_name
  public_key = file("${path.module}/../shridhar_key.pub")
}

# 4. AWS EC2 Instance (t3.micro - Free Tier in Mumbai)
resource "aws_instance" "letsdraw_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.shridhar.key_name
  vpc_security_group_ids = [aws_security_group.letsdraw_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  # Startup script: runs automatically when the EC2 server boots for the first time
  user_data = <<-EOF
    #!/bin/bash

    # Step 1: Add extra memory (swap) so Docker builds don't run out of RAM
    fallocate -l 1G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile

    # Step 2: Install Docker and Git
    apt-get update -y && apt-get install -y docker.io docker-compose-v2 git
    systemctl enable --now docker

    # Step 3: Download the project from GitHub
    git clone https://github.com/Shridhar2622/Devops.git /home/ubuntu/letsdraw

    # Step 4: Start the app (Frontend + Backend + Nagios) using Docker
    cd /home/ubuntu/letsdraw && docker compose up -d --build
  EOF

  tags = {
    Name = "Doodle-Dash-DevOps-Server"
  }
}
