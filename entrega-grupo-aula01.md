# Entrega Aula 01 — Grupo Solo

**Disciplina:** Cloud & Cognitive Environments — FIAP MBA AI Engineering & Multi-Agents  
**Turma:** 4AIER  
**Data de entrega:** 29/09/2026  
**RM:** 377019  
**Modalidade da entrega:** Individual — Grupo Solo

> **Observação sobre a modalidade:** esta entrega foi preparada de forma individual. O template obrigatório foi preservado, mas as seções de grupo e distribuição foram adaptadas para um único aluno. O bônus N3 inclui código e roteiro de execução; evidências de `terraform plan/apply/destroy` devem ser geradas no Azure Cloud Shell com a conta do aluno, pois não foram simuladas ou inventadas.

## Grupo

| # | Nome completo | GitHub | E-mail FIAP |
|---|---------------|--------|-------------|
| 1 | Renato Cesar Martins Romão | (https://github.com/renato-cromao/qc-solo-aula01/tree/main) | RM377019@fiap.com.br |

**RM:** 377019  
**Grupo:** Solo

## Distribuição do trabalho

| Membro | Nível assumido | Item específico |
|--------|----------------|-----------------|
| Renato Cesar Martins Romão | 🟢 N1 + 🟡 N2 + 🔴 N3 (bônus) | Exercícios 1.1 a 1.4, 2.1 a 2.3, 3.1 a 3.3, diagramas, IaC, README e revisão final |

> Como a entrega é individual, todo o trabalho foi concentrado no único integrante. O campo de rodízio entre membros não se aplica a esta entrega.

---

## 🟢 Nível 1 — Respostas

### Exercício 1.1 — Mapeamento de modelos de serviço

| Serviço | Modelo | Justificativa |
|---|---|---|
| Gmail | SaaS | Aplicação completa entregue ao usuário; a infraestrutura e a aplicação são operadas pelo provedor. |
| Azure Virtual Machines | IaaS | O Azure fornece a infraestrutura virtualizada, mas o cliente administra SO, patches, runtime e aplicações. |
| Azure App Service (API) | PaaS | O provedor administra a plataforma, SO e runtime; a equipe concentra-se no código e na configuração da aplicação. |
| AWS Lambda | FaaS | A unidade implantada é uma função executada sob demanda, sem servidor dedicado gerenciado pelo cliente. |
| Azure SQL Database | PaaS | O mecanismo de banco é gerenciado; a equipe administra esquema, dados, consultas e políticas de acesso. |
| Salesforce CRM | SaaS | CRM completo consumido como serviço, sem administração da infraestrutura subjacente. |
| Google Kubernetes Engine (GKE) | PaaS/IaaS (híbrido) | O GCP gerencia o control plane do Kubernetes, enquanto o cliente continua responsável por workloads, pods e parte da configuração do cluster. |
| Azure Blob Storage | PaaS | Object storage gerenciado; o cliente administra dados, containers, acesso, lifecycle e políticas. |
| Azure OpenAI Service | SaaS / API-as-a-Service | Modelos são consumidos por API sem que a equipe gerencie servidores ou a infraestrutura de inferência. |

### Exercício 1.2 — Os 6 Rs na prática

**Cenário A — Rehost (Lift & Shift).** O sistema é antigo, pouco documentado e existe urgência para obter elasticidade. Rehospedar em VMs na nuvem reduz o número de mudanças no código e, portanto, o risco imediato da migração. Depois da estabilização, a organização pode planejar modernização em uma segunda etapa.

**Cenário B — Retire.** Com menos de cinco usuários mensais e baixa consulta aos dados, manter ou migrar o ERP pode custar mais do que o valor que ele entrega. O caminho mais racional é arquivar os dados necessários, cumprir requisitos de retenção e desativar o sistema.

**Cenário C — Refactor.** A empresa escolheu explicitamente decompor o monólito em microserviços, usar Kubernetes e adotar arquitetura orientada a eventos. Isso altera significativamente a arquitetura da aplicação para explorar características cloud-native.

**Cenário D — Repurchase.** O CRM próprio pode ser substituído por um SaaS que atende aproximadamente 90% das necessidades e apresenta menor custo. Nesse caso, troca-se o software existente por outro produto em vez de migrá-lo tecnicamente.

**Cenário E — Retain.** O mainframe precisa continuar on-premises por uma restrição regulatória informada no cenário. Assim, ele permanece onde está enquanto a organização pode integrar outros componentes com a nuvem de forma híbrida.

### Exercício 1.3 — Calculando o impacto do SLA

Para um SLA de **99,9%**:

- Disponibilidade indisponível = `1 - 0,999 = 0,001`.
- Downtime anual = `8.760 × 0,001 = 8,76 horas/ano`.
- Impacto financeiro máximo = `8,76 × R$ 50.000 = R$ 438.000/ano`.

Para limitar a perda a **menos de R$ 50.000/ano**, o downtime precisa ser inferior a 1 hora/ano, pois `R$ 50.000 ÷ R$ 50.000/h = 1 h`.

SLA mínimo teórico:

`SLA > (1 - 1/8.760) × 100 = 99,9886%`

Na prática, uma meta comercial de **99,99%** satisfaz a condição: o downtime máximo seria de aproximadamente **0,876 h/ano (52,56 min)** e a perda associada, nas mesmas premissas, seria de **R$ 43.800/ano**.

### Exercício 1.4 — RBAC na prática

| Perfil | Role Azure mais adequada | Justificativa |
|---|---|---|
| Agente de IA que lê produtos no Storage | `Storage Blob Data Reader` | Concede leitura no data plane dos blobs sem permitir alteração dos objetos. |
| Engenheiro de dados que carrega catálogos | `Storage Blob Data Contributor` | Permite leitura, gravação e exclusão de blobs, sem conceder administração ampla da assinatura. |
| FinOps que precisa visualizar custos | `Cost Management Reader` | Permite visualizar dados e configurações de custos sem alterar recursos. `Billing Reader` pode ser usado quando o escopo requerido é de faturamento. |
| Auditor externo que lê configurações | `Reader` no escopo da assinatura | Permite visualizar recursos e configurações sem modificá-los. |
| CI/CD que provisiona via Terraform | `Contributor` no Resource Group específico + Service Principal/Workload Identity dedicado | Permite gerenciar recursos apenas no escopo necessário e evita `Owner` ou `Contributor` no nível da assinatura. |

O princípio aplicado é **least privilege**: conceder somente as permissões necessárias, no menor escopo possível, preferencialmente a identidades de workload em vez de credenciais pessoais.

---

## 🟡 Nível 2 — Respostas + Implementação

### Exercício 2.1 — Arquitetura de alto nível: Quantum Commerce

#### 1. Camadas propostas

A arquitetura proposta usa **sete camadas lógicas**:

1. **Edge e apresentação:** clientes web/mobile chegam por Azure Front Door, CDN e WAF. Essa camada reduz latência global, distribui tráfego e aplica controles de borda.
2. **API e aplicação:** Azure API Management expõe APIs e aplica quotas, autenticação e políticas; Azure Container Apps ou AKS executam backends e orquestradores.
3. **IA e agentes:** Azure AI Foundry/Azure OpenAI executa modelos e agentes, com políticas de segurança, prompt orchestration e integração com ferramentas internas.
4. **Retrieval e dados:** Azure AI Search mantém índice textual/vetorial para RAG; PostgreSQL armazena entidades transacionais; Cosmos DB atende dados semiestruturados e baixa latência; Blob/ADLS Gen2 guarda catálogo, documentos e imagens.
5. **Integração e eventos:** Service Bus e Event Hubs desacoplam pedidos, atualização de catálogo, eventos de navegação e pipelines de processamento.
6. **Segurança e governança:** Microsoft Entra ID, Managed Identities, Key Vault, RBAC e Azure Policy controlam identidade, segredos e conformidade.
7. **Observabilidade e plataforma:** Azure Monitor, Application Insights e Log Analytics centralizam métricas, traces e logs; Terraform e pipeline CI/CD tornam a infraestrutura reproduzível.

#### 2. Provedor principal

O provedor principal escolhido é **Microsoft Azure**. Para este cenário, a vantagem não é apenas computação: há integração direta entre Azure OpenAI/AI Foundry, Azure AI Search, Managed Identities/Entra ID, Key Vault e serviços de observabilidade. Para uma plataforma conversacional corporativa, essa integração reduz componentes de cola e facilita aplicar identidade e governança de forma consistente. A escolha deve ser reavaliada com base em disponibilidade regional dos modelos, limites de quota, requisitos de residência de dados, contratos empresariais e custo real do tráfego internacional.

#### 3. Serviços por categoria

| Categoria | Serviço Azure | Alternativa AWS | Alternativa GCP |
|---|---|---|---|
| Compute (backend) | Azure Container Apps / AKS | ECS/Fargate / EKS | Cloud Run / GKE |
| Storage (catálogo, imagens) | Blob Storage / ADLS Gen2 | Amazon S3 | Cloud Storage |
| Banco relacional | Azure Database for PostgreSQL | Amazon RDS for PostgreSQL | Cloud SQL for PostgreSQL |
| Banco NoSQL | Azure Cosmos DB | DynamoDB | Firestore |
| Vector Database | Azure AI Search | Amazon OpenSearch Service (vector search) | Vertex AI Vector Search |
| Serviços de IA cognitivos | Azure OpenAI + Azure AI Foundry | Amazon Bedrock | Vertex AI |
| CDN | Azure Front Door / Azure CDN | CloudFront | Cloud CDN |
| Mensageria/Filas | Service Bus / Event Hubs | SQS/SNS/Kinesis | Pub/Sub |
| Observabilidade | Azure Monitor + Application Insights + Log Analytics | CloudWatch + X-Ray | Cloud Monitoring + Cloud Logging + Trace |

#### 4. Diagrama

Arquivo: `diagramas/arquitetura-qc-aula01.png`.

A leitura do diagrama segue o fluxo **cliente → edge → frontend → APIs/backend → IA/dados**, com mensageria desacoplando eventos e serviços transversais de segurança/observabilidade atendendo todas as camadas.

### Exercício 2.2 — Comparativo de custos: 3 provedores

#### Premissas da estimativa

Para tornar os números comparáveis, foram adotadas as seguintes premissas em **29/09/2026**:

- preço on-demand, sem impostos e sem contrato empresarial;
- aproximadamente **730 h/mês** para recursos 24/7;
- regiões dos EUA com preços comparáveis (`East US`, `us-east-1`, `us-central1`), pois o exercício não fixa região;
- object storage em tier standard/hot, sem operações e sem egress;
- banco PostgreSQL gerenciado, 2 vCPU/8 GB e 100 GB;
- para funções, contabiliza-se **somente a tarifa de requisições**. O custo de duração/GB-s não pode ser calculado corretamente sem memória e tempo médio por invocação, que não foram informados no enunciado;
- valores são estimativas acadêmicas e devem ser recalculados nas calculadoras oficiais na data do envio.

| Item | Azure | AWS | GCP | Notas |
|---|---:|---:|---:|---|
| 2 × VM (2 vCPU / 8 GB) | **US$ 140,16** | **US$ 121,47** | **US$ 97,82** | Azure D2s v5 ≈ US$ 0,096/h; EC2 t3.large ≈ US$ 0,0832/h; GCE e2-standard-2 ≈ US$ 0,067/h |
| 500 GB object storage | **US$ 10,40** | **US$ 11,50** | **US$ 10,00** | Blob Hot LRS ≈ US$ 0,0208/GB-mês; S3 Standard ≈ US$ 0,023/GB-mês; GCS Standard ≈ US$ 0,020/GB-mês |
| Banco gerenciado | **US$ 110,78** | **US$ 118,08** | **US$ 118,18** | PostgreSQL single-instance: 2 vCPU/8 GB + 100 GB; Azure B2ms + Premium SSD, AWS equivalente burstable + 100 GB, GCP custom 2 vCPU/8 GB + SSD |
| 10M req serverless | **US$ 1,80** | **US$ 1,80** | **US$ 3,20** | Azure/AWS: 1M req gratuitas e ~US$ 0,20/M excedente; GCP: 2M gratuitas e ~US$ 0,40/M excedente; duração não incluída |
| **Total mensal** | **US$ 263,14** | **US$ 252,85** | **US$ 229,20** | Estimativa simplificada, sem impostos, egress e operações adicionais |
| **Total anual** | **US$ 3.157,68** | **US$ 3.034,22** | **US$ 2.750,38** | `mensal × 12` |

**a) Qual ficou mais barato?** Com essas premissas, o **GCP** apresenta o menor custo estimado, cerca de **US$ 229,20/mês**. A AWS fica aproximadamente **US$ 23,65/mês (~10,3%)** acima e o Azure, **US$ 33,94/mês (~14,8%)** acima. A diferença é perceptível, mas não deve ser tratada como um ranking universal: região, família de instância, descontos, perfil de I/O, egress e arquitetura podem alterar significativamente o resultado.

