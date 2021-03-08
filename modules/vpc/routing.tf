resource "aws_route_table" "private"{
  vpc_id =  aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnets_assosication" {
    count = var.public_subnets_count
    route_table_id = aws_vpc.main.main_route_table_id
    subnet_id = aws_subnet.public_subnets[count.index].id
}

resource "aws_route_table_association" "private_subnets_assosication" {
    count = var.private_subnets_count
    route_table_id = aws_route_table.private.id
    subnet_id = aws_subnet.private_subnets[count.index].id
}
