$colourJson = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "colors.json"

$colourObj = Get-Content $colourJson | ConvertFrom-Json

foreach ($lang in $colourObj.PSObject.Properties) {
    foreach ($info in $lang.Value) {
        if ($info | Get-Member -Name "url") {
            $info.PSObject.Properties.Remove("url")
        }
    }
}

ConvertTo-Json -Compress $colourObj | Out-File -FilePath $colourJson -Encoding utf8 -Force
