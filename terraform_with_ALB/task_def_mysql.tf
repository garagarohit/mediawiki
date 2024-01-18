data "aws_subnets" "subnet" {
  filter {
    name = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}
resource "aws_ecs_task_definition" "test" {
  family                   = "my_mediawiki_test-mysql"
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<TASK_DEFINITION
[
      {
        "environment": [
          {
            "name": "MYSQL_DATABASE",
            "value": "my_database"
          },
          {
            "name": "MYSQL_PASSWORD",
            "value": "my_password"
          },
          {
            "name": "MYSQL_ROOT_PASSWORD",
            "value": "root_password"
          },
          {
            "name": "MYSQL_USER",
            "value": "my_user"
          }
        ],
        "image": "${data.aws_ecr_repository.example.repository_url}:latest",
        "name": "mediawiki-mysql-con"
      }
    ]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    
  }
}
resource "aws_ecs_service" "test-service-mysql" {
  name            = "testapp-service-mediawiki-mysql"
  cluster         = aws_ecs_cluster.mediawiki_cluster.id
  task_definition = aws_ecs_task_definition.test.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sg-3306.id]
    subnets          = data.aws_subnets.subnet.ids
    assign_public_ip = true
  }
  service_registries{
    registry_arn = aws_service_discovery_service.example.arn
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_service_discovery_private_dns_namespace" "example" {
  name        = "snipe.terraform.com"
  description = "example"
  vpc         = aws_default_vpc.default.id
}

resource "aws_service_discovery_service" "example" {
  name = "example"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.example.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

data "aws_ecr_repository" "mysql" {
  name = "mysql"
}

data "external" "mysql_image" {
  program = ["bash", "./ecs-mysql-task-defination.sh"]
}

