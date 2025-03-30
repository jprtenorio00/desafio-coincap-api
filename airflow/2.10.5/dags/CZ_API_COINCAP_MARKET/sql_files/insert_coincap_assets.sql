INSERT INTO `inspired-nomad-455114-k3.cz_api_coincap.cz_coincap_market` (
  ID_CRIPTO,
  ID_EXCHANGE,
  ID_ATIVO_BASE,
  ID_ATIVO_COTACAO,
  SIGLA_ATIVO_BASE,
  SIGLA_ATIVO_COTACAO,
  VL_PRECO_MERCADO,
  VL_VOLUME_24H_MERCADO,
  PC_VOLUME_MERCADO,
  DT_CONSULTA
)
SELECT
  ID_CRIPTO,
  ID_EXCHANGE,
  ID_ATIVO_BASE,
  ID_ATIVO_COTACAO,
  SIGLA_ATIVO_BASE,
  SIGLA_ATIVO_COTACAO,
  VL_PRECO_MERCADO,
  VL_VOLUME_24H_MERCADO,
  PC_VOLUME_MERCADO,
  FORMAT_TIMESTAMP('%d/%m/%Y %H:%M:%S', CURRENT_TIMESTAMP(), 'America/Sao_Paulo') AS DT_CONSULTA
FROM `inspired-nomad-455114-k3.sz_api_coincap.sz_coincap_market`
WHERE ID_CRIPTO IS NOT NULL;
