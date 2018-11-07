Function Get-BitlockerEncryptionToast {

    [cmdletBinding()]
    Param(
        [Parameter(Mandatory,Position=1,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string]
        $Computername
    )

    Begin { $Session = New-PSSession -ComputerName $Computername }

    Process {

        $EncryptionPercentage = Invoke-Command -Session $Session -ScriptBlock { (Get-BitLockerVolume).EncryptionPercentage }
        
        While($EncryptionPercentage -lt 100) {

           Out-Null

        }

        $Header = New-BTHeader -Id 1 -Title "Encryption Complete!"
        New-BurntToastNotification -Text "Encryption on $Computername has completed!" -Header $Header -Silent

    }

    End { Get-PSSession | Remove-PSSession }
}