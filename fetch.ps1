function Request-ColourData {
    $colourDataUri = "https://raw.githubusercontent.com/ozh/github-colors/master/colors.json"

    $webReq = Invoke-WebRequest -Uri $colourDataUri
    $status = $webReq.StatusCode

    if ($status -ne 200) {
        throw "Unable to obtain data due to HTTP error (status code: " + $status + ")"
    }

    return $webReq.Content
}

$colourJson = Join-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "lib") -ChildPath "colors.json"

$colourObj = Request-ColourData | ConvertFrom-Json

foreach ($lang in $colourObj.PSObject.Properties) {
    foreach ($info in $lang.Value) {
        if ($info | Get-Member -Name "url") {
            $info.PSObject.Properties.Remove("url")
        }
    }
}

ConvertTo-Json -Compress $colourObj | Out-File -FilePath $colourJson -Encoding utf8 -Force
