provider "aws" {
  region = "us-east-1"
}

resource "aws_launch_configuration" "example" {
    image_id             = "ami-07d0cf3af28718ef8"
    instance_type        = "t2.micro"
    security_groups      = ["${aws_security_group.intance.id}"]

    user_data = <<-EOF
              #!/bin/bash
                 echo "Hello, World" > index.html
                 nohup busybox httpd -f -p "${var.server_port}" &
                 EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
      from_port   = "${var.server_port}"
      to_port     = "${var.server_port}"
      protocol    = "tcp"
      cdir_clocks = ["0.0.0.0/0"]
  }

  lifecycle {
      create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"

  min_size = 2
  max_size = 10

  tag = {
      key                = "Name"
      value              = "terraform-asg-example"
      propagate_at_launch = true
  }
}

