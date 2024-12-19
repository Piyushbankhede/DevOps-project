provider "aws" {
  region     = "us-east-1"
   profile   = "default"
}
resource  "aws_instance" "myinstance"{
ami = "ami-04b70fa74e45c3917"
instance_type = "t2.micro"
tags = {
    Name = "my tf to launch instance"
   }
}
resource "aws_ebs_volume" "ebsobb" {
  availability_zone = "us-east-1a"
  size              = 4
  tags = {
    Name = "myebs-to-test"
  }
}
output name {
  value       = aws_ebs_volume.ebsobb
  
}
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebsobb.id
  instance_id = aws_instance.myinstance.id
}
