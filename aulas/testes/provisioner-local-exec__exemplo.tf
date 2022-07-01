# Fonte:
# https://www.terraform.io/language/resources/provisioners/local-exec

#
# Example usage

resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}


# » Interpreter Examples

resource "null_resource" "example1" {
  provisioner "local-exec" {
    command = "open WFH, '>completed.txt' and print WFH scalar localtime"
    interpreter = ["perl", "-e"]
  }
}

resource "null_resource" "example2" {
  provisioner "local-exec" {
    command = "Get-Date > completed.txt"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo $FOO $BAR $BAZ >> env_vars.txt"

    environment = {
      FOO = "bar"
      BAR = 1
      BAZ = "true"
    }
  }
}