**b) Reserved Instance de 1 ano no mais caro.** O Azure é o mais caro no cenário on-demand. Usando como referência uma tarifa de **aproximadamente US$ 0,0592/h** para D2s v5 com Reserved Instance de 1 ano em East US, o custo das duas VMs cai de US$ 140,16 para cerca de **US$ 86,43/mês**. Mantidos os demais itens, o total do Azure cai para aproximadamente **US$ 209,41/mês**. Nesse recorte, **o resultado muda e o Azure passa a ficar abaixo do GCP**. Isso demonstra por que compromissos de uso podem alterar a decisão financeira; em produção, a comparação deve aplicar modalidades equivalentes de compromisso nos três provedores e considerar utilização real.

**c) Outros fatores para AI Engineering.** Além de preço, consideraríamos: disponibilidade e quota de modelos/GPUs por região; latência para os 12 países; residência e soberania de dados; IAM e integração com identidade corporativa; segurança e serviços de rede privada; maturidade de MLOps/LLMOps e observabilidade; qualidade dos serviços de busca vetorial/RAG; SLA e opções multi-região; custo de egress; lock-in; suporte empresarial; competências da equipe e velocidade de entrega.

**Referências de preço consultadas (acesso em 29/09/2026):** calculadoras oficiais Azure, AWS e Google Cloud; Azure Virtual Machines/Blob Storage/Azure Functions/Azure Database for PostgreSQL; Amazon EC2/S3/Lambda/RDS; Google Compute Engine/Cloud Storage/Cloud Run functions/Cloud SQL. Os valores são estimativas acadêmicas em USD e podem variar por região, contrato, câmbio e alterações de preço.

