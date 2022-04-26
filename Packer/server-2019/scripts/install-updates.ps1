<#
Script for installing Windows Updates. The script will scan the operating system
for all available Windows Updates that need to be installed, queue them for install,
accept the EULA, download the updates, and install them.
#>
<#
Check to see if Windows Update is currently busy. If so, we cannot install updates
right now and fail out
#>
If((New-Object -ComObject Microsoft.Update.Session).CreateUpdateInstaller().IsBusy) {
    Throw "Windows Update is currently busy."
}
# End user feedback
Write-Output ((Get-Date -UFormat %R) + " - Searching for Windows Updates")
# Try/Catch to search for available Windows Updates
Try {
    # Create a new session to the update service
    $Session = New-Object -ComObject Microsoft.Update.Session
    # Create a search object for the update services
    $Searcher = $Session.CreateUpdateSearcher()
    # Set Windows Update as the update source
    $Searcher.ServerSelection = 2
    # Search for all available updates that are not installed
    $Results = $Searcher.Search("IsInstalled=0 AND Type='Software'")
}
Catch {
    Throw ("Unable to search for updates - " + $Global:Error[0])
}
# Remove optional updates
$Updates = $Results.Updates | Where-Object -Property AutoSelection -Eq 1
# If there are any updates to install, download and install them
If($Updates) {
    # Create a collection object for all of the updates that need to be installed
    $UpdateInstallList = New-Object -ComObject Microsoft.Update.UpdateColl
    <#
    Loop through each of the available updates, determine if it needs to be installed,
    and add to the install list if so, and ensure the update is downloaded
    #>
    ForEach($Update in $Updates) {
        # End user feedback
        Write-Output ((Get-Date -UFormat %R) + " - " + $Update.Title + " - Preparing download")
        # Add the update to the install list
        $UpdateInstallList.Add($Update) | Out-Null
        # End user feedback
        Write-Output ((Get-Date -UFormat %R) + " - " + $Update.Title + " - Accepting EULA")
        # Accept the EULA on the update
        $Update.AcceptEula() | Out-Null
        # If the update has not been downloaded
        If(!$Update.IsDownloaded) {
            # Using the existing Windows Update session, create the download object
            $Downloader = $Session.CreateUpdateDownloader()
            # Create the update download collection
            $Downloader.Updates = New-Object -ComObject Microsoft.Update.UpdateColl
            # Add the update to the download collection
            $Downloader.Updates.Add($Update) | Out-Null
            # End user feedback
            Write-Output ((Get-Date -UFormat %R) + " - " + $Update.Title + " - Downloading")
            # Download the update. This might take a while depending on the update size
            $Downloader.Download() | Out-Null
            # End user feedback
            Write-Output ((Get-Date -UFormat %R) + " - " + $Update.Title + " - Download completed")
        }
    }
    # End user feedback
    Write-Output ((Get-Date -UFormat %R) + " - " + "Preparing for installation")
    # Using the existing Windows Update session, create an installer
    $Installer = $Session.CreateUpdateInstaller()
    # Create a new collection for the updates to install
    $Installer.Updates = New-Object -ComObject Microsoft.Update.UpdateColl
    # Loop through the updates and add each to the install queue
    ForEach($Update in $UpdateInstallList) {
        # End user feedback
        Write-Output ((Get-Date -UFormat %R) + " - " + $Update.Title + " - Adding to install list")
        # Add the update to the install collection
        $Installer.Updates.Add($Update) | Out-Null
    }
    # Try/Catch to install the update
    Try {
        # End user feedback
        Write-Output ((Get-Date -UFormat %R) + " - Installing updates")
        # Install all of the updates
        $Install = $Installer.Install()
        # If the install returns anything other than a 2 or 3, it failed
        If($Install.ResultCode -NotMatch '2|3') {
            Write-Output ("Install failed - " + $Install.ResultCode)
            Throw $Install.ResultCode
        }
        # End user feedback
        Write-Output ((Get-Date -UFormat %R) + " - Windows Updates completed")
    }
    Catch {
        # Terminate with an error
        Throw ("Install failed - " + $Install.ResultCode)
    }
}
Else {
    # End user feedback
    Write-Output "No updates available"
}