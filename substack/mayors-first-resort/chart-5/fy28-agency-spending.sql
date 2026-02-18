-- Table 5: FY28 Expenditure — November Plan vs. Preliminary Budget, Top Agencies
-- Source: OMB Expense Plan Qtr1 (Socrata sqmu-2ixd)
-- Preliminary figures from FY27 Financial Plan PDF (pp.2–88, line 728 per agency)
-- Amounts in thousands → divide by 1e3 for millions

SELECT
  agency_name,
  ROUND(SUM(year_3_estimate) / 1e3, 0) AS nov_fy28_m
FROM omb.expense_plan_qtr1
WHERE publication_date = '20251117'
  AND line_number = '728'
GROUP BY agency_name
ORDER BY nov_fy28_m DESC
LIMIT 10;
