package terraform

# Deny SSH from anywhere
deny[msg] {
  input.resource_type == "aws_security_group_rule"
  input.values.from_port == 22
  input.values.cidr_blocks[_] == "0.0.0.0/0"
  msg := sprintf("Security group rule '%s' allows SSH from 0.0.0.0/0", [input.resource_name])
}

# Deny RDP from anywhere
deny[msg] {
  input.resource_type == "aws_security_group_rule"
  input.values.from_port == 3389
  input.values.cidr_blocks[_] == "0.0.0.0/0"
  msg := sprintf("Security group rule '%s' allows RDP from 0.0.0.0/0", [input.resource_name])
}
