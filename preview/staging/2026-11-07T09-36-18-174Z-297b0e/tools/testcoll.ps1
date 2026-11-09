# testcoll.ps1 ASCII
. "$PSScriptRoot/i18n-slugs.ps1"
$db = Get-Content "C:\Users\HP\OneDrive\Documents\Default Project\data\packages.json" -Raw | ConvertFrom-Json
. "$PSScriptRoot/i18n-urlmap-head.ps1"
