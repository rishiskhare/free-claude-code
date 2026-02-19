#requires -Version 5.1

<#
.SYNOPSIS
    Reusable UI components for the setup wizard
.DESCRIPTION
    Provides common UI functions like confirmations, choices, and headers
#>

function Show-Header {
    <#
    .SYNOPSIS
        Display a section header
    .PARAMETER Title
        The title to display
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Read-Confirmation {
    <#
    .SYNOPSIS
        Ask user for yes/no confirmation
    .PARAMETER Prompt
        The question to ask
    .PARAMETER DefaultYes
        Whether to default to Yes
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        
        [Parameter(Mandatory = $false)]
        [switch]$DefaultYes
    )

    $choices = if ($DefaultYes) { 'Y/n' } else { 'y/N' }
    
    do {
        $response = Read-Host "$Prompt [$choices]"
        
        if ([string]::IsNullOrWhiteSpace($response)) {
            return $DefaultYes.IsPresent
        }
        
        $response = $response.Trim().ToLower()
        
        if ($response -eq 'y' -or $response -eq 'yes') {
            return $true
        } elseif ($response -eq 'n' -or $response -eq 'no') {
            return $false
        }
        
        Write-Host "Please enter 'y' or 'n'" -ForegroundColor Yellow
    } while ($true)
}

function Read-Choice {
    <#
    .SYNOPSIS
        Display a numbered menu and get user choice
    .PARAMETER Prompt
        The prompt to display
    .PARAMETER Options
        Array of options to choose from
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Options
    )

    Write-Host $Prompt -ForegroundColor Cyan
    Write-Host ""
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  $($i + 1)) $($Options[$i])" -ForegroundColor Gray
    }
    
    Write-Host ""
    
    do {
        $response = Read-Host "Choice [1-$($Options.Count)]"
        
        if ($response -match '^\d+$') {
            $choice = [int]$response
            if ($choice -ge 1 -and $choice -le $Options.Count) {
                return $choice - 1
            }
        }
        
        Write-Host "Please enter a number between 1 and $($Options.Count)" -ForegroundColor Yellow
    } while ($true)
}

function Show-MessageBox {
    <#
    .SYNOPSIS
        Display a message in a box
    .PARAMETER Message
        The message to display
    .PARAMETER Type
        Message type (Info, Warning, Error)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )

    $color = switch ($Type) {
        'Info' { 'Cyan' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
    }

    $icon = switch ($Type) {
        'Info' { 'ℹ' }
        'Warning' { '⚠' }
        'Error' { '✗' }
    }

    $lines = $Message -split "`n"
    $maxLength = ($lines | Measure-Object -Property Length -Maximum).Maximum
    $boxWidth = [Math]::Min([Math]::Max($maxLength + 4, 40), 70)
    
    Write-Host ""
    Write-Host ("┌" + ("─" * ($boxWidth - 2)) + "┐") -ForegroundColor $color
    
    foreach ($line in $lines) {
        $padding = " " * ($boxWidth - $line.Length - 4)
        Write-Host ("│ $icon $line$padding │") -ForegroundColor $color
    }
    
    Write-Host ("└" + ("─" * ($boxWidth - 2)) + "┘") -ForegroundColor $color
    Write-Host ""
}

function Test-IsAdmin {
    <#
    .SYNOPSIS
        Check if running with administrator privileges
    #>
    [CmdletBinding()]
    param()

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Show-ProgressSpinner {
    <#
    .SYNOPSIS
        Display a spinner while executing an action
    .PARAMETER Message
        Message to display
    .PARAMETER Action
        ScriptBlock to execute
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action
    )

    $spinner = @('|', '/', '-', '\')
    $i = 0
    
    $job = Start-Job -ScriptBlock $Action
    
    while ($job.State -eq 'Running') {
        Write-Host "`r$Message $($spinner[$i % $spinner.Length])" -NoNewline -ForegroundColor Cyan
        $i++
        Start-Sleep -Milliseconds 100
    }
    
    $result = Receive-Job $job
    Remove-Job $job
    
    Write-Host "`r$Message ✓" -ForegroundColor Green
    
    return $result
}

Export-ModuleMember -Function Show-Header, Read-Confirmation, Read-Choice, Show-MessageBox, Test-IsAdmin, Show-ProgressSpinner
