variable "env_name" {
  type = string
}

variable "fp_context" {
  type = string
}

data "aws_ssm_parameter" "db_host" {
  name = "/fp/database/host"
}

data "aws_ssm_parameter" "db_user" {
  name = "/fp/database/user"
}

data "aws_ssm_parameter" "db_password" {
  name = "/fp/database/password"
}

data "aws_ssm_parameter" "auth_domain" {
  name = "/fp/auth/domain"
}

data "aws_ssm_parameter" "auth_client_id" {
  name = "/fp/auth/client_id"
}

data "aws_ssm_parameter" "auth_client_secret" {
  name = "/fp/auth/client_secret"
}

module "main" {
  source     = "github.com/FightPandemics/tf-fargate-task//module"
  image_tag  = var.env_name
  fp_context = var.fp_context
  subdomain  = var.env_name
  backend_env_variables = [
    {
      name  = "PORT"
      value = "8000"
    },
    {
      name  = "MONGO_URI"
      value = "mongodb+srv://${data.aws_ssm_parameter.db_user.value}:${data.aws_ssm_parameter.db_password.value}@${data.aws_ssm_parameter.db_host.value}/fightpandemics?retryWrites=true&w=majority"
    },
    {
      name  = "GEO_SERVICE_URL"
      value = "localhost:5000"
    },
    {
      name  = "AUTH_STATE"
      value = "fight-pandemics"
    },
    {
      name  = "AUTH_APP_URL"
      value = "http://localhost:8000"
    },
    {
      name  = "AUTH_SECRET_KEY"
      value = data.aws_ssm_parameter.auth_client_secret.value
    },
    {
      name  = "AUTH_DOMAIN"
      value = data.aws_ssm_parameter.auth_domain.value
    },
    {
      name  = "AUTH_CLIENT_ID"
      value = data.aws_ssm_parameter.auth_client_id.value
    },
    {
      name  = "NODE_ENV"
      value = var.env_name
    },
  ]
}
