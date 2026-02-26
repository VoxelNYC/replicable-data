-- Table 1. Initiative Ledger: Agency 992 (February 2026 Financial Plan)
-- Source: omb.financial_plan_initiatives (Socrata e64w-ctmw)
-- Amounts in the source table are in $thousands.
-- Excludes SAVP (shadow copy) to avoid double-counting.

SELECT
  init_nm AS entry,
  init_type AS type,
  ROUND(SUM(fy1_amt) / 1000.0, 1) AS fy26_m,
  ROUND(SUM(fy2_amt) / 1000.0, 1) AS fy27_m
FROM omb.financial_plan_initiatives
WHERE pub_date = '20260217'
  AND agency_cd = '992'
  AND init_type IN ('SAV', 'BAS')
GROUP BY 1, 2

UNION ALL

SELECT
  'Total booked in Agency 992' AS entry,
  '' AS type,
  ROUND(SUM(fy1_amt) / 1000.0, 1) AS fy26_m,
  ROUND(SUM(fy2_amt) / 1000.0, 1) AS fy27_m
FROM omb.financial_plan_initiatives
WHERE pub_date = '20260217'
  AND agency_cd = '992'
  AND init_type IN ('SAV', 'BAS')

ORDER BY fy26_m DESC;
