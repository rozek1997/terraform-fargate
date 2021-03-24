data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy" "cloudfront_full_access" {
  arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

data "aws_iam_policy" "cloudwatch_read_only" {
  arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

data "aws_iam_policy" "ssm_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

data "aws_iam_policy" "cert_manager_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

data "aws_iam_policy" "route53_full_access" {
  arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_policy" "ecs-ssm" {
  name        = "ecs-ssm"
  description = "Provides access for ecs tasks to get parameters from parameter store. Used mainly for crowdcomms/api"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "ssm:GetParameters"
          #          "kms:Decrypt" Required only if your secret uses a custom KMS key and not the default key. The ARN for your custom key should be added as a resource.
        ],
        Resource : [
          "arn:aws:ssm:${var.aws_region}:${var.account_id}:parameter/*"
          #          "arn:aws:kms:${var.aws_region}:${var.aws_region}:key/aws/ssm"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name                = "ecs-task-execution"
  managed_policy_arns = [aws_iam_policy.ecs-ssm.arn, data.aws_iam_policy.ecs_task_execution.arn]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "",
        Effect : "Allow",
        Principal : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task" {
  name = "ecs-task-${terraform.workspace}" //add workspace
  managed_policy_arns = [
    data.aws_iam_policy.cloudfront_full_access.arn,
    data.aws_iam_policy.cloudwatch_read_only.arn,
    data.aws_iam_policy.ssm_read_only.arn,
    data.aws_iam_policy.cert_manager_full_access.arn,
    data.aws_iam_policy.route53_full_access.arn
//    var.s3_policy_arn,
//    var.sns_policy_arn,
//    var.sqs_policy_arn
  ]
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Sid : "",
        Effect : "Allow",
        Principal : {
          "Service" : "ecs.amazonaws.com",
          "Service": "ecs-tasks.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
    }

  )
}
