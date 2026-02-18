-- Table 2: General Reserve (Contemporaneous November Plan), FY2017–FY2027
-- Source: OMB Expense Plan Qtr1 (Socrata sqmu-2ixd)
-- Amounts in thousands; dividing by 1000 converts to millions
-- Uses earliest publication per fiscal year for contemporaneous figure
-- NOTE: FY2020 and FY2022 are missing from Socrata; see November Plan PDFs

SELECT DISTINCT ON (fiscal_year_1)
       fiscal_year_1 AS fy,
       publication_date,
       year_1_forecast / 1000.0 AS fy1_adopted_m
FROM omb.expense_plan_qtr1
WHERE agency_name = 'General Reserve'
  AND line_number = '704'
ORDER BY fiscal_year_1, publication_date ASC;
