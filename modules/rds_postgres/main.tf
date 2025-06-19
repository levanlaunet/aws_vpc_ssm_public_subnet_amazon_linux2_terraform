
resource "aws_db_subnet_group" "this" {
  name       = "${var.db_name}_subnet_group"
  subnet_ids = var.db_subnet_ids
  tags = {
    Name = "${var.db_name}_subnet_group"
  }
}

resource "aws_db_instance" "this" {
  identifier         = var.db_instance_name
  engine             = "postgres"
  engine_version     = var.db_engine_version
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
  username           = var.db_username
  password           = var.db_password
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.db_security_group_ids

  db_name = var.db_name

  skip_final_snapshot = true
  publicly_accessible = false # RDS nằm trong private subnet

  tags = {
    Name = var.db_name
  }
}

# Method 1: Không cần null_resource mà cài thủ công sau khi RDS database đã Active
# Method 2: Cần cài PostgreSQL client (psql) trên máy chạy Terraform
# resource "null_resource" "create_db_and_vector" {
#   provisioner "local-exec" {
#     command = <<EOT
#               PGPASSWORD="${var.db_password}" psql -h ${aws_db_instance.this.address} -U ${var.db_username} -d postgres -c "CREATE DATABASE ${var.db_name};"
#               PGPASSWORD="${var.db_password}" psql -h ${aws_db_instance.this.address} -U ${var.db_username} -d ${var.db_name} -c "CREATE EXTENSION IF NOT EXISTS vector;"
#               EOT
#   }
#   depends_on = [aws_db_instance.this]
# }