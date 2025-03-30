
# Desafio CoinCap API

Este projeto é uma implementação de pipeline de dados utilizando Apache Airflow e Google BigQuery com a API pública da CoinCap. Ele realiza extração, transformação e carga (ETL) dos dados de criptomoedas como Bitcoin, Ethereum e BNB, armazenando-os organizadamente em três camadas: RZ (Raw Zone), SZ (Staging Zone) e CZ (Consumer Zone).

## 📁 Estrutura do Projeto

```
desafio-coincap-api/
├── airflow/
│   └── 2.10.5/
│       ├── dags/
│       │   ├── RZ_API_COINCAP_CRYPTO/
│       │   ├── RZ_API_COINCAP_MARKET/
│       │   ├── RZ_API_COINCAP_BITCOIN/
│       │   ├── ...
│       ├── airflow.cfg
│       ├── secrets_config.json
│       └── ...
├── bigquery-model/
│   └── schemas/  ← arquivos exportados com o schema das tabelas
└── README.md
```

## 🛠️ Como Configurar Localmente

### 1. Clonar o repositório

```bash
git clone https://github.com/jprtenorio00/desafio-coincap-api.git
cd desafio-coincap-api
```

### 2. Criar arquivo `secrets_config.json`

Na raiz do projeto, crie um arquivo com sua API Key da CoinCap:

```json
{
  "COINCAP_API_KEY": "sua_api_key_aqui"
}
```

### 3. Instalação do Apache Airflow

```bash
cd airflow/2.10.5
source .airflow/bin/activate
airflow standalone
```

