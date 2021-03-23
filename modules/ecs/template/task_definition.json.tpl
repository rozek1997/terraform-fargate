 ${
   jsonencode(
      [
          {
            "name": "crowdcomms_${service}",
            "image": image,
//            "entryPoint": service == "api" || service == "cms" ? ["./entrypoint-api"] : ["./entrypoint-${service}"],
            "essential": true,
            "memoryReservation": service_memory,
            "secrets": [
              for env in ssm_secrets: {
                name = env
                valueFrom = "arn:aws:ssm:${aws_region}:${account_id}:parameter/${workspace}/${env}"
              }
            ],
            "environment": [
              for env in environments: {
                name = env.name
                value = env.value
              }
            ],
            portMappings: [
              {
                hostPort: 8080,
                containerPort: 8080
              }
            ],
            "logConfiguration": {
              "logDriver": "awslogs",
              "options": {
                "awslogs-group": cc_log_group,
                "awslogs-region": aws_region,
                "awslogs-stream-prefix": cc_log_stream
              }
            }
          }
      ]
  )
 }