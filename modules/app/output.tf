output "ssm_instance_id" {
  value = aws_instance.ssm_ec2_instance.id
}

output "nginx_public_ip" {
  value = aws_instance.ssm_ec2_instance.public_ip
}
