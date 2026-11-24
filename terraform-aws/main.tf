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
  description = "Security group for Doodle-Dash game, API, and Nagios"

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

  # Automatically installs Docker and Docker Compose on boot
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose-v2
              systemctl enable --now docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "Doodle-Dash-DevOps-Server"
  }
}
