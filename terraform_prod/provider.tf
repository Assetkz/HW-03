terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.89.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.1"
    }
  }
}

provider "yandex" {
  token     = "y0__xC99MOICBjB3RMg3p3J5BKKBjtCkBZQbDhCnYXwYQ9BvLNCmw"
  cloud_id  = "b1gqlqus7d1hemq4sbvt"
  folder_id = "b1g9bocfri43pv7m860p"
  zone      = "ru-central1-a"
}
