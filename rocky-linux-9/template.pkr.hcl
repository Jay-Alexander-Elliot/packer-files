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
  access_key            = var.aws_access_key
  secret_key            = var.aws_secret_key
  region                = "us-west-2"
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "*rocky-linux-9*x86_64*"
      "root-device-type"    = "ebs"
    }
    owners      = ["actual-rocky-linux-ami-owner-id"] // Replace with the actual owner ID
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "rocky"
  ami_name      = "packer-rocky-linux-example-${timestamp()}"
}

source "googlecompute" "example" {
  project_id              = var.gcp_project_id
  service_account_json    = var.gcp_service_account_json
  image_name              = "packer-rocky-linux-example-${timestamp()}"
  image_family            = "rocky-linux-9"
  zone                    = "us-west1-a"
  ssh_username            = "rocky"
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
