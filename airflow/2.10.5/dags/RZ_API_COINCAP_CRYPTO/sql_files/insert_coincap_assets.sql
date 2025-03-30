DELETE FROM `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_crypto` WHERE TRUE;

INSERT INTO `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_crypto` (
  id, rank, symbol, name, supply, maxSupply,
  marketCapUsd, volumeUsd24Hr, priceUsd,
  changePercent24Hr, vwap24Hr, explorer
)
SELECT
  id, rank, symbol, name, supply, maxSupply,
  marketCapUsd, volumeUsd24Hr, priceUsd,
  changePercent24Hr, vwap24Hr, explorer
FROM UNNEST([
  {values}
]);
