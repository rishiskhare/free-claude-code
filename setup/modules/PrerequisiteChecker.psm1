#requires -Version 5.1

<#
.SYNOPSIS
    Prerequisite detection and installation
.DESCRIPTION
    Detects, installs, and configures all system prerequisites for the setup wizard
#>

function Test-Prerequisites {
    <#
    .SYNOPSIS
        Test all prerequisites and return status
    #>
    [CmdletBinding()]
    param()

    $results = @{
        Python = Test-PythonInstalled
        NodeJS = Test-NodeJSInstalled
        UV = Test-UVInstalled
        PM2 = Test-PM2Installed
        FZF = Test-FZFInstalled
        ClaudeCLI = Test-ClaudeCLIInstalled
        AllRequiredPass = $false
    }

    # Check if all required prerequisites pass
    $results.AllRequiredPass = $results.Python.Installed -and 
                               $results.NodeJS.Installed -and 
                               $results.UV.Installed -and 
                               $results.PM2.Installed -and 
                               $results.FZF.Installed

    return $results
}

function Test-PythonInstalled {
    <#
    .SYNOPSIS
        Check if Python 3.14+ is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $true
    }

    try {
        # Try python command
        $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
        
        if ($pythonCmd) {
            $versionOutput = & python --version 2>&1
            if ($versionOutput -match 'Python (\d+\.\d+\.\d+)') {
                $version = [version]$matches[1]
                $result.Version = $version.ToString()
                $result.Path = $pythonCmd.Source
                
                # Check if version is 3.14+
                if ($version.Major -ge 3 -and $version.Minor -ge 14) {
                    $result.Installed = $true
                    $result.Status = 'OK'
                } else {
                    $result.Status = "Version too old (need 3.14+, found $($version.ToString()))"
                }
            }
        }
    } catch {
        $result.Status = "Error checking Python: $_"
    }

    return $result
}

function Test-NodeJSInstalled {
    <#
    .SYNOPSIS
        Check if Node.js is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $true
    }

    try {
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
        
        if ($nodeCmd) {
            $versionOutput = & node --version 2>&1
            if ($versionOutput -match 'v(\d+\.\d+\.\d+)') {
                $result.Version = $matches[1]
                $result.Path = $nodeCmd.Source
                $result.Installed = $true
                $result.Status = 'OK'
            }
        }
    } catch {
        $result.Status = "Error checking Node.js: $_"
    }

    return $result
}

function Test-UVInstalled {
    <#
    .SYNOPSIS
        Check if uv is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $true
    }

    try {
        $uvCmd = Get-Command uv -ErrorAction SilentlyContinue
        
        if ($uvCmd) {
            $versionOutput = & uv --version 2>&1
            if ($versionOutput -match '(\d+\.\d+\.\d+)') {
                $result.Version = $matches[1]
                $result.Path = $uvCmd.Source
                $result.Installed = $true
                $result.Status = 'OK'
            }
        }
    } catch {
        $result.Status = "Error checking uv: $_"
    }

    return $result
}

function Test-PM2Installed {
    <#
    .SYNOPSIS
        Check if PM2 is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $true
    }

    try {
        $pm2Cmd = Get-Command pm2 -ErrorAction SilentlyContinue
        
        if ($pm2Cmd) {
            $versionOutput = & pm2 --version 2>&1
            if ($versionOutput -match '(\d+\.\d+\.\d+)') {
                $result.Version = $matches[1]
                $result.Path = $pm2Cmd.Source
                $result.Installed = $true
                $result.Status = 'OK'
            }
        }
    } catch {
        $result.Status = "Error checking PM2: $_"
    }

    return $result
}

function Test-FZFInstalled {
    <#
    .SYNOPSIS
        Check if fzf is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $true
    }

    try {
        $fzfCmd = Get-Command fzf -ErrorAction SilentlyContinue
        
        if ($fzfCmd) {
            $versionOutput = & fzf --version 2>&1
            if ($versionOutput -match '(\d+\.\d+)') {
                $result.Version = $matches[1]
                $result.Path = $fzfCmd.Source
                $result.Installed = $true
                $result.Status = 'OK'
            }
        }
    } catch {
        $result.Status = "Error checking fzf: $_"
    }

    return $result
}