### Exercício 2.3 — Estratégia de migração para uma empresa

**a) Workload escolhido.** Consideramos um pipeline corporativo de dados que recebe arquivos e tabelas de sistemas internos, executa validações de qualidade e transformações em Spark/SQL, publica datasets curados para consumo analítico e é atualmente suportado por jobs agendados, VMs e banco relacional. A descrição é propositalmente genérica e não contém informações confidenciais.

**b) Estratégia 6R: Replatform.** A opção seria migrar a carga para serviços gerenciados mantendo a lógica de negócio principal, evitando uma reescrita completa no primeiro ciclo. O ganho é reduzir administração de servidores e melhorar elasticidade, observabilidade e automação. O risco é menor do que em um refactor amplo, e o prazo é compatível com migração por etapas. Depois de estabilizada a plataforma, componentes específicos podem ser refatorados quando houver benefício mensurável.

**c) Serviços Azure e estimativa.** A solução poderia usar **Azure Data Factory** para orquestração, **Azure Databricks** para processamento Spark, **ADLS Gen2** para zonas raw/curated, **Key Vault + Managed Identity** para credenciais e **Azure Monitor/Log Analytics** para observabilidade. Para uma PoC pequena — cluster de jobs executando poucas horas por dia, ~500 GB de storage, pipelines diários e baixo egress — adotamos uma faixa inicial de **US$ 400 a US$ 900/mês**, com ponto de planejamento em aproximadamente **US$ 650/mês**. O número é orçamento preliminar; Databricks varia fortemente com tamanho do cluster, DBUs e horas de execução.

