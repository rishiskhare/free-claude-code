#requires -Version 5.1

<#
.SYNOPSIS
    Retro terminal UI components with ASCII art and neon colors
.DESCRIPTION
    Provides beautiful retro/tech aesthetic with progress bars, boxes, and status indicators
#>

function Show-RetroLogo {
    <#
    .SYNOPSIS
        Display the ASCII art logo
    #>
    [CmdletBinding()]
    param()

    $logoPath = Join-Path $PSScriptRoot "..\assets\logo.txt"
    
    if (Test-Path $logoPath) {
        $logo = Get-Content $logoPath -Raw
        Write-Host $logo -ForegroundColor Green
    } else {
        Write-Host "`n  FREE CLAUDE CODE - SETUP WIZARD`n" -ForegroundColor Green
    }
}

function Show-StepIndicator {
    <#
    .SYNOPSIS
        Display progress indicator for current step
    .PARAMETER Current
        Current step number
    .PARAMETER Total
        Total number of steps
    .PARAMETER StepName
        Name of the current step
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [int]$Current,
        
        [Parameter(Mandatory = $true)]
        [int]$Total,
        
        [Parameter(Mandatory = $true)]
        [string]$StepName
    )

    $percentage = [Math]::Round(($Current / $Total) * 100)
    $barLength = 40
    $filledLength = [Math]::Round(($Current / $Total) * $barLength)
    $emptyLength = $barLength - $filledLength
    
    $bar = ("[" + ("█" * $filledLength) + ("░" * $emptyLength) + "]")
    
    Write-Host ""
    Write-Host "Progress: " -NoNewline -ForegroundColor Gray
    Write-Host $bar -NoNewline -ForegroundColor Cyan
    Write-Host " $percentage%" -ForegroundColor Cyan
    Write-Host "Step $Current/$Total" -NoNewline -ForegroundColor Gray
    Write-Host ": $StepName" -ForegroundColor White
    Write-Host ""
}

function Show-RetroBox {
    <#
    .SYNOPSIS
        Draw a box with title and content
    .PARAMETER Title
        Box title
    .PARAMETER Lines
        Array of content lines
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Lines
    )

    $maxLength = ($Lines | Measure-Object -Property Length -Maximum).Maximum
    $titleLength = $Title.Length
    $boxWidth = [Math]::Max($maxLength, $titleLength) + 4
    
    Write-Host ""
    Write-Host ("┌─" + ("─" * $Title.Length) + "─┐") -ForegroundColor DarkGreen
    Write-Host ("│ " + $Title + " │") -ForegroundColor Green
    Write-Host ("├─" + ("─" * $Title.Length) + "─┤") -ForegroundColor DarkGreen
    
    foreach ($line in $Lines) {
        $padding = " " * ($boxWidth - $line.Length - 4)
        Write-Host ("│ " + $line + $padding + " │") -ForegroundColor Gray
    }
    
    Write-Host ("└─" + ("─" * ($boxWidth - 4)) + "─┘") -ForegroundColor DarkGreen
    Write-Host ""
}

function Write-Status {
    <#
    .SYNOPSIS
        Write a status message with icon
    .PARAMETER Message
        The message to display
    .PARAMETER Level
        Status level (Info, Success, Warning, Error, Processing)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Processing')]
        [string]$Level = 'Info'
    )

    $icon = switch ($Level) {
        'Info' { '[ℹ]' }
        'Success' { '[✓]' }
        'Warning' { '[⚠]' }
        'Error' { '[✗]' }
        'Processing' { '[⟳]' }
    }

    $color = switch ($Level) {
        'Info' { 'Cyan' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
        'Error' { 'Red' }
        'Processing' { 'Cyan' }
    }

    Write-Host "$icon " -NoNewline -ForegroundColor $color
    Write-Host $Message -ForegroundColor Gray
}

function Show-Menu {
    <#
    .SYNOPSIS
        Display a retro-styled menu
    .PARAMETER Title
        Menu title
    .PARAMETER Options
        Array of menu options
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,
        
        [Parameter(Mandatory = $true)]
        [string[]]$Options
    )

    $maxLength = ($Options | Measure-Object -Property Length -Maximum).Maximum
    $boxWidth = [Math]::Max($maxLength + 8, $Title.Length + 4)
    
    Write-Host ""
    Write-Host ("┌" + ("─" * ($boxWidth - 2)) + "┐") -ForegroundColor DarkGreen
    
    $titlePadding = " " * (($boxWidth - $Title.Length - 2) / 2)
    Write-Host ("│" + $titlePadding + $Title + $titlePadding + "│") -ForegroundColor Green
    
    Write-Host ("├" + ("─" * ($boxWidth - 2)) + "┤") -ForegroundColor DarkGreen
    
    for ($i = 0; $i -lt $Options.Count; $i++) {
        $number = "  $($i + 1))"
        $option = $Options[$i]
        $padding = " " * ($boxWidth - $number.Length - $option.Length - 3)
        Write-Host ("│" + $number + " " + $option + $padding + "│") -ForegroundColor Gray
    }
    
    Write-Host ("└" + ("─" * ($boxWidth - 2)) + "┘") -ForegroundColor DarkGreen
    Write-Host ""
}

function Read-UserInput {
    <#
    .SYNOPSIS
        Read user input with validation
    .PARAMETER Prompt
        Input prompt
    .PARAMETER Default
        Default value
    .PARAMETER Validation
        Validation scriptblock
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt,
        
        [Parameter(Mandatory = $false)]
        [string]$Default = "",
        
        [Parameter(Mandatory = $false)]
        [scriptblock]$Validation = { $true }
    )

    do {
        if ($Default) {
            $userInput = Read-Host "$Prompt [$Default]"
            if ([string]::IsNullOrWhiteSpace($userInput)) {
                $userInput = $Default
            }
        } else {
            $userInput = Read-Host $Prompt
        }
        
        $validationResult = & $Validation $userInput
        
        if ($validationResult -eq $true) {
            return $userInput
        } else {
            Write-Host "Invalid input: $validationResult" -ForegroundColor Red
        }
    } while ($true)
}

function Read-SecureInput {
    <#
    .SYNOPSIS
        Read secure input (masked)
    .PARAMETER Prompt
        Input prompt
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt
    )

    $secureString = Read-Host $Prompt -AsSecureString
    $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

Export-ModuleMember -Function Show-RetroLogo, Show-StepIndicator, Show-RetroBox, Write-Status, Show-Menu, Read-UserInput, Read-SecureInput
