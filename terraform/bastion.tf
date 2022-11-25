# SSH key
resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = var.ssh_public_key
  tags = {
    Name = "admin-ssh-key-pair"
  }
}

# Security Group
resource "aws_security_group" "sbcntr_sg_bastion" {
  name        = "bastion"
  description = "Security group for bastion"
  vpc_id      = aws_vpc.sbcntr_vpc.id
}

resource "aws_security_group_rule" "sbcntr_sg_bastion_out" {
  security_group_id = aws_security_group.sbcntr_sg_bastion.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sbcntr_sg_bastion_in_ssh" {
  security_group_id = aws_security_group.sbcntr_sg_bastion.id
  type              = "ingress"
  cidr_blocks       = var.bastion_ssh_allowed_ips
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
}

# EC2
resource "aws_instance" "bastion_ec2" {
  instance_type = "t2.micro"
  ami           = var.ec2_bastion_ami
  subnet_id     = aws_subnet.sbcntr_subnet_public_ingress1["a"].id
  vpc_security_group_ids = [
    aws_security_group.sbcntr_sg_bastion.id
  ]
  key_name = aws_key_pair.admin.key_name

  tags = {
    Name = "bastion-ec2"
  }
}