**d) Maior obstáculo e mitigação.** O maior obstáculo tende a ser a combinação de dependências legadas, conectividade privada, identidade/permissões e validação de equivalência dos dados. A mitigação seria executar uma migração em ondas: inventário das dependências, landing zone e conectividade, IaC, piloto com um pipeline, execução paralela entre legado e cloud, reconciliação automatizada de contagens/checksums/regras de qualidade, observabilidade e só então cutover. Dessa forma, a mudança reduz risco operacional e gera evidência antes de desligar a solução anterior.

---

## 🔴 Nível 3 — Bônus

> O código foi preparado no ZIP, porém `plan`, `apply` e `destroy` dependem das credenciais e da assinatura Azure do aluno. As evidências de execução devem ser obtidas no Azure Cloud Shell antes do envio caso o bônus N3 seja submetido para pontuação.

### Exercício 3.1 — Terraform: endurecer a segurança da VM

Implementação disponível em `terraform/`.

Principais alterações:

- variável `meu_ip` validada como IPv4 e usada como `${var.meu_ip}/32`;
- regra de entrada SSH na porta 22 aceita somente o IP informado;
- inclusão da subnet `subnet-app` com CIDR `10.0.2.0/24`;
- `output "public_ip_address"` expõe somente o IP público da VM;
- VM Linux utiliza Ubuntu 24.04 e autenticação SSH, sem senha;
- NSG é associado à subnet da VM;
- `.gitignore` impede versionamento de state, planos, `.env`, chaves e `terraform.tfvars`.

