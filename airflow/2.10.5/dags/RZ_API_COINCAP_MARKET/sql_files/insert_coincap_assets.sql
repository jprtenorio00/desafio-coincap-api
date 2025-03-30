DELETE FROM `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_market` WHERE TRUE;

INSERT INTO `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_market` (
  cryptoId,
  exchangeId,
  baseId,
  quoteId,
  baseSymbol,
  quoteSymbol,
  priceUsd,
  volumeUsd24Hr,
  volumePercent
)
SELECT
  cryptoId,
  exchangeId,
  baseId,
  quoteId,
  baseSymbol,
  quoteSymbol,
  priceUsd,
  volumeUsd24Hr,
  volumePercent
FROM UNNEST([
  {values}
]);
