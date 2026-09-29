README — Entrega Aula 01 — Grupo Solo
Este pacote contém N1 e N2 completos e a implementação proposta do bônus N3 para a entrega individual de Renato Cesar Martins Romão (RM 377019), turma 4AIER.
1. Antes de entregar
Dados da entrega:
- Aluno: Renato Cesar Martins Romão
- RM: 377019
- Grupo: Solo
- Turma: 4AIER
- E-mail FIAP: RM377019@fiap.com.br
- Data: 29/09/2026
Antes do upload, execute o N3 no Azure Cloud Shell caso queira enviar o bônus com evidências reais. Não inclua terraform.tfstate, .env, chaves privadas, arquivos .pem ou .venv/ no ZIP.
2. Terraform — Exercício 3.1
No Azure Cloud Shell:
cd terraform
MY_IP=$(curl -s ifconfig.me)

terraform init
terraform fmt -check
terraform validate
terraform plan \
  -var="meu_ip=$MY_IP" \
  -var="admin_public_key=$(cat ~/.ssh/id_rsa.pub)" \
  -out=tfplan
terraform apply tfplan
terraform output -raw public_ip_address
Ao adaptar o código ao lab original, confira no plan que:
- a origem do SSH muda de * para <SEU_IP>/32;
- a subnet subnet-app 10.0.2.0/24 é adicionada;
- a VM não aparece com -/+ (replacement).
Limpeza:
terraform destroy \
  -var="meu_ip=$MY_IP" \
  -var="admin_public_key=$(cat ~/.ssh/id_rsa.pub)"
3. Bicep — Exercício 3.2
az group create --name rg-bicep-aula01 --location eastus2
MY_IP=$(curl -s ifconfig.me)

az deployment group create \
  --resource-group rg-bicep-aula01 \
  --template-file bicep/main.bicep \
  --parameters meuIp="$MY_IP" \
               adminPublicKey="$(cat ~/.ssh/id_rsa.pub)"

az group delete --name rg-bicep-aula01 --yes --no-wait
Contagem desta entrega
Arquivo	Linhas
arm/template.json	182
terraform/main.tf	124
bicep/main.bicep	154


variables.tf e outputs.tf foram separados por organização. O Terraform completo desta pasta tem 161 linhas nos três arquivos .tf.
Legibilidade e escolha
Para um ambiente exclusivamente Azure, Bicep é muito natural porque usa os tipos de recursos ARM diretamente e reduz abstrações adicionais. Terraform é a preferência quando se deseja uma ferramenta comum para Azure, AWS, GCP e outros providers.
4. Validações locais realizadas nesta preparação
- arm/template.json validado como JSON bem-formado.
- Diagramas PNG gerados a partir dos arquivos .dot incluídos no pacote.
- O código Terraform/Bicep não foi aplicado em uma assinatura Azure, pois isso exige as credenciais/assinatura Azure do aluno. Execute os comandos acima e registre as evidências antes da entrega se quiser pontuar o N3.
5. Estrutura
qc-grupo-Solo-aula01/
├── entrega-grupo-aula01.md
├── README.md
├── .gitignore
├── diagramas/
│   ├── arquitetura-qc-aula01.png
│   ├── arquitetura-qc-aula01.dot
│   ├── arquitetura-multicloud-qc-aula01.png
│   └── arquitetura-multicloud-qc-aula01.dot
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── bicep/
│   └── main.bicep
└── arm/
    └── template.json
