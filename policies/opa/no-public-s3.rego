package terraform

# Deny public-read S3 buckets
deny[msg] {
  input.resource_type == "aws_s3_bucket"
  input.values.acl == "public-read"
  msg := sprintf("S3 bucket '%s' cannot have public-read ACL", [input.resource_name])
}

deny[msg] {
  input.resource_type == "aws_s3_bucket"
  input.values.acl == "public-read-write"
  msg := sprintf("S3 bucket '%s' cannot have public-read-write ACL", [input.resource_name])
}

# Require encryption
deny[msg] {
  input.resource_type == "aws_s3_bucket"
  not input.values.server_side_encryption_configuration
  msg := sprintf("S3 bucket '%s' must have server-side encryption enabled", [input.resource_name])
}
