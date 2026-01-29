resource "aws_instance" "frontend" {
  ami           = data.aws_ssm_parameter.al2023_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_mumbai.id
  vpc_security_group_ids      = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  user_data = file("${path.module}/userdata.sh")

  tags = {
    Name = "frontend-ec2"
  }
}