> Acesse o Airflow em: [http://localhost:8080](http://localhost:8080)

### 4. Executar DAGs

Copie os arquivos da pasta `dags/` para o diretório `airflow/2.10.5/dags/`. Isso fará com que o Airflow detecte suas DAGs.

---

## ☁️ Como preparar o ambiente no Google Cloud Platform (GCP)

1. **Crie uma conta gratuita no Google Cloud Platform**  
   Acesse [console.cloud.google.com](https://console.cloud.google.com/) com sua conta Google e ative o projeto gratuito.

2. **Crie um projeto no GCP**  
   Exemplo de ID do projeto: `inspired-nomad-40028922-k3`

3. **Ative a API do BigQuery**  
   Vá até "APIs e serviços" → "Biblioteca" → pesquise por **BigQuery API** e ative.

4. **Acesse o BigQuery Console**  
   Vá até a aba lateral esquerda → BigQuery → e clique em seu projeto.

5. **Crie os seguintes Conjuntos de Dados (Datasets)**:
   - `rz_api_coincap` (Raw Zone - dados brutos)
   - `sz_api_coincap` (Standardized Zone - dados padronizados)
   - `cz_api_coincap` (Consumer Zone - dados prontos para consumo)

---

### 🧱 Exemplo de criação de tabela RZ

```sql
CREATE TABLE `inspired-nomad-40028922-k3.rz_api_coincap.rz_coincap_crypto` (
  id STRING,
  rank STRING,
  symbol STRING,
  name STRING,
  supply STRING,
  maxSupply STRING,
  marketCapUsd STRING,
  volumeUsd24Hr STRING,
  priceUsd STRING,
  changePercent24Hr STRING,
  vwap24Hr STRING,
  explorer STRING
);
```

### 🧱 Exemplo de criação de tabela CZ

```sql
CREATE TABLE `inspired-nomad-40028922-k3.cz_api_coincap.cz_coincap_crypto` (
  ID_CRIPTO STRING,
  NR_POSICAO_RANK STRING,
  DS_SIGLA_ATIVO STRING,
  NM_ATIVO STRING,
  QT_EM_CIRCULACAO STRING,
  QT_MAXIMA_EMISSAO STRING,
  VL_CAPITALIZACAO_MERCADO STRING,
  VL_VOLUME_24H STRING,
  VL_PRECO_ATUAL STRING,
  PC_VARIACAO_24H STRING,
  VL_PRECO_MEDIO_24H STRING,
  LINK_EXPLORADOR STRING,
  DT_CONSULTA STRING
);
```

> 📌 **As demais tabelas seguem esse mesmo padrão, adaptando os campos de acordo com os dados da RZ e objetivos da CZ.**

---

### 📘 Padrões de nomenclatura utilizados

| Prefixo | Significado                  |
|---------|------------------------------|
| ID_     | Identificador                |
| NM_     | Nome                         |
| DS_     | Descrição ou Sigla           |
| DT_     | Data                         |
| NR_     | Número inteiro               |
| QT_     | Quantidade                   |
| VL_     | Valor monetário ou numérico  |
| PC_     | Percentual                   |
| LINK_   | Link ou URL                  |

---

## 🔄 Schedules das DAGs

| DAG                         | Frequência        |
|----------------------------|-------------------|
| RZ_API_COINCAP_CRYPTO      | A cada 30 minutos |
| RZ_API_COINCAP_MARKET      | Minuto 10         |
| RZ_API_COINCAP_BITCOIN     | Minuto 20         |
| RZ_API_COINCAP_ETHEREUM    | Minuto 40         |
| RZ_API_COINCAP_BNB         | Minuto 50         |

---

## 📦 Como preparar o ambiente Airflow no WSL

Para rodar este projeto, você precisa configurar o Apache Airflow em um ambiente virtual no Ubuntu (WSL). Siga os passos abaixo cuidadosamente:

### 🔧 Instalação e Configuração do Ubuntu via WSL

1. Instale o **Ubuntu** via [Microsoft Store](https://aka.ms/wslstore).
2. Instale o WSL com o comando (via CMD como Administrador):
   ```bash
   wsl.exe --install
   ```
3. Reinicie o computador após a instalação.
4. Abra o Ubuntu e crie sua conta UNIX com nome de usuário e senha.

### 📁 Estrutura de Diretórios

5. Crie o diretório principal do projeto:
   ```bash
   mkdir -p ~/airflow/2.10.5
   cd ~/airflow/2.10.5
   ```

### 🔄 Atualização e Instalação de Dependências

6. Atualize os pacotes:
   ```bash
   sudo apt-get update
   ```
7. Instale o Python 3.12 e o venv:
   ```bash
   sudo apt install python3.12 python3.12-venv
   ```
8. Crie um ambiente virtual chamado `.airflow`:
   ```bash
   python3.12 -m venv .airflow
   ```
9. Ative o ambiente virtual:
   ```bash
   source .airflow/bin/activate
   ```

### 🌍 Configuração de Variáveis de Ambiente

10. Defina as variáveis necessárias:
    ```bash
    export AIRFLOW_HOME=$(pwd)
    export AIRFLOW_VERSION=2.10.5
    export PYTHON_VERSION="$(python --version | cut -d ' ' -f 2 | cut -d '.' -f 1-2)"
    export CONSTRAINT_URL="https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"
    ```

### 📥 Instalação do Apache Airflow

11. Instale o Airflow com os pacotes necessários:
    ```bash
    pip install "apache-airflow[async,postgres,google]==${AIRFLOW_VERSION}" --constraint "${CONSTRAINT_URL}"
    ```

### 🚀 Inicialização

12. Inicie o Airflow:
    ```bash
    airflow standalone
    ```
    O terminal mostrará um **username** e **senha**, que você deve salvar para acessar a interface.

13. Acesse o Airflow via navegador:
    [http://localhost:8080](http://localhost:8080)

### 📌 Observações

- Crie a pasta `dags/` dentro de `~/airflow/2.10.5/` e coloque suas DAGs lá.
- Caso reinicie o computador, repita os comandos:
  ```bash
  cd ~/airflow/2.10.5
  wsl
  export AIRFLOW_HOME=$(pwd)
  source .airflow/bin/activate
  airflow standalone
  ```

---

## 🧠 Contribuição

Contribuições são bem-vindas! Fique à vontade para abrir issues ou PRs com melhorias, sugestões ou correções.

---

## 📄 Licença

MIT License.
