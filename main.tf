#### This provisions a VPC 
resource "aws_vpc" "CICDVPC"{
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "CICDVPC"
  }
}

#### This provisions our public subnet
resource "aws_subnet" "PUBSUB1" {
  vpc_id = aws_vpc.CICDVPC
  cidr_block = var.cidr_block_PUBSUB1
  availability_zone = var.AZ1
  map_public_ip_on_launch = true
  tags = {
    "Name" = "PUBSUB1"
  }
}

#### This provisions our internet gateway
resource "aws_internet_gateway" "CICDIGW" {
 vpc_id = aws_vpc.CICDVPC
}

#### This attaches the internet gateway to the VPC
 resource "aws_internet_gateway_attachment" "IGWA" {
   internet_gateway_id = aws_internet_gateway.CICDIGW
   vpc_id = aws_vpc.CICDVPC
 }

#### This generates a Keypair using ssh-keygen.exe
resource "aws_key_pair" "CICD-key" {
    key_name = "CICD-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD070L92OaGBwCMjVdEox3HsMhKkTw+PvivQLMxiHGkZ1nu7pkB5O5FIZbl9a8GbweQ2JSsv4b0qylx6rXnLjpqVI4NcHorkss05wqv175fdnPDwPj8cjmnXLxl4i70Q+3NDj7YVjJPKB/USDfS6gSCpoZWomq58g1RxKJaKUlrUzpNYHAqJbQz9JRTVF/cBJt80pnYfqunzMotGStyXXMj7yey48B6IlK8q8fOqVirt+UyY2xLJRoTiZkKceAWtdPDl3r5NcV6u22FAr1MYTOoEZ0PdSsTvGqKDrQVTVg+7gC62SmXPkfDEcecLdL9FPhfNf95fJ8FPJ0tlANL/6uAUj+fKWraeGi9G3lEuKRXfQBr8xvCghr/bKo7vnmqfvbkMBYoaQeS4FxFEznmx4wPSzJuaXRCkuJ5+FaYnGw+i9OJwBE49ecnXmdOWGHU9ZLUo0kXP/IsGIGgXf3jzhflmjcfOQtLqkS2mjFdwdzOwT80AiQ1q/LKodEwPYIA/VU= admin@PF313WVE-JDV"
  
}

#### This provisions the Jenkin's server with SG open to port 22 for SSH and 8080 fpr Jenkins, with userdata attached
 resource "aws_instance" "Jenkins" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.jenkins-sg" ]
   user_data = file("installjenkins.sh")
   tags = {
     "Name" = "Jenkins"
   }
 }

 resource "aws_security_group" "jenkins-sg" {
   name = "jenkins-sg"
   description = "Allow access to port 22  and 8080"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the SonarQube server using Ubuntu 18.04 t2 medium with SG open to port 22 for SSH and 9000 f0r Sonarqube with usedata attached
 resource "aws_instance" "sonarqube" {
   ami = var.ami_ubuntu
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.sonarqube-sg" ]
   user_data = file("installsonarqube.sh")
   tags = {
     "Name" = "sonarqube"
   }
 }

 resource "aws_security_group" "Sonarqube-sg" {
   name = "jenkins-sg"
   description = "Allow access to port 22  and 9000"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 9000
    to_port = 9000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the Nexus server with SG open to port 22 for SSH and 8081 f0r Nexus
 resource "aws_instance" "Nexus" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.Nexus-sg" ]
   user_data = file("installnexus.sh")
   tags = {
     "Name" = "Nexus"
   }
 }

 resource "aws_security_group" "Nexus-sg" {
   name = "Nexus-sg"
   description = "Allow access to port 22  and 8081"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 8081
    to_port = 8081
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the prometheus server with SG open to port 22 for SSH and 8081 f0r Nexus
 resource "aws_instance" "Prometheus" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.prometheus-sg" ]
   user_data = file("installprometheus.sh")
   tags = {
     "Name" = "Nexus"
   }
 }

 resource "aws_security_group" "prometheus-sg" {
   name = "prometheus-sg"
   description = "Allow access to port 22  and 9090"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the Grafana server with SG open to port 22 for SSH and 3000 f0r Grafana
 resource "aws_instance" "Grafana" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.Grafana-sg" ]
   user_data = file("installgrafana.sh")
   tags = {
     "Name" = "Nexus"
   }
 }

 resource "aws_security_group" "Grafana-sg" {
   name = "Grafana-sg"
   description = "Allow access to port 22  and 8081"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the Dev-Env server with SG open to port 22, 8080, 9100
 resource "aws_instance" "Dev-Env" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.Dev-Env-sg" ]
   tags = {
     "Name" = "Dev-Env"
   }
 }

 resource "aws_security_group" "Dev-Env-sg" {
   name = "Dev-Env-sg"
   description = "Allow access to port 22  and 8081"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#### This provisions the Stage-Env server with SG open to port 22, 8080, 9100
 resource "aws_instance" "Stage-Env" {
   ami = var.ami
   instance_type = var.instance_type
   key_name = "CICD-key"
   subnet_id = aws_subnet.PUBSUB1
   security_groups = [ "aws_security_group.Stage-Env-sg" ]
   tags = {
     "Name" = "Stage-Env"
   }
 }

 resource "aws_security_group" "Stage-Env-sg" {
   name = "Stage-Env-sg"
   description = "Allow access to port 22  and 8081"
   vpc_id = aws_vpc.CICDVPC

   ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port = 9100
    to_port = 9100
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}