{
  containerDefinitions: [
    {
      essential: true,
      image: '{{ must_env `AWS_ACCOUNT_ID` }}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1',
      name: 'app',
      cpu: 256,
      memoryReservation: 512,
      environment: [
        {
          name: 'DB_NAME',
          value: 'sbcntrapp',
        },
        {
          name: 'DB_HOST',
          value: '{{ or (env `DB_HOST` ``) (tfstate `module.rds.aws_db_instance.sbcntr_db.address`) }}',
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
      logConfiguration: {
        logDriver: 'awsfirelens',
        secretOptions: null,
        options: null,
      },
      portMappings: [
        {
          appProtocol: '',
          containerPort: 80,
          hostPort: 80,
          protocol: 'tcp',
        },
      ],
    },
    {
      essential: true,
      image: '{{ must_env `AWS_ACCOUNT_ID` }}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-log-router:latest',
      name: 'log_router',
      cpu: 64,
      memoryReservation: 128,
      environment: [
        {
          name: 'APP_ID',
          value: 'backend-def',
        },
        {
          name: 'AWS_ACCOUNT_ID',
          value: '{{ must_env `AWS_ACCOUNT_ID` }}',
        },
        {
          name: 'AWS_REGION',
          value: 'ap-northeast-1',
        },
        {
          name: 'LOG_BUCKET_NAME',
          value: '{{ or (env `S3_BUCKET_ECS_TASK_BACKEND_LOGS` ``) (tfstate `aws_s3_bucket.sbcntr_logs.arn`) }}',
        },
        {
          name: 'LOG_GROUP_NAME',
          value: '{{ or (env `CW_LOG_GROUP_ECS_TASK_BACKEND` ``) (tfstate `module.ecs.aws_cloudwatch_log_group.sbcntr['backend_task'].name`) }}',
        },
      ],
      logConfiguration: {
        logDriver: 'awslogs',
        options: {
          'awslogs-group': "{{ or (env `CW_LOG_GROUP_ECS_TASK_BACKEND_FIRELENS` ``) (tfstate  `module.ecs.aws_cloudwatch_log_group.sbcntr-firelens-container.name`) }}",
          'awslogs-region': 'ap-northeast-1',
          'awslogs-stream-prefix': 'firelens',
        },
      },
    },
  ],
  cpu: '512',
  executionRoleArn: '{{ or (env `ECS_TASK_EXEC_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task_exec.arn`) }}',
  family: 'sbcntr-backend-def',
  ipcMode: '',
  memory: '1024',
  networkMode: 'awsvpc',
  pidMode: '',
  requiresCompatibilities: [
    'FARGATE',
  ],
  taskRoleArn: '{{ or (env `ECS_TASK_ROLE_ARN` ``) (tfstate `module.ecs.aws_iam_role.sbcntr_task.arn`) }}',
}
