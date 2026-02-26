#!/usr/bin/env python3
"""Upload 6 charts for 'Three Documents, One Budget' to Datawrapper.

Usage:
  python3 replicable-data/substack/three-documents-one-budget/upload_charts.py
"""
import json
import os
import sys
from pathlib import Path

# Add voxelnyc/scripts to path for DatawrapperClient
sys.path.insert(0, str(Path(__file__).resolve().parents[3] / "voxelnyc" / "scripts"))
from datawrapper_draft_preparer import DatawrapperClient, _load_token_from_env_local

CHARTS = [
    {
        "dir": "chart-1",
        "title": "Table 1. Initiative Ledger: Agency 992 (February 2026 Financial Plan)",
        "source_name": "omb.financial_plan_initiatives (Socrata e64w-ctmw), pub_date 20260217",
    },
    {
        "dir": "chart-2",
        "title": "Table 2. Sufficiency Scorecard (February 2026 Financial Plan)",
        "source_name": "omb.expense_plan_adpt_prel + omb.financial_plan_initiatives, pub_date 20260217",
    },
    {
        "dir": "chart-3",
        "title": "Table 3. Where the Savings-Flagged Money Is (FY27)",
        "source_name": "omb.expense_budget (Socrata mwzb-yiwb), pub_date 20260217",
    },
    {
        "dir": "chart-4",
        "title": "Table 4. PEG Negotiation Curve: FY26 (Adams Administration)",
        "source_name": "omb.expense_budget (Socrata mwzb-yiwb), FY2026 savings-flagged",
    },
    {
        "dir": "chart-5",
        "title": "Table A3. PS/OTPS Composition of Distributed Cuts",
        "source_name": "omb.expense_budget (Socrata mwzb-yiwb), Preliminary vintages FY2018-2027",
    },
    {
        "dir": "chart-6",
        "title": "Appendix B. Inferring How These Budgets Relate",
        "source_name": "Data patterns in omb.expense_budget and omb.financial_plan_initiatives",
    },
]

ARTICLE_FOLDER_NAME = "Three Documents, One Budget"


def main():
    token = os.environ.get("DATAWRAPPER_TOKEN") or _load_token_from_env_local()
    if not token:
        print("Missing DATAWRAPPER_TOKEN", file=sys.stderr)
        return 1

    client = DatawrapperClient(token)
    base_dir = Path(__file__).resolve().parent

    # Find or create folder
    folders = client.list_folders()
    folder_id = None
    for f in folders:
        if f.get("name") == ARTICLE_FOLDER_NAME:
            folder_id = f["id"]
            break
    if folder_id is None:
        # Check nested folders
        for f in folders:
            for child in f.get("children", []):
                if child.get("name") == ARTICLE_FOLDER_NAME:
                    folder_id = child["id"]
                    break
            if folder_id:
                break

    if folder_id:
        print(f"Found folder '{ARTICLE_FOLDER_NAME}' (id={folder_id})")
    else:
        print(f"Folder '{ARTICLE_FOLDER_NAME}' not found. Creating charts without folder.")

    results = []
    for chart_spec in CHARTS:
        csv_path = base_dir / chart_spec["dir"] / "data.csv"
        csv_text = csv_path.read_text(encoding="utf-8")

        created = client.create_chart(
            title=chart_spec["title"],
            chart_type="tables",
            folder_id=folder_id,
        )
        chart_id = created["id"]
        client.upload_csv_data(chart_id, csv_text)
        client.patch_chart(chart_id, {
            "metadata": {
                "describe": {
                    "source-name": chart_spec["source_name"],
                    "source-url": "https://voxelnyc.substack.com",
                },
            },
        })
        edit_url = f"https://app.datawrapper.de/chart/{chart_id}"
        print(f"  {chart_spec['dir']}: {chart_spec['title']}")
        print(f"    Edit: {edit_url}")
        results.append({"dir": chart_spec["dir"], "chart_id": chart_id, "edit_url": edit_url})

    print(f"\nAll {len(results)} charts created.")
    for r in results:
        print(f"  {r['dir']}: {r['edit_url']}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
