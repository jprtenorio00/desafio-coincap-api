CREATE OR REPLACE VIEW `<project-id>.cz_api_coincap.vw_coincap_dashboard`
OPTIONS (
  description = "View consolidada com os dados de criptoativos, mercado e histórico de preços de BTC, ETH e BNB"
) AS
WITH crypto_base AS (
  SELECT *,
         FORMAT_TIMESTAMP('%d/%m/%Y %H', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', DT_CONSULTA)) AS HORA_CHAVE
  FROM `<project-id>.cz_api_coincap.cz_coincap_crypto`
),
market_base AS (
  SELECT *,
         FORMAT_TIMESTAMP('%d/%m/%Y %H', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', DT_CONSULTA)) AS HORA_CHAVE
  FROM `<project-id>.cz_api_coincap.cz_coincap_market`
),
btc_base AS (
  SELECT *,
         FORMAT_TIMESTAMP('%d/%m/%Y %H', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', DT_CONSULTA_HISTORICO)) AS HORA_CHAVE
  FROM `<project-id>.cz_api_coincap.cz_coincap_bitcoin`
),
eth_base AS (
  SELECT *,
         FORMAT_TIMESTAMP('%d/%m/%Y %H', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', DT_CONSULTA_HISTORICO)) AS HORA_CHAVE
  FROM `<project-id>.cz_api_coincap.cz_coincap_ethereum`
),
bnb_base AS (
  SELECT *,
         FORMAT_TIMESTAMP('%d/%m/%Y %H', PARSE_TIMESTAMP('%d/%m/%Y %H:%M:%S', DT_CONSULTA_HISTORICO)) AS HORA_CHAVE
  FROM `<project-id>.cz_api_coincap.cz_coincap_bnb`
)

SELECT
  crypto.ID_CRIPTO,                         -- Identificador da criptomoeda
  crypto.NR_POSICAO_RANK,                  -- Posição no ranking de capitalização de mercado
  crypto.DS_SIGLA_ATIVO,                   -- Sigla da criptomoeda
  crypto.NM_ATIVO,                         -- Nome da criptomoeda
  crypto.QT_EM_CIRCULACAO,                 -- Quantidade em circulação
  crypto.QT_MAXIMA_EMISSAO,                -- Quantidade máxima de emissão
  crypto.VL_CAPITALIZACAO_MERCADO,         -- Valor de capitalização de mercado
  crypto.VL_VOLUME_24H,                    -- Volume de transações nas últimas 24h
  crypto.VL_PRECO_ATUAL,                   -- Preço atual da criptomoeda
  crypto.PC_VARIACAO_24H,                  -- Porcentagem de variação nas últimas 24h
  crypto.VL_PRECO_MEDIO_24H,               -- Preço médio nas últimas 24h
  crypto.LINK_EXPLORADOR,                  -- Link para o explorador da blockchain
  crypto.DT_CONSULTA AS DT_CONSULTA_CRYPTO, -- Data/hora da coleta dos dados da crypto

  market.ID_EXCHANGE,                      -- ID da exchange de mercado
  market.ID_ATIVO_BASE,                    -- ID do ativo base negociado
  market.ID_ATIVO_COTACAO,                 -- ID do ativo de cotação
  market.SIGLA_ATIVO_BASE,                 -- Sigla do ativo base
  market.SIGLA_ATIVO_COTACAO,              -- Sigla do ativo de cotação
  market.VL_PRECO_MERCADO,                 -- Preço de mercado do ativo
  market.VL_VOLUME_24H_MERCADO,            -- Volume negociado em 24h no mercado
  market.PC_VOLUME_MERCADO,                -- Porcentagem de volume de mercado
  market.DT_CONSULTA AS DT_CONSULTA_MARKET, -- Data/hora da coleta de mercado

  btc.VL_PRECO_HISTORICO AS BTC_PRECO,              -- Preço histórico do Bitcoin
  btc.DT_CONSULTA_HISTORICO AS BTC_DATA_HORA,       -- Data/hora do histórico BTC

  eth.VL_PRECO_HISTORICO AS ETH_PRECO,              -- Preço histórico do Ethereum
  eth.DT_CONSULTA_HISTORICO AS ETH_DATA_HORA,       -- Data/hora do histórico ETH

  bnb.VL_PRECO_HISTORICO AS BNB_PRECO,              -- Preço histórico do BNB
  bnb.DT_CONSULTA_HISTORICO AS BNB_DATA_HORA        -- Data/hora do histórico BNB

FROM crypto_base AS crypto
LEFT JOIN market_base AS market
  ON crypto.ID_CRIPTO = market.ID_CRIPTO AND crypto.HORA_CHAVE = market.HORA_CHAVE
LEFT JOIN btc_base AS btc
  ON crypto.ID_CRIPTO = 'bitcoin' AND crypto.HORA_CHAVE = btc.HORA_CHAVE
LEFT JOIN eth_base AS eth
  ON crypto.ID_CRIPTO = 'ethereum' AND crypto.HORA_CHAVE = eth.HORA_CHAVE
LEFT JOIN bnb_base AS bnb
  ON crypto.ID_CRIPTO = 'binance-coin' AND crypto.HORA_CHAVE = bnb.HORA_CHAVE

ORDER BY crypto.DT_CONSULTA DESC, crypto.NR_POSICAO_RANK ASC;
