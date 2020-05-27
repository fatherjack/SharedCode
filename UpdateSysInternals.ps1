Function Update-SysInternals {
    <#
    .Synopsis
       PowerShell script to update Sysinternals tools

    .DESCRIPTION
       Creates a PSDrive mapped to '\\live.sysinternals.com\tools' and then copies tools that are new or have a different byte length

       NOTE: Needs to run with elevated permissions.

    .EXAMPLE
       Update-SysInternals

    .NOTES

        # This Sample Code is provided for the purpose of illustration only and is not intended
        # to be used in a production environment.
        # THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
        # EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF
        # MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

      
    .AUTHOR
        Jonathan Allen - Sept 2016
    #>

    Begin {
        cls;
        # check we are running with elevated priveledges
        $user = [Security.Principal.WindowsIdentity]::GetCurrent();
        $IsAdmin = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
        if (!($IsAdmin)) {
            "Please start your PowerShell host as an administrator account and then update sysinternals tools." | Write-Warning
            Break
        }
        # check we can map a drive to the sysinternals download location and get local location for tools
        try {
            $Sysinternals = '\\live.sysinternals.com\tools'
            # Create PSDrive to do tools comparison and copy from
            if (!(Get-PSDrive | Where-Object { $_.root -eq $sysinternals })) {
                New-PSDrive -Name SysInternals -PSProvider FileSystem -Root $sysinternals | Out-Null
                $CleanUp = $true
            }
            # Get target directory file from user
            $Obj = New-Object -ComObject Shell.application
            "Please select your sysinternals tools directory in the 'Select folder' dialog" | Write-Output
            $Folder = $obj.BrowseForFolder(0, 'Select your SysInternals tools directory:', 5)
            $LocalToolsDir = $Folder.Self.Path
            cls;
            "Updating sysinternals tools in $LocalToolsDir." | Write-Output
        }
        catch {
            cls;
            "Cannot reach \\live.sysinternals.com. Please update sysinternals tools later." | Write-Warning
            Break
        }
    }

    Process {
        try {
            # map a drive to the sysinternals location
            if (!(Test-Path $LocalToolsDir)) {
                New-Item -Path $LocalToolsDir -ItemType directory
            }
        }
        catch {
            "Cannot locate or create selected folder. Please re-run Update-Sysinternals and provide a different location for the tools." | Write-Warning
            break
        }
        "Checking $Sysinternals ..." | Write-Output
        # Get tools list from both locations
        $SourceTools = Get-ChildItem 'SysInternals:\' | Where-Object { $_.attributes -eq 'Archive' }
        $LocalTools = Get-ChildItem $LocalToolsDir

        # basic count of objects to decide if there are any new tools
        $SourceCount = Get-ChildItem SysInternals:\ | Measure-Object | Select-Object count
        $LocalCount = Get-ChildItem $LocalToolsDir | Measure-Object | Select-Object count
        $NewTools = $SourceCount.Count - $LocalCount.Count

        if ($NewTools -ne 0) {
            $msg = "Good news everyone! $($SourceCount.Count - $LocalCount.Count) new tools to download.`r`n"
        }
        else {
            $msg = "No new tools to download. Checking for updates to your current tool set...`r`n"
        }
        $msg | Write-Output

        # for each tool at the source compare its creation date and length with the local tool
        foreach ($Tool in $SourceTools) {
            if ($Tool.name -notin $LocalTools.name) {
                # new tools get copied
                $KB = "{0:N2}" -f $($tool.Length / 1KB)
                "New tool`t$($Tool.name) ($KB KB)" | Write-Output
                try {
                    Copy-Item -Path ("SysInternals:\" + $Tool.name) -Destination $LocalToolsDir
                }
                catch {
                    "Unable to update $($Tool.name) at the moment. Please try again later." | Write-Warning
                    $Error
                }

            }
            # checks length and date and updates on any difference
            elseif (($Tool.Length -ne (Get-ChildItem $LocalToolsDir | ? name -EQ $tool.name).Length) -and ($Tool.CreationTimeUtc -ne (Get-ChildItem $LocalToolsDir | ? name -EQ $tool.name).CreationTimeUtc) ) {
                # having a difference means we copy the new version
                $KB = "{0:N2}" -f $($tool.Length / 1KB)
                "Updating`t$($Tool.name) ($KB KB)" | Write-Output
                Copy-Item -Path ("SysInternals:\" + $Tool.name) -Destination $LocalToolsDir
            }
            else {
                # confirm tool is up to date
                "No change`t$($Tool.name)" | Write-Output
            }
        }
        # remove the drive we created
        if ($CleanUp) { Remove-PSDrive SysInternals }
    }
    End { }
}