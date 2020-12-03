# Connect to Exchange Online and create a resource
Set-ExecutionPolicy RemoteSigned
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
New-Mailbox -Name "MTR-ConferenceRoom02" -Alias ConferenceRoom02 -Room -EnableRoomMailboxAccount $true -MicrosoftOnlineServicesID MTR-ConferenceRoom02@theorange.cat -RoomMailboxPassword (ConvertTo-SecureString -String '>4#nU+QX^eFHB&fzn}qw' -AsPlainText -Force)
Set-CalendarProcessing -Identity "MTR-ConferenceRoom02" -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse "This is a Microsoft Teams Room!"

#Sleep for 20 seconds
Start-Sleep 20

#Connect to MS Online to set password to never expires
Connect-MsolService -Credential $UserCredential
Set-MsolUser -UserPrincipalName MTR-ConferenceRoom02@theorange.cat -PasswordNeverExpires $true
Get-MsolUser -UserPrincipalName MTR-ConferenceRoom02@theorange.cat | Select PasswordNeverExpires

#Sleep for 300 seconds to populate the security group and assign a SfB account
Start-Sleep 300

#Enable account for SfB
Import-Module SkypeOnlineConnector
$cssess=New-CsOnlineSession -Credential $UserCredential
Import-PSSession $cssess -AllowClobber
$rm="MTR-ConferenceRoom02@theorange.cat"
Enable-CsMeetingRoom -Identity $rm -RegistrarPool "sippoolDB42E12.infra.lync.com" -SipAddressType EmailAddress