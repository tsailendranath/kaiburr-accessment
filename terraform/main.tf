provider "aws" {
  profile    = "default"
  region     = "ap-south-1"
}

variable "awsprops" {
    type = map
    default = {
    region = "ap-south-1"
    vpc = "vpc-03cb9e1227d46cf95"
    ami = "ami-0fdea1353c525c182"
    itype = "t2.micro"
    subnet = "subnet-0c6ec401b1eac1f94"
    publicip = true
    keyname = "devops.pem"
    secgroupname = "project-iac-sg"
  }
}


resource "aws_security_group" "project-iac-sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "project-iac" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet") #FFXsubnet2
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = "Ec21kp"
  user_data = "${file("init.sh")}"
  vpc_security_group_ids = [
    aws_security_group.project-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }

  provisioner "file" {
        source      = "~/Desktop/kaiburr-main/terraform/mongodb-ansible"
        destination = "/home/ec2-user/mongodb-ansible"
     }
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${file("~/Desktop/kaiburr-main/terraform/files/Ec21kp.pem")}"
      host        = "${self.public_ip}"
    }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "redhat"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.project-iac-sg ]
}


output "ec2instance" {
  value = aws_instance.project-iac.public_ip
}
