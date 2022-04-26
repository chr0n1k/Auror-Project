# End user feedback
Write-Host -ForegroundColor Green "Removing default password complexity policy..."

<#
The default password complexity policy doesn't allow the password 'vagrant' so we disable it.

WARNING: Obviously this is a bad idea, but this is a test/dev environment.
#>
secedit /export /cfg C:\Security-Policy.cfg
(Get-Content C:\Security-Policy.cfg).Replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File 'C:\Security-Policy.cfg'
secedit /configure /db C:\Windows\security\local.sdb /cfg C:\Security-Policy.cfg /areas SECURITYPOLICY
Remove-Item -Path 'C:\Security-Policy.cfg' -Confirm:$False -Force

# Set the default Administrator user password
$Password = ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force
$Administrator = Get-LocalUser -Name Administrator
$Administrator | Set-LocalUser -Password $Password

# End user feedback
Write-Host -ForegroundColor Green "Setting DNS server addresses. . ."

# Set DNS server addresses to use the loopback first and then Google DNS for any names it can't resolve.
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses 127.0.0.1, 8.8.8.8

# End user feedback
Write-Host -ForegroundColor Green "Installing Active Directory features. . ."

# Install the AD Domain Services features
Install-WindowsFeature Ad-Domain-Services, RSAT-Ad-AdminCenter, RSAT-AdDs-Tools

# End user feedback
Write-Host -ForegroundColor Green "Creating Active Directory forest. . ."

# Create password as secure string
$Password = ConvertTo-SecureString -String '53cur!ty' -AsPlainText -Force

# Install the Active Directory Forest
$Settings = @{
    CreateDnsDelegation           = $False
    DomainName                    = 'auror.local'
    DomainNetbiosName             = 'auror'
    InstallDns                    = $True
    SafeModeAdministratorPassword = $Password
    Force                         = $True
    NoRebootOnCompletion          = $True
}
Install-ADDSForest @Settings