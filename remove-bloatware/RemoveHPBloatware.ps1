# Remove Microsoft bloatware/crapware
# Original file https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388#file-remove-hpbloatware-ps1 
# and modified by Jeroen Burgerhout (@BurgerhoutJ)

# Create a tag file just so Intune knows this was installed
if (-not (Test-Path "$($env:ProgramData)\HP\RemoveHPBloatware"))
{
    Mkdir "$($env:ProgramData)\HP\RemoveHPBloatware"
}
Set-Content -Path "$($env:ProgramData)\HP\RemoveHPBloatware\RemoveHPBloatware.ps1.tag" -Value "Installed"

# Start logging
Start-Transcript "$($env:ProgramData)\HP\RemoveHPBloatware\RemoveHPBloatware.log"
# List of built-in apps to remove
$UninstallPackages = @(
    "AD2F1837.HPEasyClean"
    "AD2F1837.HPPCHardwareDiagnosticsWindows"
    "AD2F1837.HPPowerManager"
    "AD2F1837.HPPrivacySettings"
    "AD2F1837.HPProgrammableKey"
    "AD2F1837.HPQuickDrop"
    "AD2F1837.HPSupportAssistant"
    "AD2F1837.HPSystemInformation"
    "AD2F1837.HPWorkWell"
    "AD2F1837.myHP"
    "Tile.TileWindowsApplication"
)

# List of programs to uninstall
$UninstallPrograms = @(
    "HP Client Security Manager"
    "HP Notifications"
    "HP Security Update Service"
    "HP System Default Settings"
    "HP Wolf Security"
    "HP Wolf Security Application Support for Sure Sense"
    "HP Wolf Security Application Support for Windows"
)

$HPidentifier = "AD2F1837"

$InstalledPackages = Get-AppxPackage -AllUsers | Where {($UninstallPackages -contains $_.Name)} #-or ($_.Name -match "^$HPidentifier")}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where {($UninstallPackages -contains $_.DisplayName)} #-or ($_.DisplayName -match "^$HPidentifier")}

$InstalledPrograms = Get-Package | Where {$UninstallPrograms -contains $_.Name}

# Remove provisioned packages first
ForEach ($ProvPackage in $ProvisionedPackages) {

    Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

    Try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
        Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
}

# Remove appx packages
ForEach ($AppxPackage in $InstalledPackages) {
                                            
    Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
}

# Remove installed programs
$InstalledPrograms | ForEach {

    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
    }
    Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
}

Stop-Transcript