# Create OpsMan instance
resource "aws_instance" "opsmman_az1" {
  ami = "${var.opsman_ami}"
  availability_zone = "${var.az1}"
  instance_type = "${var.opsman_instance_type}"
  key_name = "${var.aws_key_name}"
  vpc_security_group_ids = ["${aws_security_group.directorSG.id}"]
  subnet_id = "${aws_subnet.PcfVpcPublicSubnet_az1.id}"
  associate_public_ip_address = true
  private_ip = "${var.opsman_ip_az1}"
  root_block_device {
    volume_size = 100
  }
  tags {
    Name = "${var.prefix}-OpsMan az1"

    "fuse:terraform" = "pivotal-sb1"
    "fuse:product" = "pivotal"
    "fuse:environment" = "nonprod"
    "fuse:crowdstrike" = "na"
  }
}

resource "aws_eip_association" "eip_assoc_opsman_az1" {
  instance_id   = "${aws_instance.opsmman_az1.id}"
  allocation_id = "${data.aws_eip.eip_opsman_az1.id}"
}

data "aws_eip" "eip_opsman_az1" {
  public_ip = "${var.opsman_public_ip_az1}"
}

resource "aws_eip" "opsman" {
  instance = "${aws_instance.opsmman_az1.id}"
  vpc      = true
}
