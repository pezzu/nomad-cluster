module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.16.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = [join("", [var.region, "a"]), join("", [var.region, "b"]), join("", [var.region, "c"])]
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_dns_hostnames    = true
  enable_dns_support      = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  create_igw              = true
  enable_ipv6             = false
  map_public_ip_on_launch = true

  tags = {
    Environment = var.cluster_name
  }

  vpc_tags = {
    Name        = "${var.cluster_name}-vpc"
    Environment = var.cluster_name
  }
}

resource "aws_security_group" "server_lb" {
  name   = "${var.cluster_name}-server-lb"
  vpc_id = module.vpc.vpc_id

  # Nomad
  ingress {
    from_port   = 4646
    to_port     = 4646
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

  # Consul
  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.allowlist_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_elb" "server_lb" {
#   name      = "${var.cluster_name}-server-lb"
#   subnets   = distinct(aws_instance.server.*.subnet_id)
#   internal  = false
#   instances = aws_instance.server.*.id

#   # Nomad
#   listener {
#     instance_port     = 4646
#     instance_protocol = "http"
#     lb_port           = 4646
#     lb_protocol       = "http"
#   }

#   # Consul
#   listener {
#     instance_port     = 8500
#     instance_protocol = "http"
#     lb_port           = 8500
#     lb_protocol       = "http"
#   }

#   security_groups = [aws_security_group.server_lb.id]
# }

resource "aws_security_group" "server_ui_ingress" {
  name   = "${var.cluster_name}-ui-ingress"
  vpc_id = module.vpc.vpc_id

  # Nomad
  ingress {
    from_port       = 4646
    to_port         = 4646
    protocol        = "tcp"
    cidr_blocks     = [var.allowlist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }
  # Consul
  ingress {
    from_port       = 8500
    to_port         = 8500
    protocol        = "tcp"
    cidr_blocks     = [var.allowlist_ip]
    security_groups = [aws_security_group.server_lb.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
