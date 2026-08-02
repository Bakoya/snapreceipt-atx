data "aws_ssm_parameter" "service_config" {
  name            = "${var.ssm_base_path}/${var.service_name}/env_config"
  with_decryption = true
}

locals {
  service_json = jsondecode(data.aws_ssm_parameter.service_config.value)

  service_envs = [
    for key, value in local.service_json : {
      name  = key
      value = tostring(value)
    }
  ]
}
