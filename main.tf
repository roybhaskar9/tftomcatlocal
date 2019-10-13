provider "aws" {
    region = "us-east-1"
  
}

resource "aws_security_group" "tomcat" {
    name = "tomcat-sg"
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

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
        
    }
}

    resource "aws_instance" "tomcat_vm"{
        instance_type = "t2.medium"
        ami = "ami-04763b3055de4860b"
        security_groups = ["${aws_security_group.tomcat.name}"]
        key_name = "sai-key"

    tags={
        name = "tomcat server"

    }
    connection {
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("sai-key")}"
            host = "${self.public_ip}"

    }
        provisioner "remote-exec" {
            inline = [
                "sudo apt-get update",
                "sudo apt-get -y install wget",
                "sudo apt-get -y install tomcat7 tomcat7-admin",
                "sudo apt-get update",
                "sudo apt-get -y install tomcat7 tomcat7-admin",
                "sudo rm -f /etc/tomcat7/tomcat-users.xml",    
                "sudo wget https://raw.githubusercontent.com/Sreesai9/terraform-class/master/tomcat-users.xml -P /etc/tomcat7/",
                "sudo service tomcat7 restart"

                
            ]
        }
         provisioner "local-exec" {
             command = <<-EOT
                ssh-keyscan -H ${self.public_ip} >> ~/.ssh/known_hosts
                scp -i /Users/sreesai/Documents/Personal/terraform-class/tomcat-latest/sai-key /Users/sreesai/Documents/Personal/terraform-class/tomcat-latest/sample.war ubuntu@${self.public_ip}:/tmp/sample.war
                wget --http-user=admin --http-password=admin 'http://${self.public_ip}:8080/manager/text/deploy?war=file:/tmp/sample.war&path=/sampleapp' -O -
                open -a /Applications/Safari.app http://${self.public_ip}:8080
                


            EOT 

    }
    }




resource "aws_key_pair" "sai_key" {
    key_name = "sai-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4uEI20EF53E5FPJpKSn5t0t5cIVV4j8cf9BxnOCNTB3MD3vRc1/lJArWoqttw+nMUEpDImSO/FgiD81EPnLQRe/8kU6DMyz6bsmMicyNGnPDyUc7lHOeHuKJ12YsYfkS69Ev96edkb62w+WY365Z1/4T2FLZ8mSadwtqJ7m+AzvDmtSEjezq1YFDmswmwoG9Ms2SQB9rjRejC5QTlA9xUlxynHLuNiqZXCGX27Fg6+LvEONom7nv+RA1QoYgvUy5zyxyVMbEDHTcY8LOsJ7EFdtYWeaBjyURk60ag7EkyJvkiifNYDAGnWWy0tIy+VydY6kqSrgN2TUJQYTz28hlB sai-key"
  }
    
