
resource "aws_instance" "ssm_ec2_instance" {
  ami                         = var.image_id
  instance_type               = var.ssm_instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_ec2_profile.name

  user_data                   = var.os_type == "amazon_linux_2" ? file("${path.module}/scripts/amazon2_user_data.sh") : file("${path.module}/scripts/amazon2023_user_data.sh")
  user_data_replace_on_change = true  

  tags = {
    Name = var.ssm_instance_name
  }
}

resource "aws_iam_role" "ssm_ec2_role" {
  name = "ssm_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# SSM
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# S3
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ssm_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# 
resource "aws_iam_instance_profile" "ssm_ec2_profile" {
  name = "ssm_ec2_profile"
  role = aws_iam_role.ssm_ec2_role.name
}
