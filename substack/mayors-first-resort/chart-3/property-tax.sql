-- Table 3: Property Tax — November Plan baseline
-- Source: OMB Revenue Plan Qtr1 (Socrata vf4p-p8ui)
-- Property Tax Increase line and Preliminary combined totals from PDFs (see README)

SELECT
  revenue_source_name,
  ROUND(yr1_fp_rev_amt / 1e9, 2) AS fy26_b,
  ROUND(yr2_fp_rev_amt / 1e9, 2) AS fy27_b,
  ROUND(yr3_fp_rev_amt / 1e9, 2) AS fy28_b,
  ROUND(yr4_fp_rev_amt / 1e9, 2) AS fy29_b
FROM omb.revenue_plan_qtr1
WHERE publication_date = '2025 11 17'
  AND LOWER(revenue_source_name) LIKE '%property%'
ORDER BY yr1_fp_rev_amt DESC;
