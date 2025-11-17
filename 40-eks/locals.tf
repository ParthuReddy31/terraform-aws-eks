locals {
  name = "${var.project_name}-${var.environment}"

  vpc_id = data.aws_ssm_parameter.vpc_id.value

  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  # Use public subnets for nodes temporarily (they have direct internet access)
  # This avoids NAT Gateway cross-AZ routing issues
  public_subnet_ids = split(",", data.aws_ssm_parameter.public_subnet_ids.value)

  eks_control_plane_sg_id = data.aws_ssm_parameter.eks_control_plane_sg_id.value

  eks_node_sg_id = data.aws_ssm_parameter.eks_node_sg_id.value
}
