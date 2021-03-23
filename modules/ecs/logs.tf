resource "aws_cloudwatch_log_group" "cc_log_group" {
  for_each          = toset(var.service_names)
  name              = "/crowdocomms-${terraform.workspace}/${each.value}/app"
  retention_in_days = 0
}

resource "aws_cloudwatch_log_stream" "cc_log_stream" {
  for_each       = toset(var.service_names)
  name           = "cc-stream-${terraform.workspace}-${each.value}"
  log_group_name = aws_cloudwatch_log_group.cc_log_group[each.value].name

}