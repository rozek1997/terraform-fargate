output "alb_sec_group_id" {
  value = aws_security_group.alb.id
}

output "api_target_group" {
  value = aws_alb_target_group.api
}

output "cms_target_group" {
  value = aws_alb_target_group.cms
}