function Test-ClaudeCLIInstalled {
    <#
    .SYNOPSIS
        Check if Claude Code CLI is installed
    #>
    [CmdletBinding()]
    param()

    $result = @{
        Installed = $false
        Version = $null
        Path = $null
        Status = 'Not Found'
        Required = $false
    }

    try {
        $claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
        
        if ($claudeCmd) {
            $result.Path = $claudeCmd.Source
            $result.Installed = $true
            $result.Status = 'OK'
        }
    } catch {
        $result.Status = "Not installed (optional)"
    }

    return $result
}

function Invoke-PrerequisiteInstallation {
    <#
    .SYNOPSIS
        Install missing prerequisites
    .PARAMETER Results
        Results from Test-Prerequisites
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Results
    )

    Write-Host ""
    Write-Host "Installing missing prerequisites..." -ForegroundColor Cyan
    Write-Host ""

    # Install Python if needed
    if (-not $Results.Python.Installed) {
        Write-Host "[⟳] Installing Python 3.14..." -ForegroundColor Cyan
        try {
            Install-Python
            Write-Host "[✓] Python installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "[✗] Failed to install Python: $_" -ForegroundColor Red
            throw
        }
    }

    # Install Node.js if needed
    if (-not $Results.NodeJS.Installed) {
        Write-Host "[⟳] Installing Node.js..." -ForegroundColor Cyan
        try {
            Install-NodeJS
            Write-Host "[✓] Node.js installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "[✗] Failed to install Node.js: $_" -ForegroundColor Red
            throw
        }
    }

    # Install uv if needed
    if (-not $Results.UV.Installed) {
        Write-Host "[⟳] Installing uv..." -ForegroundColor Cyan
        try {
            Install-UV
            Write-Host "[✓] uv installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "[✗] Failed to install uv: $_" -ForegroundColor Red
            throw
        }
    }

    # Install PM2 if needed
    if (-not $Results.PM2.Installed) {
        Write-Host "[⟳] Installing PM2..." -ForegroundColor Cyan
        try {
            Install-PM2
            Write-Host "[✓] PM2 installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "[✗] Failed to install PM2: $_" -ForegroundColor Red
            throw
        }
    }

    # Install fzf if needed
    if (-not $Results.FZF.Installed) {
        Write-Host "[⟳] Installing fzf..." -ForegroundColor Cyan
        try {
            Install-FZF
            Write-Host "[✓] fzf installed successfully" -ForegroundColor Green
        } catch {
            Write-Host "[✗] Failed to install fzf: $_" -ForegroundColor Red
            throw
        }
    }

    Write-Host ""
    Write-Host "All prerequisites installed!" -ForegroundColor Green
    Write-Host ""
}

