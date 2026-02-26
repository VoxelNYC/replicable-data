-- Table 4. PEG Negotiation Curve: FY26 (Adams Administration)
-- Source: omb.expense_budget (Socrata mwzb-yiwb)
-- fiscal_year = 2026, savings_flag = 'Y', grouped by publication_date.
-- Shows Preliminary → Executive → Adopted compression.

SELECT
  CASE publication_date
    WHEN '20250116' THEN 'Preliminary (Jan 2025)'
    WHEN '20250501' THEN 'Executive (May 2025)'
    WHEN '20250630' THEN 'Adopted (Jun 2025)'
    ELSE publication_date
  END AS vintage,
  publication_date AS pub_date_raw,
  ROUND(SUM(CASE WHEN financial_plan_amount < 0
    THEN financial_plan_amount ELSE 0 END) / 1e6, 0) AS gross_cuts_m,
  ROUND(SUM(CASE WHEN financial_plan_amount > 0
    THEN financial_plan_amount ELSE 0 END) / 1e6, 0) AS restorations_m,
  ROUND(SUM(financial_plan_amount) / 1e6, 0) AS net_m
FROM omb.expense_budget
WHERE fiscal_year = 2026
  AND financial_plan_savings_flag = 'Y'
GROUP BY 1, 2
ORDER BY pub_date_raw;
