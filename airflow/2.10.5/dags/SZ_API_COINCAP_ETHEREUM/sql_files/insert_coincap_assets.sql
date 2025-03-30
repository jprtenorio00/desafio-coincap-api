CREATE OR REPLACE TABLE `inspired-nomad-455114-k3.sz_api_coincap.sz_coincap_ethereum` AS
SELECT
  id AS ID_CRIPTO,
  FORMAT('%.2f', CAST(priceUsd AS FLOAT64)) AS VL_PRECO_HISTORICO,
  time AS DT_CONSULTA_TIMESTAMP,
  FORMAT_DATETIME('%d/%m/%Y %H:%M:%S', DATETIME(TIMESTAMP(date), "America/Sao_Paulo")) AS DT_CONSULTA_HISTORICO
FROM `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_ethereum`
WHERE priceUsd IS NOT NULL;
