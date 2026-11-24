# =============================================================================
# TERRAFORM AWS VARIABLES (ASIA PACIFIC - MUMBAI: ap-south-1)
# =============================================================================
variable "aws_region" {
  description = "AWS Region where the EC2 instance and key pair reside"
  type        = string
  default     = "ap-south-1" # Asia Pacific (Mumbai)
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible in ap-south-1)"
  type        = string
  default     = "t3.micro" # t3.micro is AWS Free Tier in Mumbai
}

variable "key_name" {
  description = "Name of the EC2 Key Pair created in AWS Console"
  type        = string
  default     = "shridhar_key"
}
