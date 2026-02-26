-- Table A3. PS/OTPS Composition of Distributed Cuts
-- Source: omb.expense_budget (Socrata mwzb-yiwb)
-- FY2018-2025 from expense_budget_meta preliminary cycle;
-- FY2027 direct (pub_date 20260217, excludes 99C holding line).
-- Intra-city excluded: object_code !~ '^[0-9]{2}[A-Z]$'

WITH prelim AS (
  SELECT fiscal_year::int AS fy, publication_date
  FROM omb.expense_budget_meta
  WHERE cycle_name = 'preliminary'
    AND fiscal_year::int BETWEEN 2018 AND 2025
),
cuts_historical AS (
  SELECT
    p.fy,
    SUM(
      CASE
        WHEN b.financial_plan_savings_flag = 'Y'
         AND COALESCE(b.financial_plan_amount, 0) < 0
          THEN -b.financial_plan_amount
        ELSE 0
      END
    ) AS gross_cut_dollars,
    SUM(
      CASE
        WHEN b.financial_plan_savings_flag = 'Y'
         AND COALESCE(b.financial_plan_amount, 0) < 0
         AND COALESCE(b.personal_service_other_than_personal_service_indicator, '?') IN ('P', 'PS')
          THEN -b.financial_plan_amount
        ELSE 0
      END
    ) AS ps_gross_cut_dollars
  FROM prelim p
  JOIN omb.expense_budget b
    ON b.fiscal_year::int = p.fy
   AND b.publication_date = p.publication_date
  WHERE b.object_code !~ '^[0-9]{2}[A-Z]$'
  GROUP BY 1
),
cuts_fy27 AS (
  SELECT
    2027 AS fy,
    SUM(
      CASE
        WHEN financial_plan_savings_flag = 'Y'
         AND COALESCE(financial_plan_amount, 0) < 0
          THEN -financial_plan_amount
        ELSE 0
      END
    ) AS gross_cut_dollars,
    SUM(
      CASE
        WHEN financial_plan_savings_flag = 'Y'
         AND COALESCE(financial_plan_amount, 0) < 0
         AND COALESCE(personal_service_other_than_personal_service_indicator, '?') IN ('P', 'PS')
          THEN -financial_plan_amount
        ELSE 0
      END
    ) AS ps_gross_cut_dollars
  FROM omb.expense_budget
  WHERE publication_date = '20260217'
    AND fiscal_year = 2027
    AND agency_number != '99C'
    AND object_code !~ '^[0-9]{2}[A-Z]$'
),
all_cuts AS (
  SELECT * FROM cuts_historical
  UNION ALL
  SELECT * FROM cuts_fy27
)
SELECT
  fy,
  ROUND((gross_cut_dollars / 1e6)::numeric, 0) AS gross_cuts_m,
  ROUND((100.0 * ps_gross_cut_dollars / NULLIF(gross_cut_dollars, 0))::numeric, 1) AS ps_share_pct
FROM all_cuts
ORDER BY fy;
