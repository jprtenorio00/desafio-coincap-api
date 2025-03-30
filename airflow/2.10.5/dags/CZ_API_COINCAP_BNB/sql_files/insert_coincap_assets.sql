MERGE `inspired-nomad-455114-k3.cz_api_coincap.cz_coincap_bnb` AS destino
USING (
  SELECT
    ID_CRIPTO,
    VL_PRECO_HISTORICO,
    DT_CONSULTA_TIMESTAMP,
    DT_CONSULTA_HISTORICO
  FROM `inspired-nomad-455114-k3.sz_api_coincap.sz_coincap_bnb`
  WHERE VL_PRECO_HISTORICO IS NOT NULL
) AS origem
ON destino.DT_CONSULTA_TIMESTAMP = origem.DT_CONSULTA_TIMESTAMP
WHEN NOT MATCHED THEN
  INSERT (
    ID_CRIPTO,
    VL_PRECO_HISTORICO,
    DT_CONSULTA_TIMESTAMP,
    DT_CONSULTA_HISTORICO
  )
  VALUES (
    origem.ID_CRIPTO,
    origem.VL_PRECO_HISTORICO,
    origem.DT_CONSULTA_TIMESTAMP,
    origem.DT_CONSULTA_HISTORICO
  );