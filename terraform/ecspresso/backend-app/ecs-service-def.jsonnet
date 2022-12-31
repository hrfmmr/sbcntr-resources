{
  deploymentConfiguration: {
    maximumPercent: 200,
    minimumHealthyPercent: 100,
  },
  deploymentController: {
    type: 'CODE_DEPLOY',
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
      targetGroupArn: '{{ or (env `LB_TG_INTERNAL_BLUE` ``) (tfstate `module.ecs.aws_lb_target_group.internal_blue.arn`) }}',
    },
  ],
  networkConfiguration: {
    awsvpcConfiguration: {
      assignPublicIp: 'DISABLED',
      securityGroups: [
        '{{ or (env `SG_BACKEND_APP` ``) (tfstate `module.ecs.aws_security_group.sbcntr_sg_container.id`) }}',
      ],
      subnets: [
        "{{ or (env `VPC_SUBNET_APP_AZ_A` ``) (tfstate `module.network.aws_subnet.sbcntr_subnet_private_container1['a'].id`) }}",
        "{{ or (env `VPC_SUBNET_APP_AZ_C` ``) (tfstate `module.network.aws_subnet.sbcntr_subnet_private_container1['c'].id`) }}",
      ],
    },
  },
  pendingCount: 0,
  platformFamily: 'Linux',
  platformVersion: '1.4.0',
  propagateTags: 'NONE',
  runningCount: 0,
  schedulingStrategy: 'REPLICA',
}
