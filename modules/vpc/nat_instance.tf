#changed constant ami to use data source!

resource "aws_instance" "nat_instance" {
  ami = "ami-058436d7e072250b3"
  instance_type = "t2.micro"
  source_dest_check = false
  subnet_id = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.nat_sec_group.id]
}

resource "aws_eip" "nat_instance_ip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_instance_ip.id
}
