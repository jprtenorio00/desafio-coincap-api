DELETE FROM `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_bnb` WHERE TRUE;

INSERT INTO `inspired-nomad-455114-k3.rz_api_coincap.rz_coincap_bnb` (
  id,
  priceUsd,
  time,
  date
)
SELECT
  id,
  priceUsd,
  time,
  date
FROM UNNEST([
  {values}
]);
