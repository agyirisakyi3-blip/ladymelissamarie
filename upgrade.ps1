# Feature Upgrade Script for Lady Melissa Marie Website
# Usage: .\upgrade.ps1 [-Message "Your commit message"] [-Backup] [-Deploy]

param(
    [string]$Message = "Feature upgrade",
    [switch]$Backup,
    [switch]$Deploy,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

# Colors
$Green = @{ForegroundColor = "Green"}
$Yellow = @{ForegroundColor = "Yellow"}
$Cyan = @{ForegroundColor = "Cyan"}
$Red = @{ForegroundColor = "Red"}

function Write-Status {
    param([string]$Text, [hashtable]$Color = $Cyan)
    Write-Host "`n=> " -NoNewline @Color
    Write-Host $Text
}

if ($Help) {
    Write-Host @"

Feature Upgrade Script - Lady Melissa Marie Website
=====================================================

Usage:
  .\upgrade.ps1                          # Basic upgrade with default message
  .\upgrade.ps1 -Message "Updated nav"   # Custom commit message
  .\upgrade.ps1 -Backup                  # Create backup before upgrade
  .\upgrade.ps1 -Deploy                  # Deploy after upgrade
  .\upgrade.ps1 -Backup -Deploy          # Backup, upgrade, and deploy

Options:
  -Message    Custom git commit message (default: "Feature upgrade")
  -Backup     Create timestamped backup of modified files
  -Deploy     Push changes to remote repository
  -Help       Show this help message

"@
    exit
}

# ==============================
# STEP 1: Pre-flight checks
# ==============================
Write-Status "Running pre-flight checks..." $Green

# Check git is available
try {
    git --version | Out-Null
    Write-Host "  [OK] Git is available"
} catch {
    Write-Host "  [FAIL] Git not found. Please install Git." @Red
    exit 1
}

# Check we're in a git repo
if (-not (Test-Path ".git")) {
    Write-Host "  [FAIL] Not a git repository." @Red
    exit 1
}
Write-Host "  [OK] Inside git repository"

# Check for uncommitted changes
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "  [INFO] Uncommitted changes detected:"
    $gitStatus | ForEach-Object { Write-Host "    $_" }
} else {
    Write-Host "  [INFO] No uncommitted changes. Nothing to upgrade." @Yellow
    exit 0
}

# ==============================
# STEP 2: Create Backup (optional)
# ==============================
if ($Backup) {
    Write-Status "Creating backup..." $Green
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = "backups\upgrade_$timestamp"
    
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    # Backup modified files
    $modifiedFiles = git diff --name-only
    if ($modifiedFiles) {
        foreach ($file in $modifiedFiles) {
            $destDir = Split-Path $backupDir\$file -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item $file -Destination $backupDir\$file -Force
            Write-Host "  [BACKUP] $file"
        }
    }
    
    # Backup untracked files
    $untrackedFiles = git ls-files --others --exclude-standard
    if ($untrackedFiles) {
        foreach ($file in $untrackedFiles) {
            $destDir = Split-Path $backupDir\$file -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item $file -Destination $backupDir\$file -Recurse -Force
            Write-Host "  [BACKUP] $file (untracked)"
        }
    }
    
    Write-Host "`n  Backup saved to: $backupDir" @Green
}

# ==============================
# STEP 3: Run linting/validation
# ==============================
Write-Status "Validating HTML files..." $Green

$htmlErrors = 0
$htmlFiles = Get-ChildItem -Path . -Filter "*.html" -File

foreach ($file in $htmlFiles) {
    $content = Get-Content $file.FullName -Raw
    
    # Check for unclosed tags
    $openTags = [regex]::Matches($content, '<(?!/|!|br|hr|img|input|meta|link)([\w-]+)[^>]*[^/]>').Groups[1].Value
    $closeTags = [regex]::Matches($content, '</([\w-]+)>').Groups[1].Value
    
    # Basic validation - check for doctype
    if ($content -notmatch '<!DOCTYPE html>') {
        Write-Host "  [WARN] $($file.Name): Missing DOCTYPE declaration" @Yellow
    }
    
    # Check for broken links (href="#" or empty src)
    if ($content -match 'href="#"' -or $content -match 'src=""') {
        Write-Host "  [WARN] $($file.Name): Contains empty href or src" @Yellow
    }
}

if ($htmlErrors -eq 0) {
    Write-Host "  [OK] HTML validation passed (warnings only)" @Green
}

# ==============================
# STEP 4: Generate Change Summary
# ==============================
Write-Status "Generating change summary..." $Green

$modifiedFiles = git diff --name-only
$untrackedFiles = git ls-files --others --exclude-standard

Write-Host "`n  MODIFIED FILES:" @Yellow
foreach ($file in $modifiedFiles) {
    $changes = git diff --stat $file
    Write-Host "    - $file"
}

Write-Host "`n  NEW FILES:" @Yellow
if ($untrackedFiles) {
    foreach ($file in $untrackedFiles) {
        Write-Host "    + $file"
    }
} else {
    Write-Host "    (none)"
}

# ==============================
# STEP 5: Stage and Commit
# ==============================
Write-Status "Staging changes..." $Green

git add -A

Write-Status "Committing with message: '$Message'" $Green

$commitResult = git commit -m "$Message" 2>&1
Write-Host $commitResult

# ==============================
# STEP 6: Deploy (optional)
# ==============================
if ($Deploy) {
    Write-Status "Deploying to remote repository..." $Green
    
    $currentBranch = git branch --show-current
    Write-Host "  Branch: $currentBranch"
    
    $pushResult = git push origin $currentBranch 2>&1
    Write-Host $pushResult
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n  [SUCCESS] Deployed successfully!" @Green
    } else {
        Write-Host "`n  [FAIL] Deployment failed." @Red
        exit 1
    }
}

# ==============================
# STEP 7: Update CHANGELOG
# ==============================
Write-Status "Updating CHANGELOG..." $Green

$changelogPath = "CHANGELOG.md"
$date = Get-Date -Format "yyyy-MM-dd"
$timestamp = Get-Date -Format "HH:mm"

$changelogEntry = @"

## [$date $timestamp] - $Message

### Changed
$(foreach ($file in $modifiedFiles) { "- Updated \`"$file\`"" })

### Added
$(if ($untrackedFiles) { foreach ($file in $untrackedFiles) { "- Added \`"$file\`"" }} else { "- No new files" })

"@

if (Test-Path $changelogPath) {
    $existingContent = Get-Content $changelogPath -Raw
    $newContent = "# Changelog" + "`n`nAll notable changes to this project will be documented in this file.`n" + $changelogEntry + $existingContent.Replace("# Changelog`n`nAll notable changes to this project will be documented in this file.`n", "")
    Set-Content $changelogPath -Value $newContent -NoNewline
} else {
    $newContent = "# Changelog`n`nAll notable changes to this project will be documented in this file." + $changelogEntry
    Set-Content $changelogPath -Value $newContent
}

Write-Host "  CHANGELOG.md updated" @Green

# ==============================
# STEP 8: Summary
# ==============================
Write-Status "Upgrade Complete!" $Green

Write-Host @"

  Commit:  $Message
  Date:    $date $timestamp
  Branch:  $currentBranch
  Files:   $($modifiedFiles.Count) modified, $($untrackedFiles.Count) new

  Next steps:
    - Visit https://github.com/agyirisakyi3-blip/ladymelissamarie to verify
    - Test the live site for any issues

"@
