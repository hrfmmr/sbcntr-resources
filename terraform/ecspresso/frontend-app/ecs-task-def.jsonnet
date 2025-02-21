{
  containerDefinitions: [
    {
      cpu: 256,
      environment: [
        {
          name: 'SESSION_SECRET_KEY',
          value: '41b678c65b37bf99c37bcab522802760',
        },
        {
          name: 'NOTIF_SERVICE_HOST',
          value: 'http://{{ or (env `NOTIF_SERVICE_HOST` ``) (tfstate `module.ecs.aws_lb.internal.dns_name`) }}',
        },
        {
          name: 'APP_SERVICE_HOST',
          value: 'http://{{ or (env `APP_SERVICE_HOST` ``) (tfstate `module.ecs.aws_lb.internal.dns_name`) }}',
        },
        {
          name: 'DB_HOST',
          value: '{{ or (env `DB_HOST` ``) (tfstate `module.rds.aws_db_instance.sbcntr_db.address`) }}',
        },
        {
          name: 'DB_NAME',
          value: '{{ or (env `DB_NAME` ``) (tfstate `module.rds.aws_db_instance.sbcntr_db.db_name`) }}',
        },
        {
          name: 'DB_PASSWORD',
          value: '{{ ssm `/sbcntr/db/DB_PASSWORD` }}',
        },
        {
          name: 'DB_USERNAME',
          value: '{{ ssm `/sbcntr/db/DB_USERNAME` }}',
        },
      ],
      essential: true,
      image: '{{ must_env `AWS_ACCOUNT_ID` }}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:2c90e20',
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': "{{ or (env `CW_LOG_GROUP_ECS_TASK_FRONTEND` ``) (tfstate `module.ecs.aws_cloudwatch_log_group.sbcntr['frontend_task'].name`) }}",
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
    },
  ],
  cpu: '256',
  executionRoleArn: '{{ or (env `ECS_TASK_EXEC_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task_exec.arn`) }}',
  family: 'sbcntr-frontend-def',
  ipcMode: '',
  memory: '512',
  networkMode: 'awsvpc',
  pidMode: '',
  requiresCompatibilities: [
    'FARGATE',
  ],
  runtimePlatform: {
    cpuArchitecture: 'ARM64',
    operatingSystemFamily: 'LINUX',
  },
  taskRoleArn: '{{ or (env `ECS_TASK_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task.arn`) }}',
}
