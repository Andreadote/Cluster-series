resource "aws_instance" "base" {
  ami = data.aws_ami.amzlinux2.id
  instance_type =  = "t2.micro"
  subnet_id =  element(aws_subnet.public[*].id, count.index)

  tags = {
    Name = "Ansible-Ubuntu"
    "env" = "prod"
  }
  
}