variable "vm_name_prefix" {
  default = "sockshop"
}

variable "vm_count" {
  default = 3
}

variable "vm_user" {
  default = "user"
}

variable "public_ssh_key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDf/ylJEGjOTlnhAGzsTX9o8YV9IWNVC+pzK/4gyryAZ6M04IzMxTIQwLGoGF99KCZGe7gSYIS53aEpmlu8PP9X6BtuKewj62pTrnseTv3gTilqD8MBFT2wmrffN1dvtWCXwXIADIcW4vhEUj20RmsyARktbLSAynhxTYKpoRRm/dDyobXPB29nsyKsQYHwAirRjK/CDm047u6yOKI/pgiIkGhxoSzQaSdRAe74VyNZcDRR/+dawQqYzEonq5Fsoj8HL1qeKMCUtrkNfvl625ShtShgeC3jXP+1Fw+2bnxV/uep97w2BpQT7cvKTGneTrvBtvtyq/en7mq96Zx0ClT5ymleG+V+Me0BOBtdcrBXvTFwqzT0OfZdJjnY9AH1SDf9JBRP5T1XyG7+yDR6d3EX86VXhpaDkraQDDxaIgKRG1uOxDD34y4+XvYNYua7AzqtMao8Guto3b7uE/0pwCXba894bixt4cn60FqRzHTKKnpo1hewUNZY/GPu6ehc1Gb9P/IcckXoUJvtRJ9pqwu+PQFfj32OwdY2V62sTpPTJ7+vFiCxqkLkY4hQ/dhjuQPbgEK8w6lAnalQwkyKdwxMlPNWsNhOVXCdO4hfuqsl7wYxOE5OpPfX9J0w78wrBVkq+ETmX+RCqHmQsN7cRJjFujRn12qw+s9j3G2tcS1F9w== user@test"
}

variable "image_id" {
  default = "fd8pfd17g205ujpmpb0a"
}
