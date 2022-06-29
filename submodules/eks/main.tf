
data "aws_partition" "current" {}
data "aws_caller_identity" "aws_account" {}

locals {
  aws_account_id    = data.aws_caller_identity.aws_account.account_id
  dns_suffix        = data.aws_partition.current.dns_suffix
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"
  eks_cluster_security_group_rules = {
    ingress_nodes_443 = {
      description = "Private subnets to ${var.deploy_id} EKS cluster API"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = [for sb in var.private_subnets : sb.cidr_block]
    }
    egress_nodes_9443 = {
      description = "EKS control plane to nodes"
      protocol    = "tcp"
      from_port   = 9443
      to_port     = 9443
      type        = "egress"
      cidr_blocks = [for sb in var.private_subnets : sb.cidr_block]
    }
    egress_nodes_443 = {
      description = "${var.deploy_id} EKS cluster API to private subnets"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "egress"
      cidr_blocks = [for sb in var.private_subnets : sb.cidr_block]
    }
    egress_nodes_kubelet = {
      description = "${var.deploy_id} EKS cluster API to private subnets"
      protocol    = "tcp"
      from_port   = 10250
      to_port     = 10250
      type        = "egress"
      cidr_blocks = [for sb in var.private_subnets : sb.cidr_block]
    }
  }

  node_security_group_rules = {
    ingress_cluster_9443 = {
      description                   = "Cluster API to node groups 9443, hephaestus"
      protocol                      = "tcp"
      from_port                     = 9443
      to_port                       = 9443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_cluster_443 = {
      description                   = "Node groups to cluster API 443"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "egress"
      source_cluster_security_group = true
    }
    ingress_cluster_443 = {
      description                   = "Cluster API to node groups 443"
      protocol                      = "tcp"
      from_port                     = 443
      to_port                       = 443
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_kubelet = {
      description                   = "Cluster API to node kubelets"
      protocol                      = "tcp"
      from_port                     = 10250
      to_port                       = 10250
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_cluster_coredns_tcp = {
      description                   = "Cluster to node CoreDNS TCP"
      protocol                      = "tcp"
      from_port                     = 53
      to_port                       = 53
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_cluster_coredns_tcp = {
      description                   = "Cluster to node CoreDNS TCP"
      protocol                      = "tcp"
      from_port                     = 53
      to_port                       = 53
      type                          = "egress"
      source_cluster_security_group = true
    }
    ingress_cluster_coredns_udp = {
      description                   = "Cluster to node CoreDNS UDP"
      protocol                      = "udp"
      from_port                     = 53
      to_port                       = 53
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_cluster_coredns_udp = {
      description                   = "Cluster to node CoreDNS UDP"
      protocol                      = "udp"
      from_port                     = 53
      to_port                       = 53
      type                          = "egress"
      source_cluster_security_group = true
    }
    ingress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_tcp = {
      description = "Node to node CoreDNS"
      protocol    = "tcp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    ingress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "ingress"
      self        = true
    }
    egress_self_coredns_udp = {
      description = "Node to node CoreDNS"
      protocol    = "udp"
      from_port   = 53
      to_port     = 53
      type        = "egress"
      self        = true
    }
    egress_https = {
      description = "Egress all HTTPS to internet"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_tcp = {
      description = "Egress NTP/TCP to internet"
      protocol    = "tcp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_ntp_udp = {
      description = "Egress NTP/UDP to internet"
      protocol    = "udp"
      from_port   = 123
      to_port     = 123
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    teleport_3024 = {
      description = "Access to Teleport"
      protocol    = "tcp"
      from_port   = 3024
      to_port     = 3024
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    efs_2049 = {
      description = "Access to EFS"
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    inter_node_traffic_int = {
      description = "Node to node pod/svc trafic in"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    inter_node_traffic_out = {
      description = "Node to node pod/svc trafic out"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "egress"
      self        = true
    }
  }
}
