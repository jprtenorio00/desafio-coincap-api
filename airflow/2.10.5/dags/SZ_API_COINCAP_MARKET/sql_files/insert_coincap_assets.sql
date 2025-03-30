CREATE OR REPLACE TABLE `inspired-nomad-455114-k3.sz_api_coincap.sz_coincap_market` AS
SELECT
  cryptoId AS ID_CRIPTO,
  exchangeId AS ID_EXCHANGE,
  baseId AS ID_ATIVO_BASE,
  quoteId AS ID_ATIVO_COTACAO,
  baseSymbol AS SIGLA_ATIVO_BASE,
  quoteSymbol AS SIGLA_ATIVO_COTACAO,
  FORMAT('%.2f', CAST(priceUsd AS FLOAT64)) AS VL_PRECO_MERCADO,
  FORMAT('%.2f', CAST(volumeUsd24Hr AS FLOAT64)) AS VL_VOLUME_24H_MERCADO,
  FORMAT('%.2f%%', CAST(volumePercent AS FLOAT64)) AS PC_VOLUME_MERCADO
FROM `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_market`
WHERE cryptoId IS NOT NULL;
