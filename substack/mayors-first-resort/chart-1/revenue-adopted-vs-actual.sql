-- Table 1: City Funds Revenue — Adopted vs. Actual, FY2017–FY2025
-- Source: OMB Revenue Budget (Socrata ugzk-a6x4)
-- "Adopted" = adopted_budget_amount from earliest publication per fiscal year
-- "Actual (Modified)" = current_modified_budget_amount from latest publication per fiscal year

WITH pubs AS (
  SELECT fiscal_year,
         MIN(publication_date) AS first_pub,
         MAX(publication_date) AS last_pub
  FROM omb.revenue_budget
  WHERE funding_source_name = 'City Funds'
  GROUP BY fiscal_year
),
adopted AS (
  SELECT r.fiscal_year, SUM(r.adopted_budget_amount) AS adopted_total
  FROM omb.revenue_budget r
  JOIN pubs p ON r.fiscal_year = p.fiscal_year
             AND r.publication_date = p.first_pub
  WHERE r.funding_source_name = 'City Funds'
  GROUP BY r.fiscal_year
),
modified AS (
  SELECT r.fiscal_year, SUM(r.current_modified_budget_amount) AS modified_total
  FROM omb.revenue_budget r
  JOIN pubs p ON r.fiscal_year = p.fiscal_year
             AND r.publication_date = p.last_pub
  WHERE r.funding_source_name = 'City Funds'
  GROUP BY r.fiscal_year
)
SELECT
  a.fiscal_year,
  ROUND(a.adopted_total / 1e9, 2) AS adopted_b,
  ROUND(m.modified_total / 1e9, 2) AS modified_b,
  ROUND((m.modified_total - a.adopted_total) / 1e9, 2) AS delta_b,
  ROUND((m.modified_total - a.adopted_total) / a.adopted_total * 100, 1) AS pct_over
FROM adopted a JOIN modified m ON a.fiscal_year = m.fiscal_year
ORDER BY a.fiscal_year;
