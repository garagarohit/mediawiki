resource "aws_ecs_task_definition" "mediawiki-main" {
  family                   = "my_mediawiki_test-main"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
#   container_definitions    = data.template_file.testapp.rendered
   container_definitions    = <<TASK_DEFINITION
   [
    {
      "portMappings": [
        {
          "hostPort": 80,
          "protocol": "tcp",
          "containerPort": 80
        }
      ],
      "image": "${data.aws_ecr_repository.example.repository_url}:latest",
      "name": "mediawikiapp"
    }
  ]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX" 
  }
}



resource "aws_ecs_service" "test-service-mediawiki-main" {
  name            = "testapp-service-mediawiki-main"
  cluster         = aws_ecs_cluster.mediawiki_cluster.id
  task_definition = aws_ecs_task_definition.mediawiki-main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg-80.id]
    subnets          = data.aws_subnets.subnet.ids
    assign_public_ip = true
  }
    load_balancer {
    target_group_arn = module.mediawiki-alb.elb-target-group-arn
    container_name   = "mediawikiapp"
    container_port   = 80
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role, aws_ecs_service.test-service-mysql]
}


data "aws_ecr_repository" "example" {
  name = "mediawiki"
}
# data "aws_ecr_image" "service_image" {
#   repository_name = "mediawiki"
#   image_tag = "master"
# }
# output "ecr_image" {
#   value = data.aws_ecr_image.service_image.image_tag
# }


data "external" "mediawiki_image" {
  program = ["bash", "./ecs-task-definition.sh"]
}