function Install-Python {
    <#
    .SYNOPSIS
        Install Python 3.14
    #>
    [CmdletBinding()]
    param()

    Write-Host "  Downloading Python installer..." -ForegroundColor Gray
    
    $version = "3.14.2"
    $url = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
    $installer = Join-Path $env:TEMP "python-installer.exe"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing -TimeoutSec 300
        
        Write-Host "  Installing Python (this may take a few minutes)..." -ForegroundColor Gray
        
        $installerArguments = "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0 Include_pip=1"
        $process = Start-Process -FilePath $installer -ArgumentList $installerArguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -ne 0) {
            throw "Python installer failed with exit code $($process.ExitCode)"
        }
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        
        # Verify
        Start-Sleep -Seconds 2
        $pythonTest = Get-Command python -ErrorAction SilentlyContinue
        if (-not $pythonTest) {
            throw "Python installation verification failed"
        }
        
        if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "Python installed successfully" -Level INFO
        }
    } finally {
        if (Test-Path $installer) {
            Remove-Item $installer -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-NodeJS {
    <#
    .SYNOPSIS
        Install Node.js LTS
    #>
    [CmdletBinding()]
    param()

    Write-Host "  Downloading Node.js installer..." -ForegroundColor Gray
    
    $url = "https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi"
    $installer = Join-Path $env:TEMP "node-installer.msi"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $installer -UseBasicParsing -TimeoutSec 300
        
        Write-Host "  Installing Node.js (this may take a few minutes)..." -ForegroundColor Gray
        
        $msiArguments = "/i `"$installer`" /quiet /norestart"
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArguments -Wait -PassThru -NoNewWindow
        
        if ($process.ExitCode -notin @(0, 3010)) {
            throw "Node.js installer failed with exit code $($process.ExitCode)"
        }
        
        # Refresh PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
        
        # Verify
        Start-Sleep -Seconds 2
        $nodeTest = Get-Command node -ErrorAction SilentlyContinue
        if (-not $nodeTest) {
            throw "Node.js installation verification failed"
        }
        
        if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "Node.js installed successfully" -Level INFO
        }
    } finally {
        if (Test-Path $installer) {
            Remove-Item $installer -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-UV {
    <#
    .SYNOPSIS
        Install uv package manager
    #>
    [CmdletBinding()]
    param()

    Write-Host "  Installing uv via pip..." -ForegroundColor Gray
    
    try {
        $output = & python -m pip install --upgrade uv 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "pip install uv failed: $output"
        }
        
        # Verify
        Start-Sleep -Seconds 1
        $uvTest = Get-Command uv -ErrorAction SilentlyContinue
        if (-not $uvTest) {
            throw "uv installation verification failed"
        }
        
        if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "uv installed successfully" -Level INFO
        }
    } catch {
        throw "Failed to install uv: $_"
    }
}

function Install-PM2 {
    <#
    .SYNOPSIS
        Install PM2 globally via npm
    #>
    [CmdletBinding()]
    param()

    Write-Host "  Installing PM2 via npm..." -ForegroundColor Gray
    
    try {
        $output = & npm install -g pm2 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "npm install pm2 failed: $output"
        }
        
        # Verify
        Start-Sleep -Seconds 1
        $pm2Test = Get-Command pm2 -ErrorAction SilentlyContinue
        if (-not $pm2Test) {
            throw "PM2 installation verification failed"
        }
        
        if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "PM2 installed successfully" -Level INFO
        }
    } catch {
        throw "Failed to install PM2: $_"
    }
}

function Install-FZF {
    <#
    .SYNOPSIS
        Install fzf
    #>
    [CmdletBinding()]
    param()

    Write-Host "  Downloading fzf..." -ForegroundColor Gray
    
    $url = "https://github.com/junegunn/fzf/releases/download/0.46.1/fzf-0.46.1-windows_amd64.zip"
    $zipFile = Join-Path $env:TEMP "fzf.zip"
    $destDir = Join-Path $env:LOCALAPPDATA "fzf"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing -TimeoutSec 120
        
        Write-Host "  Extracting fzf..." -ForegroundColor Gray
        
        if (Test-Path $destDir) {
            Remove-Item $destDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        
        Expand-Archive -Path $zipFile -DestinationPath $destDir -Force
        
        # Add to PATH
        $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
        if ($userPath -notlike "*$destDir*") {
            [Environment]::SetEnvironmentVariable('Path', "$destDir;$userPath", 'User')
            $env:Path = "$destDir;$env:Path"
        }
        
        # Verify
        Start-Sleep -Seconds 1
        $fzfTest = Get-Command fzf -ErrorAction SilentlyContinue
        if (-not $fzfTest) {
            throw "fzf installation verification failed"
        }
        
        if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
            Write-Log "fzf installed successfully" -Level INFO
        }
    } finally {
        if (Test-Path $zipFile) {
            Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
        }
    }
}

Export-ModuleMember -Function Test-Prerequisites, Invoke-PrerequisiteInstallation, Test-PythonInstalled, Test-NodeJSInstalled, Test-UVInstalled, Test-PM2Installed, Test-FZFInstalled, Test-ClaudeCLIInstalled