Comandos de validação no Azure Cloud Shell:

```bash
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
```

No `terraform plan` do **lab já existente**, a alteração esperada da regra do NSG é conceitualmente:

```text
source_address_prefix: "*" -> "<SEU_IP_PUBLICO>/32"
+ subnet-app (10.0.2.0/24)
```

A VM não deve aparecer com `-/+` (destroy/create). Se aparecer, o diff deve ser revisado antes de aplicar.

**Evidência de execução a anexar pelo aluno:** trecho ou screenshot do `terraform plan` mostrando que a VM não será recriada.

Destruição ao final:

```bash
terraform destroy \
  -var="meu_ip=$MY_IP" \
  -var="admin_public_key=$(cat ~/.ssh/id_rsa.pub)"
```

**Evidência de execução a anexar pelo aluno:** confirmação do `terraform destroy` concluído.

### Exercício 3.2 — Bicep equivalente

O arquivo equivalente está em `bicep/main.bicep`. Nesta implementação o Resource Group é criado pelo Azure CLI e o Bicep, executado em escopo de Resource Group, cria VNet, duas subnets, NSG, IP público, NIC e VM Ubuntu 24.04.

```bash
az group create --name rg-bicep-aula01 --location eastus2
MY_IP=$(curl -s ifconfig.me)

az deployment group create \
  --resource-group rg-bicep-aula01 \
  --template-file bicep/main.bicep \
  --parameters meuIp="$MY_IP" \
               adminPublicKey="$(cat ~/.ssh/id_rsa.pub)"

az group delete --name rg-bicep-aula01 --yes --no-wait
```

#### Comparação dos artefatos desta entrega

| Artefato | Linhas |
|---|---:|
| `arm/template.json` | 182 |
| `terraform/main.tf` | 124 |
| `bicep/main.bicep` | 154 |

> No Terraform, `variables.tf` e `outputs.tf` foram separados por organização; contando os três `.tf`, são 161 linhas. A quantidade de linhas depende da formatação e não deve ser tratada isoladamente como medida de qualidade.

**Qual ficou mais legível?** Para este exemplo, o Bicep ficou bastante direto na descrição dos recursos Azure e nas referências entre eles, enquanto o Terraform apresentou uma organização clara e portátil através de recursos do provider `azurerm`. Nesta análise, o **Bicep é mais natural para uma stack exclusivamente Azure**, enquanto o **Terraform é mais adequado quando a padronização precisa abranger vários provedores**.

**Quando escolher Bicep sobre Terraform?** Quando a solução é Azure-only, a equipe quer alinhamento imediato com o modelo ARM e novos recursos do Azure, e não existe requisito de uma linguagem IaC comum entre clouds. Terraform seria preferido quando o mesmo workflow precisa gerenciar Azure, AWS, GCP, SaaS e outros providers com uma ferramenta comum.

### Exercício 3.3 — Multi-cloud para a Quantum Commerce

#### a) Arquitetura proposta

Arquivo: `diagramas/arquitetura-multicloud-qc-aula01.png`.

A proposta usa **Azure + AWS**, evitando que o caminho crítico dependa de chamadas síncronas frequentes entre nuvens:

