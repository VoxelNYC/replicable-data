-- Table 3. Where the Savings-Flagged Money Is (FY27)
-- Source: omb.expense_budget (Socrata mwzb-yiwb)
-- publication_date 20260217, fiscal_year 2027, savings_flag = 'Y'
-- 404 lines across 73 agencies.

WITH raw AS (
  SELECT
    agency_number,
    MAX(agency_name) AS agency_name,
    SUM(CASE WHEN financial_plan_amount < 0
      THEN financial_plan_amount ELSE 0 END) AS cuts,
    SUM(CASE WHEN financial_plan_amount > 0
      THEN financial_plan_amount ELSE 0 END) AS restorations,
    SUM(financial_plan_amount) AS net
  FROM omb.expense_budget
  WHERE publication_date = '20260217'
    AND fiscal_year = 2027
    AND financial_plan_savings_flag = 'Y'
  GROUP BY 1
),
named AS (
  SELECT *,
    CASE agency_number
      WHEN '99C' THEN '99C Citywide Savings'
      WHEN '095' THEN 'Pensions (095)'
      WHEN '040' THEN 'DOE (040)'
      WHEN '826' THEN 'DEP (826)'
      WHEN '858' THEN 'DoITT (858)'
      WHEN '856' THEN 'DCAS (856)'
      WHEN '846' THEN 'Parks (846)'
      WHEN '056' THEN 'NYPD (056)'
      WHEN '057' THEN 'FDNY (057)'
      WHEN '841' THEN 'DOT (841)'
      WHEN '025' THEN 'Law Dept (025)'
      WHEN '125' THEN 'DFTA (125)'
      WHEN '260' THEN 'DYCD (260)'
      WHEN '99P' THEN 'Energy Adj (99P)'
      WHEN '071' THEN 'DHS (071)'
      WHEN '827' THEN 'Sanitation (827)'
      WHEN '068' THEN 'ACS (068)'
      ELSE NULL
    END AS display_name
  FROM raw
),
bucketed AS (
  -- Named agencies
  SELECT
    display_name AS agency,
    cuts, restorations, net,
    CASE display_name
      WHEN '99C Citywide Savings' THEN 1
      WHEN 'Pensions (095)' THEN 2
      WHEN 'DOE (040)' THEN 3
      WHEN 'DEP (826)' THEN 4
      WHEN 'DoITT (858)' THEN 5
      WHEN 'DCAS (856)' THEN 6
      WHEN 'Parks (846)' THEN 7
      WHEN 'NYPD (056)' THEN 8
      WHEN 'FDNY (057)' THEN 9
      WHEN 'DOT (841)' THEN 10
      WHEN 'Law Dept (025)' THEN 11
      WHEN 'DFTA (125)' THEN 12
      WHEN 'DYCD (260)' THEN 13
      WHEN 'Energy Adj (99P)' THEN 14
      WHEN 'DHS (071)' THEN 15
      WHEN 'Sanitation (827)' THEN 16
      WHEN 'ACS (068)' THEN 17
    END AS sort_order
  FROM named
  WHERE display_name IS NOT NULL

  UNION ALL

  -- All others bucket
  SELECT
    'All others' AS agency,
    SUM(cuts), SUM(restorations), SUM(net),
    18 AS sort_order
  FROM named
  WHERE display_name IS NULL

  UNION ALL

  -- Total row
  SELECT
    'Total' AS agency,
    SUM(cuts), SUM(restorations), SUM(net),
    19 AS sort_order
  FROM raw
)
SELECT
  agency,
  ROUND(cuts / 1e6, 1) AS gross_cuts_m,
  ROUND(restorations / 1e6, 1) AS restorations_m,
  ROUND(net / 1e6, 1) AS net_m
FROM bucketed
ORDER BY sort_order;
