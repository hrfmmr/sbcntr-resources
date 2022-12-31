{
  deploymentConfiguration: {
    deploymentCircuitBreaker: {
      enable: false,
      rollback: false,
    },
    maximumPercent: 200,
    minimumHealthyPercent: 100,
  },
  deploymentController: {
    type: 'ECS',
  },
  desiredCount: 2,
  enableECSManagedTags: false,
  enableExecuteCommand: true,
  healthCheckGracePeriodSeconds: 0,
  launchType: 'FARGATE',
  loadBalancers: [
    {
      containerName: 'app',
      containerPort: 80,
      targetGroupArn: 'arn:aws:elasticloadbalancing:ap-northeast-1:190162224208:targetgroup/sbcntr-tg-frontend/4997821a2f525ebd',
    },
  ],
  networkConfiguration: {
    awsvpcConfiguration: {
      assignPublicIp: 'DISABLED',
      securityGroups: [
        '{{ or (env `SG_FRONTEND_APP` ``) (tfstate `module.ecs.aws_security_group.sbcntr_sg_front_container.id`) }}',
      ],
      subnets: [
        "{{ or (env `VPC_SUBNET_APP_AZ_A` ``) (tfstate `module.network.aws_subnet.sbcntr_subnet_private_container1['a'].id`) }}",
        "{{ or (env `VPC_SUBNET_APP_AZ_C` ``) (tfstate `module.network.aws_subnet.sbcntr_subnet_private_container1['c'].id`) }}",
      ],
    },
  },
  pendingCount: 0,
  platformFamily: 'Linux',
  platformVersion: 'LATEST',
  propagateTags: 'NONE',
  runningCount: 0,
  schedulingStrategy: 'REPLICA',
}
