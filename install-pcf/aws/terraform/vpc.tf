/*
  For Region
*/
resource "aws_vpc" "PcfVpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "${var.prefix}-terraform-pcf-vpc"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
}
resource "aws_internet_gateway" "internetGw" {
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.prefix}-internet-gateway"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
}

# 3. NAT instance setup
# 3.1 Security Group for NAT
resource "aws_security_group" "nat_instance_sg" {
    name = "${var.prefix}-nat_instance_sg"
    description = "${var.prefix} NAT Instance Security Group"
    vpc_id = "${aws_vpc.PcfVpc.id}"
    tags {
        Name = "${var.prefix}-NAT intance security group"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# 3.2 Create NAT instance
resource "aws_instance" "nat_az1" {
    ami = "${var.amis_nat}"
    availability_zone = "${var.az1}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az1}"

    tags {
        Name = "${var.prefix}-Nat Instance az1"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
}

resource "aws_instance" "nat_az2" {
    ami = "${var.amis_nat}"
    availability_zone = "${var.az2}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az2.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az2}"

    tags {
        Name = "${var.prefix}-Nat Instance az2"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
}

# NAT Insance
resource "aws_instance" "nat_az3" {
    ami = "${var.amis_nat}"
    availability_zone = "${var.az3}"
    instance_type = "${var.nat_instance_type}"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat_instance_sg.id}"]
    subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az3.id}"
    associate_public_ip_address = true
    source_dest_check = false
    private_ip = "${var.nat_ip_az3}"

    tags {
        Name = "${var.prefix}-Nat Instance az3"

        "fuse:terraform" = "pivotal-sb1"
        "fuse:product" = "pivotal"
        "fuse:environment" = "nonprod"
    }
}

resource "aws_eip_association" "eip_assoc_nat_az1" {
    instance_id   = "${aws_instance.nat_az1.id}"
    allocation_id = "${data.aws_eip.eip_nat_az1.id}"
}

resource "aws_eip_association" "eip_assoc_nat_az2" {
    instance_id   = "${aws_instance.nat_az2.id}"
    allocation_id = "${data.aws_eip.eip_nat_az2.id}"
}

resource "aws_eip_association" "eip_assoc_nat_az3" {
    instance_id   = "${aws_instance.nat_az3.id}"
    allocation_id = "${data.aws_eip.eip_nat_az3.id}"
}

data "aws_eip" "eip_nat_az1" {
    public_ip = "${var.nat_public_ip_az1}"
}

data "aws_eip" "eip_nat_az2" {
    public_ip = "${var.nat_public_ip_az2}"
}

data "aws_eip" "eip_nat_az3" {
    public_ip = "${var.nat_public_ip_az3}"
}
