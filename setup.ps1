# One-click installer + launcher for the Prominence II: Hasturian Era server.
# First run: downloads Java 17 + the v4.1.4 server pack, applies our tuned configs,
# imports world.zip if present, then starts the server. Later runs just start it.
param([switch]$NoStart)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$Root     = $PSScriptRoot
$Server   = Join-Path $Root 'server'
$Downloads = Join-Path $Root '_downloads'
$PackUrl  = 'https://www.curseforge.com/api/v1/mods/466901/files/9184730/download'
$PackSize = 1620174106
$JdkUrl   = 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse'

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# Windows' own tools (Windows 10+). Full paths so Git-Bash's tar/curl never get picked up.
$Curl = Join-Path $env:SystemRoot 'System32\curl.exe'
$Tar  = Join-Path $env:SystemRoot 'System32\tar.exe'

function Download($url, $out) {
    & $Curl -L --fail --retry 3 --progress-bar -A 'Mozilla/5.0' -o $out $url
    if ($LASTEXITCODE -ne 0) { throw "Download failed: $url" }
}

function Extract($zip, $dest) {
    & $Tar -xf $zip -C $dest
    if ($LASTEXITCODE -ne 0) { throw "Extract failed: $zip" }
}

New-Item -ItemType Directory -Force $Server, $Downloads | Out-Null

$ramGB = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
if ($ramGB -lt 14) {
    Write-Host "WARNING: this PC has $ramGB GB RAM; the server is set to use 8 GB." -ForegroundColor Yellow
}

# 1. Java 17
$Java = Get-ChildItem (Join-Path $Server 'jdk17') -Filter java.exe -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Directory.Name -eq 'bin' } | Select-Object -First 1
if (-not $Java) {
    Step 'Downloading Java 17 (Temurin)...'
    $jdkZip = Join-Path $Downloads 'jdk17.zip'
    if (-not (Test-Path $jdkZip)) { Download $JdkUrl $jdkZip }
    New-Item -ItemType Directory -Force (Join-Path $Server 'jdk17') | Out-Null
    Extract $jdkZip (Join-Path $Server 'jdk17')
    $Java = Get-ChildItem (Join-Path $Server 'jdk17') -Filter java.exe -Recurse |
            Where-Object { $_.Directory.Name -eq 'bin' } | Select-Object -First 1
}

# 2. Server pack (the zip from CurseForge wraps the real server pack zip)
if (-not (Test-Path (Join-Path $Server 'mods'))) {
    $outer = Join-Path $Downloads 'serverpack-outer.zip'
    if (-not (Test-Path $outer) -or (Get-Item $outer).Length -ne $PackSize) {
        Step 'Downloading Prominence II v4.1.4 server pack (~1.6 GB, takes a while)...'
        Download $PackUrl $outer
    }
    if ((Get-Item $outer).Length -ne $PackSize) { throw 'Server pack download is incomplete. Run again.' }
    Step 'Extracting server pack...'
    $outerDir = Join-Path $Downloads 'outer'
    New-Item -ItemType Directory -Force $outerDir | Out-Null
    Extract $outer $outerDir
    $inner = Get-ChildItem $outerDir -Filter *.zip | Select-Object -First 1
    Extract $inner.FullName $Server
    Remove-Item -LiteralPath $outerDir -Recurse -Force
}

# 3. Our tuned configs (Java path is filled in for this PC)
Step 'Applying tuned configs...'
$javaPath = $Java.FullName -replace '\\', '/'
(Get-Content (Join-Path $Root 'config\variables.txt') -Raw).Replace('__JAVA__', $javaPath) |
    Set-Content (Join-Path $Server 'variables.txt') -Encoding ascii -NoNewline
if (-not (Test-Path (Join-Path $Server 'server.properties'))) {
    Copy-Item (Join-Path $Root 'config\server.properties') $Server
}
Set-Content (Join-Path $Server 'eula.txt') 'eula=true' -Encoding ascii

# 4. Existing world
$worldZip = Join-Path $Root 'world.zip'
if (-not (Test-Path (Join-Path $Server 'world')) -and (Test-Path $worldZip)) {
    Step 'Importing world.zip...'
    Extract $worldZip $Server
}

# 5. playit reminder
$playit = Get-Process playit*, playitd* -ErrorAction SilentlyContinue
if (-not $playit) {
    Write-Host "`nplayit.gg agent is NOT running - friends won't be able to connect. Start it (see README)." -ForegroundColor Yellow
}

if ($NoStart) { Step 'Setup complete (-NoStart given).'; return }
Step 'Starting server... (type "stop" in this window to shut it down safely)'
Set-Location $Server
& cmd.exe /c start.bat