- **Azure:** experiência conversacional e serving — Front Door/WAF, backend em Container Apps/AKS, Azure OpenAI/AI Foundry, Azure AI Search e PostgreSQL. A proximidade lógica entre agente, retrieval e banco reduz hops no fluxo interativo.
- **AWS:** catálogo/mídia e processamento assíncrono — S3 como data lake, ECS/Fargate/Lambda para processamento, DynamoDB para metadados e SQS/SNS/EventBridge para eventos.
- A sincronização entre clouds é preferencialmente incremental/batch ou event-driven. Dados necessários à inferência são replicados para um read model local, reduzindo latência e egress no fluxo de chat.

#### b) Quatro desafios e mitigação

| Desafio | Risco | Mitigação proposta |
|---|---|---|
| Latência entre nuvens | Conversas lentas e dependências frágeis | Evitar chamadas síncronas no caminho crítico, manter dados de leitura próximos ao workload, usar cache e eventos assíncronos. |
| Identidade unificada | Credenciais duplicadas e privilégio excessivo | Federação Entra ID ↔ AWS IAM/OIDC, workload identities, tokens curtos e RBAC/least privilege. |
| Custos de egress | Replicação e chamadas cross-cloud podem superar economia de compute | Co-localizar compute com seus dados, replicar somente deltas, comprimir/batch, medir FinOps por fluxo e definir budgets. |
| Observabilidade | Dificuldade de correlacionar incidentes entre clouds | OpenTelemetry, correlation/trace IDs, taxonomia comum de logs e dashboards/SIEM centralizados. |

#### c) Terraform × Pulumi

| Critério | Terraform | Pulumi |
|---|---|---|
| Linguagem | HCL declarativo; JSON também é possível | TypeScript/JavaScript, Python, Go, .NET/C#, Java e YAML |
| Pricing | CLI/community local pode ser usado sem custo; HCP Terraform possui camada Free e planos pagos por managed resources/recursos de plataforma | Plano Free e planos pagos; pricing da plataforma inclui limites/créditos por managed resources e recursos de equipe |
| Azure/AWS/GCP | Sim, por providers oficiais/ecossistema | Sim, com providers para os três grandes provedores |
| Quando escolher | Equipe quer padrão IaC amplamente adotado, grande ecossistema, HCL e forte portabilidade multi-cloud | Equipe quer expressar IaC com linguagens de programação, abstrações reutilizáveis, testes e bibliotecas do ecossistema da linguagem |

Para a QC, Terraform seria a primeira escolha se o objetivo for criar um **padrão operacional comum** entre Azure e AWS. Pulumi seria especialmente atraente se a equipe de plataforma preferir desenvolver componentes de infraestrutura usando Python/TypeScript e compartilhar bibliotecas internas.

#### d) Estimativa de egress — 10 TB/mês Azure Brazil South → AWS us-east-1

Adotando **10 TB = 10.000 GB** e a tabela pública de transferência de dados do Azure para tráfego de saída da América do Sul pela rede premium, com **100 GB/mês gratuitos** e aproximadamente **US$ 0,181/GB** na faixa seguinte:

`(10.000 GB - 100 GB) × US$ 0,181 = US$ 1.791,90/mês`

Assim, a ordem de grandeza estimada é **US$ 1.791,90/mês de egress do Azure**. A entrada de dados da internet na AWS é normalmente gratuita, portanto o principal componente deste fluxo está no lado de saída. A conta não inclui VPN/ExpressRoute/Direct Connect, gateways, processamento intermediário, impostos ou contratos privados; esses componentes precisam ser adicionados em uma arquitetura real.

**Azure Arc:** pode ajudar a QC a aplicar governança e gestão Azure a servidores/Kubernetes fora do Azure, inclusive em outros ambientes. Ele é útil para inventário, políticas e operação híbrida/multi-cloud, mas não elimina egress nem transforma serviços AWS em serviços Azure.

**AWS Outposts:** leva infraestrutura e serviços AWS gerenciados para ambiente on-premises. Para a QC faria mais sentido em requisitos híbridos, soberania/latência local ou integração com datacenter; não é, por si só, uma camada de portabilidade entre Azure e AWS.

---

## Reflexão coletiva

