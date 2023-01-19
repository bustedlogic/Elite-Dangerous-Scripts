# This script parses each kill in the journal file by hour and by type, outputting a list of totals for each ship type in hourly intervals.

$folder = "$env:USERPROFILE/Saved Games/Frontier Developments/Elite Dangerous/"
$latestLog = Get-ChildItem -Path $folder -Filter "*.log" | Sort-Object LastWriteTime | Select-Object -Last 1
$logContent = Get-Content -Path $latestLog.FullName

$bountiesPerHour = @{}
foreach($line in $logContent) {
    $json = ConvertFrom-Json -InputObject $line
    if($json.event -eq "Bounty") {
        $timeStamp = $json.timestamp
        $time = Get-Date -Date $timeStamp -Format 'yyyy-MM-dd-HH'
        if($json.Target -ne $null) {
            $target = $json.Target
            if($bountiesPerHour.ContainsKey($time)) {
                if($bountiesPerHour[$time].ContainsKey($target)) {
                    $bountiesPerHour[$time][$target] += 1
                } else {
                    $bountiesPerHour[$time][$target] = 1
                }
            } else {
                $bountiesPerHour[$time] = @{$target = 1}
            }
        }
    }
}

$outputTable = @()
foreach ($time in $bountiesPerHour.Keys) {
    $total = ($bountiesPerHour[$time].Values | Measure-Object -Sum).Sum
    $row = [ordered]@{
        'Timestamp' = $time
        'Total' = $total
    }
    foreach($target in $bountiesPerHour[$time].Keys) {
        $row[$target] = $bountiesPerHour[$time][$target]
    }
    $outputTable += New-Object PSObject -Property $row
}

$outputTable | Sort-Object Timestamp | Out-String
