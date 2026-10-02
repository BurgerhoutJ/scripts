<#
.SYNOPSIS
    Starts Windows Update, checks for updates, and downloads available updates.
.DESCRIPTION
    Uses the Windows Update Agent API with the device's configured update source.
    Accepts update license agreements as needed. Does not install updates, restart
    the device, reset the update cache, or change service or update policies.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Download available updates on managed Windows devices without requesting installation or restart.
    What it does: Starts Windows Update and BITS, scans for updates, and downloads updates not already downloaded.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Exit 0 = Scan and download succeeded, or no updates require downloading
    Exit 1 = Scan or download failed
    Scan and download are synchronous and subject to Intune's execution timeout.
#>

$ErrorActionPreference = 'Stop'

try {
    Start-Service -Name wuauserv -ErrorAction Stop
    Start-Service -Name bits -ErrorAction Stop

    $Session = New-Object -ComObject Microsoft.Update.Session
    $Session.ClientApplicationID = 'Intune Windows Update Download'
    $Searcher = $Session.CreateUpdateSearcher()
    $Searcher.Online = $true
    $SearchResult = $Searcher.Search("IsInstalled=0 and IsHidden=0 and DeploymentAction='Installation'")

    if ($SearchResult.ResultCode -ne 2) {
        throw "Windows Update scan did not fully succeed. Result code: $($SearchResult.ResultCode)."
    }

    $UpdatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
    foreach ($Update in $SearchResult.Updates) {
        if (-not $Update.IsDownloaded) {
            if (-not $Update.EulaAccepted) {
                $Update.AcceptEula()
            }
            [void]$UpdatesToDownload.Add($Update)
        }
    }

    if ($UpdatesToDownload.Count -eq 0) {
        Write-Output "Scan complete. No updates require downloading."
        exit 0
    }

    $Downloader = $Session.CreateUpdateDownloader()
    $Downloader.Updates = $UpdatesToDownload
    $DownloadResult = $Downloader.Download()

    if ($DownloadResult.ResultCode -ne 2) {
        throw "Download did not fully succeed for $($UpdatesToDownload.Count) update(s). Result code: $($DownloadResult.ResultCode); HRESULT: $($DownloadResult.HResult)."
    }

    Write-Output "Scan complete. Downloaded $($UpdatesToDownload.Count) update(s). No installation or restart requested."
    exit 0
}
catch {
    Write-Output "Windows Update scan/download failed: $($_.Exception.Message)"
    exit 1
}