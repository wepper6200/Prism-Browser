<#
.SYNOPSIS
  Release build for Windows: flutter build, portable zip and (with
  -Installer) the Inno Setup installer. Output goes to dist\.

.DESCRIPTION
  Needs Flutter, Visual Studio 2022 ("Desktop development with C++") and
  Windows Developer Mode (plugin symlinks). The installer additionally needs
  Inno Setup 6.3+ (ISCC.exe) and, to bundle the WebView2 Runtime installer,
  installer\MicrosoftEdgeWebview2Setup.exe (downloaded with -FetchWebView2).

.EXAMPLE
  ./scripts/build_windows.ps1 -Installer -FetchWebView2
#>
param(
  # Also compile installer\prism_browser.iss.
  [switch]$Installer,
  # Download Microsoft's WebView2 Evergreen bootstrapper into installer\.
  [switch]$FetchWebView2
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

function Invoke-Native([string]$exe, [string[]]$arguments) {
  & $exe @arguments
  if ($LASTEXITCODE -ne 0) { throw "$exe exited with $LASTEXITCODE" }
}

# Version from pubspec.yaml ("0.3.0+1" -> name 0.3.0, build 1).
$line = Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)' | Select-Object -First 1
$full = $line.Matches[0].Groups[1].Value
$name, $build = $full.Split('+')
if (-not $build) { $build = '1' }
Write-Host "Prism Browser $name ($build)"

Invoke-Native flutter @('build', 'windows', '--release', "--build-name=$name", "--build-number=$build")

$release = 'build/windows/x64/runner/Release'
foreach ($f in @('prism_browser.exe', 'flutter_windows.dll', 'data/app.so')) {
  if (-not (Test-Path "$release/$f")) { throw "missing $release/$f" }
}
# WebView2 plugin ships its loader next to the exe.
if (-not (Get-ChildItem $release -Filter 'WebView2Loader.dll' -Recurse)) {
  Write-Warning 'WebView2Loader.dll not found in the bundle (check the plugin build)'
}

New-Item -ItemType Directory -Force dist | Out-Null
$zip = "dist/PrismBrowser-$name-windows-x64-portable.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path "$release/*" -DestinationPath $zip
Write-Host "portable: $zip"

if ($Installer) {
  $bootstrapper = 'installer/MicrosoftEdgeWebview2Setup.exe'
  if ($FetchWebView2 -and -not (Test-Path $bootstrapper)) {
    # Official Evergreen bootstrapper (small; downloads the runtime only on
    # machines that lack it, at install time).
    Invoke-WebRequest 'https://go.microsoft.com/fwlink/p/?LinkId=2124703' -OutFile $bootstrapper
  }
  $defines = @('/Q', "/DAppVersion=$name")
  if (Test-Path $bootstrapper) { $defines += '/DBundleWebView2' }
  else { Write-Warning 'No WebView2 bootstrapper: the installer will only link to it' }

  $iscc = (Get-Command ISCC.exe -ErrorAction SilentlyContinue).Source
  if (-not $iscc) {
    $iscc = @(
      "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
      "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
      "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  }
  if (-not $iscc) { throw 'Inno Setup 6 (ISCC.exe) not found' }
  Invoke-Native $iscc ($defines + 'installer/prism_browser.iss')
  Write-Host "installer: dist/PrismBrowser-$name-windows-x64-setup.exe"
}
