packer {
  required_plugins {
    amazon = {
      version = ">= 1"
      source  = "hashicorp/amazon"
    }
    googlecompute = {
      version = ">= 1"
      source  = "hashicorp/googlecompute"
    }
  }
}

variables {
  aws_access_key = "{{env `AWS_ACCESS_KEY_ID`}}"
  aws_secret_key = "{{env `AWS_SECRET_ACCESS_KEY`}}"
  gcp_project_id = "{{env `GCP_PROJECT_ID`}}"
  gcp_service_account_json = "{{env `GCP_SERVICE_ACCOUNT_JSON`}}"
}

source "amazon-ebs" "example" {
  access_key            = "${var.aws_access_key}"
  secret_key            = "${var.aws_secret_key}"
  region                = "us-west-2"
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "*ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      "root-device-type"    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "packer-example-${timestamp()}"
}

source "googlecompute" "example" {
  project_id              = "${var.gcp_project_id}"
  service_account_json    = "${var.gcp_service_account_json}"
  image_name              = "packer-example-${timestamp()}"
  image_family            = "ubuntu-2204-lts"
  zone                    = "us-west1-a"
  ssh_username            = "packer"
}

build {
  sources = [
    "source.amazon-ebs.example",
    "source.googlecompute.example"
  ]

  provisioner "ansible" {
    playbook_file = "update_and_upgrade_playbook.yml"
  }
}
