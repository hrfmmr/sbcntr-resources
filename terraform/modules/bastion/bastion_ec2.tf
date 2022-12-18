# SSH key
resource "aws_key_pair" "admin" {
  key_name   = "admin"
  public_key = var.ssh_public_key
  tags = {
    Name = "admin-ssh-key-pair"
  }
}

# EC2
resource "aws_instance" "bastion_ec2" {
  instance_type = "t2.micro"
  ami           = var.ec2_ami
  subnet_id     = var.ec2_subnet_id
  vpc_security_group_ids = [
    aws_security_group.sbcntr_sg_bastion.id
  ]
  key_name = aws_key_pair.admin.key_name

  tags = {
    Name = "bastion-ec2"
  }
}

