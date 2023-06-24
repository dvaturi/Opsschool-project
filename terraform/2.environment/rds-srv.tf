resource "random_id" "kms_key_suffix" {
  byte_length = 2
}

resource "aws_kms_key" "rds_password_key" {
  description             = "KMS key for RDS password encryption"
  deletion_window_in_days = 7
}

resource "aws_kms_alias" "rds_password_key_alias" {
  name          = "alias/rds_kandula${random_id.kms_key_suffix.hex}"
  target_key_id = aws_kms_key.rds_password_key.key_id
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()-_=+[]{}<>:?"
}

resource "aws_kms_ciphertext" "encrypted_rds_password" {
  key_id     = aws_kms_key.rds_password_key.key_id
  plaintext  = random_password.rds_password.result
}

resource "aws_secretsmanager_secret" "rds_password_secret" {
  name = "rds_kandula${random_id.kms_key_suffix.hex}"
}

resource "aws_secretsmanager_secret_version" "rds_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_password_secret.id
  secret_string = aws_kms_ciphertext.encrypted_rds_password.ciphertext_blob
  version_stages  = ["AWSCURRENT"]
}

resource "aws_db_instance" "postgres" {
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  identifier           = "rds-postgres-kandula"
  db_name              = "kandula"
  username             = "postgres"
  password             = random_password.rds_password.result
  port                 = 5432
  publicly_accessible = false
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group_postgres.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  tags = {
    Name    = "rds-server-postgres"
    Owner   = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}



resource "aws_db_subnet_group" "rds_subnet_group_postgres" {
  name       = "rds-subnet-group-postgres"
  subnet_ids = [module.vpc_module.private_subnets_id[0],module.vpc_module.private_subnets_id[1]]

  tags = {
    Name = "rds-subnet-group-postgres"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_db_parameter_group" "rds_parameter_group_postgres" {
  name        = "rds-parameter-group-postgres"
  family      = "postgres14"
  description = "postgres 14 DB Parameter Group"

  tags = {
    Name = "rds-parameter-group-postgres"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_db_option_group" "rds_option_group_postgres" {
  name        = "rds-option-group-postgres"
  engine_name = "postgres"
  major_engine_version = "14"

  tags = {
    Name = "rds_option_group_postgres"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group" "postgres_sg" {
  name = "postgres-access"
  description = "Allow postgres inbound traffic"
  vpc_id = module.vpc_module.vpc_id

    tags = {
    Name = "postgres-rds-server-access-${module.vpc_module.vpc_id}"
    Owner = "Dean Vaturi"
    Purpose = var.purpose_tag
  }
}

resource "aws_security_group_rule" "rds_allow_5432_inside_security_group" {
  description       = "Allow all inside security group"
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.postgres_sg.id
  to_port           = 5432
  type              = "ingress"
  cidr_blocks       = var.internet_cidr
}

resource "aws_security_group_rule" "rds_outbound_anywhere" {
  description       = "allow outbound traffic to anywhere"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.postgres_sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = var.internet_cidr
} 