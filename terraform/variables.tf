variable "location" {
  description = "Região Azure onde os recursos serão criados."
  type        = string
  default     = "eastus"
}

variable "prefix" {
  description = "Prefixo usado nos nomes dos recursos."
  type        = string
  default     = "aula01-iac"
}

variable "meu_ip" {
  description = "IPv4 público autorizado para SSH, sem /32. Ex.: 203.0.113.10"
  type        = string

  validation {
    condition     = can(cidrhost("${var.meu_ip}/32", 0))
    error_message = "meu_ip deve ser um endereço IPv4 válido sem a máscara /32."
  }
}

variable "admin_username" {
  description = "Usuário administrador da VM Linux."
  type        = string
  default     = "azureuser"
}

variable "admin_public_key" {
  description = "Chave pública SSH usada na VM."
  type        = string
  sensitive   = true
}
