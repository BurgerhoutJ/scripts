#!/usr/bin/env bash
# Deploys the Azure Automation Account + runbook + schedule for the Intune
# OS version compliance automation. Run this yourself (Cloud Shell or local
# az CLI) after `az login` with an account that can create resources in the
# target subscription.
#
# This script does NOT grant the Graph API permission — that needs a Global
# Administrator / Privileged Role Administrator and is a separate,
# deliberately manual step (see Grant-ManagedIdentityGraphPermissions.ps1).
#
# Usage:
#   ./deploy.sh -g <resource-group> -l <location> -a <automation-account-name> [-s <subscription-id>]

set -euo pipefail

RESOURCE_GROUP="rg-intune-automation"
LOCATION="westeurope"
AUTOMATION_ACCOUNT="aa-intune-osversion"
SUBSCRIPTION=""
RUNBOOK_NAME="rb-intune-osversion-compliance"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while getopts "g:l:a:s:" opt; do
  case $opt in
    g) RESOURCE_GROUP="$OPTARG" ;;
    l) LOCATION="$OPTARG" ;;
    a) AUTOMATION_ACCOUNT="$OPTARG" ;;
    s) SUBSCRIPTION="$OPTARG" ;;
    *) echo "Unknown option"; exit 1 ;;
  esac
done

if [[ -z "$RESOURCE_GROUP" || -z "$AUTOMATION_ACCOUNT" ]]; then
  echo "Usage: $0 -g <resource-group> -l <location> -a <automation-account-name> [-s <subscription-id>]"
  exit 1
fi

if [[ -n "$SUBSCRIPTION" ]]; then
  az account set --subscription "$SUBSCRIPTION"
fi

echo "==> Resource group"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

echo "==> Automation Account (system-assigned identity)"
az automation account create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AUTOMATION_ACCOUNT" \
  --location "$LOCATION" \
  --assign-identity '[system]' \
  --output none

echo "==> Runbook (PowerShell 7.2)"
az automation runbook create \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "$RUNBOOK_NAME" \
  --type PowerShell72 \
  --output none

az automation runbook replace-content \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "$RUNBOOK_NAME" \
  --content "@${SCRIPT_DIR}/Update-IntuneOSVersionCompliance.ps1" \
  --output none

az automation runbook publish \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "$RUNBOOK_NAME" \
  --output none

echo "==> Variables (write-gate left empty on purpose - dry run until you opt in)"
az automation variable create \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "IntuneOSVersion-AutoApplyPlatforms" \
  --value '""' \
  --output none

az automation variable create \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "IntuneOSVersion-ExcludePolicyIds" \
  --value '""' \
  --output none

echo "==> Weekly schedule (Mondays 06:00 UTC) linked to the runbook"
START_TIME=$(date -u -d "next monday 06:00" +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || date -u -v+monday -v6H -v0M -v0S +"%Y-%m-%dT%H:%M:%S+00:00")

az automation schedule create \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --name "Weekly-IntuneOSVersionCheck" \
  --frequency Week \
  --interval 1 \
  --start-time "$START_TIME" \
  --output none

az automation job-schedule create \
  --resource-group "$RESOURCE_GROUP" \
  --automation-account-name "$AUTOMATION_ACCOUNT" \
  --runbook-name "$RUNBOOK_NAME" \
  --schedule-name "Weekly-IntuneOSVersionCheck" \
  --parameters Apply=true \
  --output none

PRINCIPAL_ID=$(az automation account show \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AUTOMATION_ACCOUNT" \
  --query identity.principalId -o tsv)

echo ""
echo "Deployed. Managed identity object (principal) ID: $PRINCIPAL_ID"
echo ""
echo "Next step (needs a Global Administrator / Privileged Role Administrator):"
echo "  ./Grant-ManagedIdentityGraphPermissions.ps1 -AutomationAccountManagedIdentityObjectId \"$PRINCIPAL_ID\""
echo ""
echo "Until 'IntuneOSVersion-AutoApplyPlatforms' has platforms in it, every run is a dry run"
echo "regardless of the schedule's Apply=true parameter. Run the runbook manually first and"
echo "review its output before adding platforms to that variable."
