

resource "aws_emr_cluster" "cluster" {
  name          = "emr cluster"
  release_label = var.emr_version
  applications  = ["Spark", "Hadoop", "Pig", "JupyterHub"]

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true

  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.security_group_id
    emr_managed_slave_security_group  = var.security_group_id
    instance_profile                  = var.emr_profile_arn
    key_name                          = var.key_name
  }

  master_instance_group {
    instance_type = "m4.large"
  }

  core_instance_group {
    instance_type  = "c4.large"
    instance_count = 2

    ebs_config {
      size                 = "40"
      type                 = "gp2"
      volumes_per_instance = 1
    }

  }

  ebs_root_volume_size = 100

  tags = {
    role = "rolename"
    env  = "env"
  }

  dynamic "bootstrap_action" {
    iterator = scripts
    for_each = var.bootstrap

    content {
      path = scripts.value.path
      name = scripts.value.name
      args = scripts.value.args
    }
  }

  configurations_json = <<EOF
  [
    {
      "Classification": "hadoop-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    },
    {
      "Classification": "spark-env",
      "Configurations": [
        {
          "Classification": "export",
          "Properties": {
            "JAVA_HOME": "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties": {}
    }
  ]
EOF

  service_role = var.emr_service_role_arn
}


