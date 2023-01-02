# IAM
resource "aws_iam_role" "ecs_codedeploy" {
  name               = "sbcntr-ecs-codedeploy-role"
  assume_role_policy = file(var.codedeploy_trust_policy)
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRoleForECS" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
  role       = aws_iam_role.ecs_codedeploy.id
}

# CodeDeploy
resource "aws_codedeploy_app" "sbcntr_backend" {
  name             = local.backend_def.codedeploy_app_name
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "sbcntr" {
  app_name               = aws_codedeploy_app.sbcntr_backend.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = local.backend_def.codedeploy_group_name
  service_role_arn       = aws_iam_role.ecs_codedeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      //action_on_timeout = "CONTINUE_DEPLOYMENT"
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 5
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = local.backend_def.cluster_name
    service_name = data.aws_ecs_service.sbcntr_backend.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          aws_lb_listener.internal_blue.arn
        ]
      }

      test_traffic_route {
        listener_arns = [
          aws_lb_listener.internal_green.arn
        ]
      }

      target_group {
        name = aws_lb_target_group.internal_blue.name
      }

      target_group {
        name = aws_lb_target_group.internal_green.name
      }
    }
  }
}