> Embora o template use o título “Reflexão coletiva”, esta reflexão é individual, pois a entrega foi realizada por um único aluno.

O ponto mais importante desta aula foi perceber que decisões de cloud não começam pela escolha de um produto específico. Modelos IaaS, PaaS, SaaS e FaaS mudam a divisão de responsabilidade operacional; os 6 Rs ajudam a separar migração de modernização; SLA transforma disponibilidade em impacto financeiro; e RBAC mostra que segurança precisa ser desenhada por identidade, permissão e escopo. Esses conceitos permitem justificar tecnicamente uma arquitetura em vez de apenas listar serviços.

Em uma plataforma agentic, essa base é ainda mais importante porque o agente depende de vários componentes determinísticos: identidade, modelos, fontes de dados, vector search, APIs, filas, observabilidade e políticas de segurança. IaC torna esse ambiente reproduzível e auditável, reduzindo configurações manuais e drift entre ambientes. O mesmo princípio vale para segredos: o código referencia identidades e cofres, mas credenciais não devem ser versionadas no repositório.

Se eu começasse a Quantum Commerce hoje, evitaria uma arquitetura excessivamente distribuída apenas para demonstrar muitos serviços. Manteria o caminho interativo do usuário — API, agente, retrieval e dados necessários à resposta — na mesma região/provedor sempre que possível, usando mensageria assíncrona para integrações menos sensíveis à latência. Adotaria multi-cloud somente quando houvesse requisito real de negócio, resiliência, negociação comercial ou capacidade técnica que compensasse complexidade e egress.

Por fim, custo seria tratado como variável observável, e não apenas como preço de tabela. Recursos estáveis podem receber compromissos de 1 ou 3 anos após medição; cargas intermitentes se beneficiam de serverless/autoscaling; e custos de IA devem incluir tokens, armazenamento vetorial, observabilidade e transferência de dados. A arquitetura deve evoluir a partir de telemetria, testes de carga e SLOs, mantendo segurança e reprodutibilidade como requisitos desde o primeiro deploy.

---

## Artefatos do ZIP

- Documento principal: `entrega-grupo-aula01.md`
- Instruções do bônus: `README.md`
- Diagrama principal: `diagramas/arquitetura-qc-aula01.png`
- Diagrama multi-cloud: `diagramas/arquitetura-multicloud-qc-aula01.png`
- Terraform: `terraform/main.tf`, `terraform/variables.tf`, `terraform/outputs.tf`, `terraform/terraform.tfvars.example`
- Bicep: `bicep/main.bicep`
- ARM equivalente para comparação: `arm/template.json`
- Endpoint ativo: não aplicável nesta versão; informar somente se houver um endpoint temporário mantido durante a correção.

## Referências técnicas

- Enunciado da Aula 1: https://github.com/IsaiasBritto/aie-cloud/blob/main/aulas/01-fundamentos-iac/exercicios.md
- Template obrigatório: https://github.com/IsaiasBritto/aie-cloud/blob/main/entregas/template-entrega-grupo.md
- Instruções da Entrega 01: https://github.com/IsaiasBritto/aie-cloud/blob/main/entregas/entrega-01/INSTRUCOES.md
- Azure Pricing Calculator: https://azure.microsoft.com/pricing/calculator/
- AWS Pricing Calculator: https://calculator.aws/
- Google Cloud Pricing Calculator: https://cloud.google.com/products/calculator
- Azure pricing: https://azure.microsoft.com/pricing/
- Azure Bandwidth: https://azure.microsoft.com/pricing/details/bandwidth/
- Azure PostgreSQL Flexible Server: https://azure.microsoft.com/pricing/details/postgresql/flexible-server/
- AWS pricing: https://aws.amazon.com/pricing/
- AWS S3: https://aws.amazon.com/s3/pricing/
- AWS Lambda: https://aws.amazon.com/lambda/pricing/
- Google Cloud pricing: https://cloud.google.com/pricing
- Google Cloud Storage: https://cloud.google.com/storage/pricing
- Cloud SQL: https://cloud.google.com/sql/pricing
- Cloud Run functions: https://cloud.google.com/functions/pricing-overview
- Terraform: https://developer.hashicorp.com/terraform
- Pulumi: https://www.pulumi.com/
