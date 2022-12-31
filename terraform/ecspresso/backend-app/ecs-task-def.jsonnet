{
  containerDefinitions: [
    {
      cpu: 256,
      environment: [
        {
          name: 'DB_NAME',
          value: 'sbcntrapp',
        },
        {
          name: 'DB_HOST',
          value: '{{ or (env `DB_HOST` ``) (tfstate `module.rds.aws_db_instance.sbcntr_db.address`) }}',
        },
      ],
      essential: true,
      image: '{{ must_env `AWS_ACCOUNT_ID` }}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1',
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': "{{ or (env `CW_LOG_GROUP_ECS_TASK_BACKEND` ``) (tfstate `module.ecs.aws_cloudwatch_log_group.sbcntr['backend_task_def'].name`) }}",
          'awslogs-region': 'ap-northeast-1',
          'awslogs-stream-prefix': 'ecs',
        },
      },
      memory: 512,
      name: 'app',
      portMappings: [
        {
          appProtocol: '',
          containerPort: 80,
          hostPort: 80,
          protocol: 'tcp',
        },
      ],
      secrets: [
        {
          name: 'DB_PASSWORD',
          valueFrom: '{{ ssm `/sbcntr/db/DB_PASSWORD` }}',
        },
        {
          name: 'DB_USERNAME',
          valueFrom: '{{ ssm `/sbcntr/db/DB_USERNAME` }}',
        },
      ],
    },
  ],
  cpu: '256',
  executionRoleArn: '{{ or (env `ECS_TASK_EXEC_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task_exec.arn`) }}',
  family: 'sbcntr-backend-def',
  ipcMode: '',
  memory: '512',
  networkMode: 'awsvpc',
  pidMode: '',
  requiresCompatibilities: [
    'FARGATE',
  ],
  taskRoleArn: '{{ or (env `ECS_TASK_EXEC_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task.arn`) }}',
}
