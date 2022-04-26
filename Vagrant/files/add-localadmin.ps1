# Add auror\Adam to local administrator group of PC01
Add-LocalGroupMember -Group "Administrators" -Member "auror\Adam"

# Run Windows Defender Update
Update-MpSignature

# Disable Automatic Sample Submission
PowerShell Set-MpPreference -SubmitSamplesConsent 2​