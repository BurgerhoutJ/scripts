# Connect to Exchange Online and create a resource
Set-ExecutionPolicy RemoteSigned
Import-Module ExchangeOnlineManagement
$UserCredential = Get-Credential
$Session = Connect-ExchangeOnline -UserPrincipalName $UserCredential -Credential $UserCredential
New-Mailbox -Name "MTR-TeamsRoom" -Alias TeamsRoom -Room -EnableRoomMailboxAccount $true -MicrosoftOnlineServicesID MTR-TeamsRoom@theorange.cat -RoomMailboxPassword (ConvertTo-SecureString -String '<password>' -AsPlainText -Force)
Set-CalendarProcessing -Identity "MTR-TeamsRoom" -AutomateProcessing AutoAccept -AllowConflicts $false -AddOrganizerToSubject $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -AddAdditionalResponse $true -AdditionalResponse "This is a Microsoft Teams Room!"

#Sleep for 20 seconds
Start-Sleep 20

#Connect to MS Online to set password to never expires
Connect-MsolService -Credential $UserCredential
Set-MsolUser -UserPrincipalName MTR-TeamsRoom@theorange.cat -PasswordNeverExpires $true
Get-MsolUser -UserPrincipalName MTR-TeamsRoom@theorange.cat | Select PasswordNeverExpires
