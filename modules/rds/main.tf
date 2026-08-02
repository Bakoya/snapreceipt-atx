resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  license_model  = var.license_model
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  multi_az               = var.multi_az

  username                      = var.username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = var.backup_retention_period
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  copy_tags_to_snapshot       = true
  deletion_protection         = var.env == "prod" ? true : false
  skip_final_snapshot         = var.env != "prod"
  final_snapshot_identifier   = var.final_snapshot_identifier

  tags = merge(var.tags, tomap({ "Name" = var.identifier }))
}
