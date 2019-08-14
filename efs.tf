variable "aws_access_key" {}
variable "aws_secret_key" {}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

resource "aws_security_group" "everything_open" {
  name        = "everything_open"
  description = "Allow everything"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  ami           = "ami-aa2ea6d0"
  instance_type = "m4.large"
  key_name      = "victor-ssh-key"

  tags = {
    Name = "ec2-efs"
  }

  security_groups = ["${aws_security_group.everything_open.name}"]

  connection {
    type = "ssh"
    user = "ubuntu"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install --yes nfs-common",
      "sudo mkdir /efs",
      "sudo chown -R ubuntu /efs",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 ${aws_efs_file_system.fs.dns_name}:/ /efs",
    ]
  }
}

resource "aws_efs_file_system" "fs" {
  tags {
    Name = "jenkins-master"
  }
}
