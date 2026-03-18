<#
.SYNOPSIS
    Compares a local CommonFunctions.au3 against the GitHub master version and lets you decide what to do.
.PARAMETER Path
    Path to the local CommonFunctions.au3 file or a directory to search. Defaults to the current directory.
.PARAMETER Recurse
    Recursively search the provided path for all CommonFunctions.au3 files and process each one.
#>
param(
    [string]$Path,
    [switch]$Recurse
)

$GitHubRawUrl = "https://raw.githubusercontent.com/jmclaren7/autoit-scripts/master/CommonFunctions.au3"

# Download the GitHub version to a temp file once
$tempFile = Join-Path $env:TEMP "CommonFunctions_github.au3"
try {
    Write-Host "Downloading latest version from GitHub..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $GitHubRawUrl -OutFile $tempFile -UseBasicParsing
} catch {
    Write-Host "Failed to download from GitHub: $_" -ForegroundColor Red
    exit 1
}
$githubContent = Get-Content $tempFile

function Compare-AndPrompt($FilePath) {
    Write-Host "`n========================================" -ForegroundColor DarkGray
    Write-Host "Local file: $FilePath" -ForegroundColor Cyan

    $localContent = Get-Content $FilePath
    $diff = Compare-Object $localContent $githubContent -IncludeEqual
    $changes = $diff | Where-Object { $_.SideIndicator -ne "==" }

    if ($changes.Count -eq 0) {
        Write-Host "  Identical. No update needed." -ForegroundColor Green
        return
    }

    $localOnly = $changes | Where-Object { $_.SideIndicator -eq "<=" }
    $githubOnly = $changes | Where-Object { $_.SideIndicator -eq "=>" }

    Write-Host "  Lines only in LOCAL:  $($localOnly.Count)" -ForegroundColor Magenta
    Write-Host "  Lines only in GITHUB: $($githubOnly.Count)" -ForegroundColor Green
    Write-Host ""

    $maxLines = 40
    $shown = 0
    foreach ($line in $changes) {
        if ($shown -ge $maxLines) {
            Write-Host "  ... ($($changes.Count - $maxLines) more lines, use VS Code diff to see all)" -ForegroundColor DarkGray
            break
        }
        if ($line.SideIndicator -eq "<=") {
            Write-Host "  - $($line.InputObject)" -ForegroundColor Magenta
        } else {
            Write-Host "  + $($line.InputObject)" -ForegroundColor Green
        }
        $shown++
    }

    Write-Host ""
    do {
        Write-Host "  [D] Open diff in VS Code  [R] Replace  [B] Backup + Replace  [S] Skip" -ForegroundColor Yellow
        $choice = (Read-Host "  Choice").ToUpper()

        switch ($choice) {
            "D" {
                Write-Host "  Opening diff in VS Code..." -ForegroundColor Cyan
                code --diff $FilePath $tempFile
                Write-Host ""
            }
            "R" {
                Copy-Item $tempFile $FilePath -Force
                Write-Host "  Replaced with GitHub version." -ForegroundColor Green
            }
            "B" {
                $backupPath = "$FilePath.bak"
                Copy-Item $FilePath $backupPath -Force
                Write-Host "  Backup saved to: $backupPath" -ForegroundColor Cyan
                Copy-Item $tempFile $FilePath -Force
                Write-Host "  Replaced with GitHub version." -ForegroundColor Green
            }
            default {
                Write-Host "  Skipped." -ForegroundColor Gray
            }
        }
    } while ($choice -eq "D")
}

# Build the list of files to process
if ($Recurse) {
    if (-not $Path) { $Path = $PWD }
    if (-not (Test-Path $Path)) {
        Write-Host "Path not found: $Path" -ForegroundColor Red
        Remove-Item $tempFile -Force
        exit 1
    }
    $files = Get-ChildItem -Path $Path -Filter "CommonFunctions.au3" -Recurse -File
    if ($files.Count -eq 0) {
        Write-Host "No CommonFunctions.au3 files found under: $Path" -ForegroundColor Red
        Remove-Item $tempFile -Force
        exit 1
    }
    Write-Host "Found $($files.Count) CommonFunctions.au3 file(s) under: $Path" -ForegroundColor Cyan
    foreach ($file in $files) {
        Compare-AndPrompt $file.FullName
    }
} else {
    if (-not $Path) {
        $Path = Join-Path $PWD "CommonFunctions.au3"
    }
    $Path = Resolve-Path $Path -ErrorAction SilentlyContinue
    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Host "CommonFunctions.au3 not found at: $Path" -ForegroundColor Red
        Remove-Item $tempFile -Force
        exit 1
    }
    Compare-AndPrompt $Path
}

Remove-Item $tempFile -Force
Write-Host "`nDone." -ForegroundColor Cyan
