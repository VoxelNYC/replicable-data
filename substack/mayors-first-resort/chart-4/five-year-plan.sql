-- Table 4: Five-Year Financial Plan — November Plan vs. Preliminary Budget
-- Sources: OMB Expense Plan Qtr1 (sqmu-2ixd) + Revenue Plan Qtr1 (vf4p-p8ui)
-- Preliminary Budget rows from FY27 Financial Plan Summary PDF (pp.21–40, All Funds)

-- November Plan total expenditures by year (amounts in thousands, dividing by 1e6 = billions)
SELECT
  'Nov Plan Expenditure' AS source,
  SUM(year_1_forecast) / 1e6 AS fy26_b,
  SUM(year_2_estimate) / 1e6 AS fy27_b,
  SUM(year_3_estimate) / 1e6 AS fy28_b,
  SUM(year_4_estimate) / 1e6 AS fy29_b
FROM omb.expense_plan_qtr1
WHERE publication_date = '20251117'
  AND line_number = '728';

-- November Plan total revenue by year (amounts in dollars, dividing by 1e9 = billions)
SELECT
  'Nov Plan Revenue' AS source,
  ROUND(SUM(yr1_fp_rev_amt) / 1e9, 2) AS fy26_rev_b,
  ROUND(SUM(yr2_fp_rev_amt) / 1e9, 2) AS fy27_rev_b,
  ROUND(SUM(yr3_fp_rev_amt) / 1e9, 2) AS fy28_rev_b,
  ROUND(SUM(yr4_fp_rev_amt) / 1e9, 2) AS fy29_rev_b
FROM omb.revenue_plan_qtr1
WHERE publication_date = '2025 11 17';
