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

source "amazon-ebs" "kali" {
  access_key            = var.aws_access_key
  secret_key            = var.aws_secret_key
  region                = "us-west-2"
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = "*kali-linux-2023*x86_64*"
      "root-device-type"    = "ebs"
    }
    owners      = ["official-kali-linux-ami-owner-id"] // Replace with the actual Kali Linux AMI owner ID
    most_recent = true
  }
  instance_type = "t2.micro"
  ssh_username  = "kali"
  ami_name      = "packer-kali-linux-${timestamp()}"
}

source "googlecompute" "kali" {
  project_id              = var.gcp_project_id
  service_account_json    = var.gcp_service_account_json
  image_name              = "packer-kali-linux-${timestamp()}"
  image_family            = "kali-linux"
  zone                    = "us-west1-a"
  ssh_username            = "kali"
}

build {
  sources = [
    "source.amazon-ebs.kali",
    "source.googlecompute.kali"
  ]

  provisioner "ansible" {
    playbook_file = "update_and_upgrade_playbook.yml"
  }
}
