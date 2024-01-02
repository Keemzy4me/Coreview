try {
    $jsonData = Get-Content -Raw -Path "C:\Users\LENOVO\Desktop\Preview.json" -ErrorAction Stop | ForEach-Object {
        $_ -replace 'undefined', 'null'  # Replace 'undefined' with 'null' to avoid JSON parsing issues
    } | ConvertFrom-Json
} catch {
    Write-Host "Error: $_"
    break
}

$configDetails = @()

foreach ($action in @("created", "deleted", "failed", "skipped", "unchanged", "updated")) {
    if ($jsonData.$action -ne $null) {
        foreach ($config in $jsonData.$action) {
            $fileInfo = [System.IO.Path]::GetFileNameWithoutExtension($config.fileName)
            $dateTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
            $configName = $config.name
            $configDescription = $null

            if ($config.source -ne $null -and $config.source.description) {
                $configDescription = $config.source.description
            } elseif ($config.target -ne $null -and $config.target.description) {
                $configDescription = $config.target.description
            }

            $configObj = [PSCustomObject]@{
                "File Name" = $fileInfo
                "Date Time" = $dateTime
                "Action" = $action
                "Config Name" = $configName
                "Config Description" = $configDescription
            }
            $configDetails += $configObj
        }
    }
}

$configDetails | Export-Csv -Path "C:/Users/LENOVO/Desktop/output.csv" -NoTypeInformation