#autoscaling group with launch template
resource "aws_launch_template" "main" {
  name_prefix            = "${local.name}-lt"
  image_id               = data.aws_ami.centos8.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    role_name = var.component
    env       = var.env
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }
}

resource "aws_autoscaling_group" "main" {
  name                = "${local.name}-asg"
  desired_capacity    = var.instance_capacity
  max_size            = var.instance_capacity
  min_size            = var.instance_capacity
  target_group_arns   = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }
}
#security group
resource "aws_security_group" "main" {
  name        = "${local.name}-sg"
  description = "${local.name}-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastion_block
    description      = "SSH"
  }

  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = var.sg_cidr_blocks
    description      = "APPPORT"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-sg"
  }
}

#target group
resource "aws_lb_target_group" "main" {
  name     = "${local.name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2 #it will check 2 times
    unhealthy_threshold = 2
    interval            = 5 #(more responsive) it will check if the target is good or bad.
    timeout             = 2 #timeout for doing health check.
  }
}

resource "aws_iam_role" "main" {
  name = "${local.name}-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com" #service is ec2
        }
      },
    ]
  })

  inline_policy {
    name = "parameter-store"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "GetParameter",
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Resource" : "arn:aws:ssm:us-east-1:992382357886:parameter/${var.env}.${var.project_name}.${var.component}.*"
        },
        {
          "Sid" : "DescribeAllParameters",
          "Effect" : "Allow",
          "Action" : "ssm:DescribeParameters",
          "Resource" : "*"
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "main" {
  name = "${local.name}-role"
  role = aws_iam_role.main.name
}