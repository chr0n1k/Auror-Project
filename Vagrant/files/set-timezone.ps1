# Set Time Zone
Set-TimeZone "E. Africa Standard Time"

# Run Windows Defender Update
Update-MpSignature

# Disable Automatic Sample Submission
PowerShell Set-MpPreference -SubmitSamplesConsent 2​