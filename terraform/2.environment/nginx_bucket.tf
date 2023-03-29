#resource "aws_s3_bucket" "nginx_access_log" {
#  bucket = "opsschool-nginx-access-log"

#  tags = {
#    Name = "opsschool-nginx-access-log"
#    Owner = "Dean Vaturi"
#    Purpose = var.purpose_tag
#  }
#}

#resource "aws_s3_bucket_acl" "nginx_access_log_acl" {
#  bucket = aws_s3_bucket.nginx_access_log.id
#  acl    = "private"
#}
