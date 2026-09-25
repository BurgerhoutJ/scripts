<#
.SYNOPSIS
    Detects whether Company Branding is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
.NOTES
    Script: Detect-CompanyBranding.ps1
#>

<#
  .NOTES
  ===========================================================================
   Created on:   	11.07.2023
   Created by:   	Simon Skotheimsvik
   Filename:     	Branding-Detection.ps1
   Info:          https://skotheimsvik.no
  ===========================================================================
  
  .DESCRIPTION
    This script sets the support information for Windows10 and Windows 11
    The information is found in "Settings - System - About - Support" and in "WinVer"
    The script can be assigned as Detection script in Microsoft Intune
    
#>

$BrandingContent = @"
RegKeyPath,Key,Value
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation","SupportURL","https://thepeskyghosts.sharepoint.com/sites/ITServicedesk"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation","Manufacturer","The Pesky Ghosts"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation","SupportHours","Standard: 0700-1700, Extended: 24-7-365"
"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation","SupportPhone","+31 6 28 25 71 24"
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion","RegisteredOwner","The Pesky Ghosts"
"HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion","RegisteredOrganization","The Pesky Ghosts"
"@

$Branding = $BrandingContent | ConvertFrom-Csv -delimiter ","

foreach ($Brand in $Branding) {
    $ExistingValue = (Get-Item -Path $($Brand.RegKeyPath)).GetValue($($Brand.Key))
    if ($ExistingValue -ne $($Brand.Value)) {
      Write-Host $($Brand.Key) "Not Equal"
      Exit 1
      Exit #Remediation 
    }
    else {
#      Write-Host $($Brand.Key) "Equal"
    }
}
Exit 0