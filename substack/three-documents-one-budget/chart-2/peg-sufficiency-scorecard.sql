-- Table 2. Sufficiency Scorecard (February 2026 Financial Plan)
-- Source: omb.expense_plan_adpt_prel + omb.financial_plan_initiatives
--
-- Operating city funds base = total city funds (line 729) minus central/pseudo agencies.
-- Savings = SAV type, "Projected Agency Savings," Agency 992.
-- Benchmark: 1.5% FY26, 2.5% FY27 (Executive Order 12).
-- Amounts in the source tables are in $thousands.

WITH latest_plan AS (
  SELECT MAX(pub_date) AS pub_date
  FROM omb.expense_plan_adpt_prel
),
latest_inits AS (
  SELECT MAX(pub_date) AS pub_date
  FROM omb.financial_plan_initiatives
),
agency_city_funds AS (
  SELECT
    CASE
      WHEN p.agency_cd ~ '^[0-9]+$' THEN LPAD(p.agency_cd, 3, '0')
      ELSE UPPER(p.agency_cd)
    END AS agency_code,
    SUM(CASE WHEN p.lineno = '729' THEN COALESCE(p.year1_frcst, 0) ELSE 0 END) AS fy26_city_k,
    SUM(CASE WHEN p.lineno = '729' THEN COALESCE(p.year2_amt, 0) ELSE 0 END) AS fy27_city_k
  FROM omb.expense_plan_adpt_prel p
  JOIN latest_plan lp ON p.pub_date = lp.pub_date
  GROUP BY 1
),
operating_denominator AS (
  SELECT
    SUM(fy26_city_k) FILTER (
      WHERE agency_code NOT IN (
        '094', '095', '098', '099', '130', '138', '817',
        '991', '992', '993', '995', '996', '997', '998', '999',
        '99C', '99P', '99S'
      )
    ) AS fy26_operating_city_k,
    SUM(fy27_city_k) FILTER (
      WHERE agency_code NOT IN (
        '094', '095', '098', '099', '130', '138', '817',
        '991', '992', '993', '995', '996', '997', '998', '999',
        '99C', '99P', '99S'
      )
    ) AS fy27_operating_city_k
  FROM agency_city_funds
),
projected_agency_savings AS (
  SELECT
    ABS(SUM(COALESCE(i.fy1_amt, 0))) AS fy26_savings_k,
    ABS(SUM(COALESCE(i.fy2_amt, 0))) AS fy27_savings_k
  FROM omb.financial_plan_initiatives i
  JOIN latest_inits li ON i.pub_date = li.pub_date
  WHERE i.init_type = 'SAV'
    AND i.init_nm = 'Projected Agency Savings'
)
SELECT
  x.fy,
  ROUND(x.operating_city_k / 1000.0, 0) AS operating_city_funds_m,
  ROUND(x.savings_k / 1000.0, 0) AS projected_agency_savings_m,
  ROUND(100.0 * x.savings_k / NULLIF(x.operating_city_k, 0), 1) AS savings_pct_of_base,
  x.benchmark_pct,
  ROUND(x.operating_city_k * x.benchmark_pct / 100.0 / 1000.0, 0) AS benchmark_m,
  ROUND((x.operating_city_k * x.benchmark_pct / 100.0 - x.savings_k) / 1000.0, 0) AS gap_m
FROM operating_denominator od
CROSS JOIN projected_agency_savings pas
CROSS JOIN LATERAL (
  VALUES
    (2026, od.fy26_operating_city_k, pas.fy26_savings_k, 1.5::numeric),
    (2027, od.fy27_operating_city_k, pas.fy27_savings_k, 2.5::numeric)
) AS x(fy, operating_city_k, savings_k, benchmark_pct)
ORDER BY x.fy;
