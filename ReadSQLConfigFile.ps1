function Read-SQLConfigFile {
    <#
    .SYNOPSIS
    Takes configuration file and shows features that are being set
    
    .DESCRIPTION
    Function to show what features and settings are being adjusted by the configuration file.  Allows for comparison of 
    config files when combined with Compare-Object
    
    .EXAMPLE
    Read-SQLConfigFile -Path C:\temp\configuration.ini

    explore all settings in specified configuration file

    .EXAMPLE
    get-childitem -filter *.ini | Read-SQLConfigFile 

    pass all ini files in current folder to Read-SQLConfigFile

    .Example
    
    $reference = get-item DPM_SQL_ConfigurationFile.ini | Read-SQLConfigFile

    (get-item SP_SQL_ConfigurationFile.ini | Read-SQLConfigFile) | compare-object -ReferenceObject $reference 

    compare two configuration files to observe difference
    
    .Notes
    Author - Jonathan Allen
    
    #>
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)][string]$Path,
        [parameter()][string]$type
    )
    begin { }
    process {
        # get all rows that have = assignment
        $content = Select-String -Path $Path -Pattern "=" -AllMatches
        return ($content | Select-Object line )

    }
    end { }
}