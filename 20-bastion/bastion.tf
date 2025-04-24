
resource "aws_instance" "docker" {
  ami                    = "ami-09c813fb71547fc4f" # This is our devops-practice AMI ID
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id = local.public_subnet_id

  # 20GB is not enough
  root_block_device {
    volume_size = 50  # Set root volume size to 50GB
    volume_type = "gp3"  # Use gp3 for better performance (optional)
  }
  
  # user_data = file("bastion.sh")
   tags = merge(var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
    )
}

resource "null_resource" "docker" {
  # Changes to any instance of the instance requires re-provisioning
  triggers = {
    instance_id = aws_instance.docker.id
  }

   connection {
    host = aws_instance.docker.public_ip
    type = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source      = "bastion.sh"
    destination = "/home/ec2-user/bastion.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with public_ip of each node in the cluster
    inline = [
      "chmod +x /home/ec2-user/bastion.sh",
      "sudo sh /home/ec2-user/bastion.sh "
    ]
  }
}

output "docker_ip" {
  value       = aws_instance.docker.public_ip
}
