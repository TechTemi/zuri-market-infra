data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "zuri" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(var.public_key_path)

  tags = local.common_tags
}

resource "aws_eip" "k3s" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-eip"
  })
}

resource "aws_instance" "k3s" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.k3s.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.zuri.key_name
  iam_instance_profile        = aws_iam_instance_profile.k3s.name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    public_ip    = aws_eip.k3s.public_ip
    project_name = local.name_prefix
  })

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-k3s-node"
  })
}

resource "aws_eip_association" "k3s" {
  instance_id   = aws_instance.k3s.id
  allocation_id = aws_eip.k3s.id
}
