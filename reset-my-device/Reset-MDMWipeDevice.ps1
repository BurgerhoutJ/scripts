# Reset and wipe an Intune managed Windows 10/11 device
# Created by Jeroen Burgerhout (@BurgerhoutJ)

# Create a tag file just so Intune knows this was installed (Just for the fun)
if (-not (Test-Path "$($env:ProgramData)\TheOrangeCat\ResetMDMDevice"))
{
    Mkdir "$($env:ProgramData)\TheOrangeCat\ResetMDMDevice"
}
Set-Content -Path "$($env:ProgramData)TheOrangeCat\ResetMDMDevice\Reset-MDMWipeDevice.ps1.tag" -Value "Installed"

# Show a messagebox where the enduser can accept or decline the reset
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form.
$form  = New-Object system.Windows.Forms.Form
$form.Width   = "400"
$form.Height  = "375"
$form.Text = "Reset My Device"
$form.AutoSize = $true
$form.Topmost = $true
$form.StartPosition = "CenterScreen"
$form.BackColor = "Orange"
$form.ForeColor = "Black"
# This base64 string holds the bytes that make up the Waternet icon for a 32x32 pixel image
$iconBase64      = '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'
$iconBytes       = [Convert]::FromBase64String($iconBase64)
# initialize a Memory stream holding the bytes
$stream          = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
$Form.Icon       = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))

$TextBox = New-Object System.Windows.Forms.label
$TextBox.Location = New-Object System.Drawing.Size(10,10)
$TextBox.Size = New-Object System.Drawing.Size(400,250)
$TextBox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)
$TextBox.BackColor = "Transparent"
$TextBox.Font = "Segoe UI, 10"
$TextBox.Text = "CAUTION!
Starting this app will reinstall your device.

ATTENTION!
The hard drive on your device will be totally erased during this action. So only proceed if your important files are stored on OneDrive or SharePoint and the synchronization is complete!

IMPORTANT!
During this entire action, the laptop must be powered. So make sure your device is directly connected to a charger or docking station before proceeding!

Click CONTINUE to start the reset or CANCEL to stop it."

$form.Controls.Add($TextBox)

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,300)
$okButton.Size = New-Object System.Drawing.Size(100,23)
$okButton.Text = 'CONTINUE'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(250,300)
$cancelButton.Size = New-Object System.Drawing.Size(100,23)
$cancelButton.Text = 'CANCEL'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::No
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$Result = $form.ShowDialog()

switch  ($Result) {

    'Yes' {

        # Dispose the form and its controls. Skip, if you want to redisplay the form later.
        $form.Close()
        $stream.Dispose()
        $form.Dispose()

        # And this is where the magic happens
        $namespaceName = "root\cimv2\mdm\dmmap"
        $className = "MDM_RemoteWipe"
        $methodName = "doWipeProtectedMethod" #change this to doWipeMethod if you run this app on Surface devices

        $session = New-CimSession

        $params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
        $param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", "", "String", "In")
        $params.Add($param)

        $instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "ParentID='./Vendor/MSFT' and InstanceID='RemoteWipe'"
        $session.InvokeMethod($namespaceName, $instance, $methodName, $params)

    }
    'No' {
        
        # Dispose the form and its controls. Skip, if you want to redisplay the form later.
        $form.Close()
        $stream.Dispose()
        $form.Dispose()
        exit
    }
}