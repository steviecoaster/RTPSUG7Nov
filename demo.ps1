#region Engine Events
#Powershell Exiting Events. This executes in a different Scope, so if BurntToast is in your current sessionstate,
#it won't be available to the event.
#Explicitly import the nodule to "force" the Event to see the module
Import-Module BurntToast

Register-EngineEvent -SourceIdentifier Powershell.Exiting -Action {

    $Header = New-BTHeader -Id 1 -Title "Powershell Exit"

    New-BurntToastNotification -Text "Whatever you were doing is done, and Powershell exited" -Header $Header -Silent


}

#You can also Register on Custom Events
    #$Event is an automatic variable used by the -Action parameter
    Register-EngineEvent -SourceIdentifier Test -Action { Toast -Header (New-BTHeader -Id 1 -Title "Engine Event Test") -Text "$($event.MessageData)" }

    New-Event -SourceIdentifier Test -Sender PowershellTesting -MessageData "Blah"

#endregion

#region Alert
$buttonProps = @{
    Id = 1
    Content = 'Go'
    Arguments = 'https://play.grafana.org/d/000000052/advanced-layout?panelId=2&fullscreen&orgId=1'
}

$button = New-BTButton @buttonProps

$header = New-BTHeader -Id 1 -Title 'Service Degradation Alert'

$toastProps = @{
    Button = $button
    Text = "There's an issue. Click 'Go' to View"
    Header = $header
    AppLogo = 'C:\users\svalding\Pictures\Toast\grafana.png'
}

New-BurntToastNotification @toastProps
#endregion

#region Reminder
Function New-ToastReminder {

    [cmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $ReminderTitle,

        [Parameter(Mandatory, Position = 1)]
        [string]
        $ReminderText,

        [Parameter(Position = 2)]
        [int]
        $Seconds,

        [Parameter(Position = 3)]
        [Int]
        $Minutes,

        [Parameter(Position = 4)]
        [Int]
        $Hours
    )

    Begin {}

    Process {

        Start-Job -ScriptBlock {
                        
            $watch =  New-Object -Type System.Diagnostics.Stopwatch
            $watch.Start()
            
            $HoursToSeconds = $using:Hours * 60  * 60
            $MinutesToSeconds = $using:Minutes * 60
            $TotalSeconds = $HoursToSeconds + $MinutesToSeconds + $using:Seconds
            
            While ($watch.Elapsed.TotalSeconds -lt $TotalSeconds) {

                Out-Null
            }
            $watch.Stop()

            $Head = New-BTHeader -ID 1 -Title $using:ReminderTitle
            Toast -Text $using:ReminderText -Header $Head -AppLogo $null

        } > $null
    }

    End {}

}
#endregion

#region Encryption
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
#endregion

#region DotNet

#endregion

#region Toner Levels

#Generate a fake dataset
$tonerLevels = [pscustomobject]@{

    Black = 100
    Cyan = 25
    Magenta = 66
    Yellow = 5
}

$tonerLevels.PSObject.Members | Where-Object { $_.MemberType -eq "NoteProperty"} | ForEach-Object {

    If($_.Value -lt 10) {

        $Header = New-BTHeader -Id 1 -Title "Toner Alert for $($_.Name)"

        New-BurntToastNotification -Header $Header -Text "$($_.Name) has $($_.Value)% Remaining!"

    }

}

#endregion