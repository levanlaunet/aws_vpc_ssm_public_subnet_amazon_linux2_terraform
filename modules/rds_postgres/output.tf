output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_arn" {
  value = aws_db_instance.this.arn
}