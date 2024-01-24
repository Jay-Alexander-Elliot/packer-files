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

source "amazon-ebs" "freebsd" {
  access_key            = var.aws_access_key
  secret_key            = var.aws_secret_key
  region                = "us-west-2"
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "*freebsd-13*x86_64*"
      "root-device-type"    = "ebs"
    }
    owners      = ["309956199498"] // Official FreeBSD AMI owner ID
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "freebsd"
  ami_name      = "packer-freebsd-13-example-${timestamp()}"
}

source "googlecompute" "freebsd" {
  project_id              = var.gcp_project_id
  service_account_json    = var.gcp_service_account_json
  image_name              = "packer-freebsd-13-example-${timestamp()}"
  image_family            = "freebsd-13"
  zone                    = "us-west1-a"
  ssh_username            = "freebsd"
}

build {
  sources = [
    "source.amazon-ebs.freebsd",
    "source.googlecompute.freebsd"
  ]

  provisioner "ansible" {
    playbook_file = "update_and_upgrade_playbook.yml"
  }
}
