# This script reads the latest journal file in the default folder and calculates the number of kills (by bounties) logged in each hourly interval

$folder = "$env:USERPROFILE/Saved Games/Frontier Developments/Elite Dangerous/"
$latestLog = Get-ChildItem -Path $folder -Filter "*.log" | Sort-Object LastWriteTime | Select-Object -Last 1
$logContent = Get-Content -Path $latestLog.FullName

$bountiesPerHour = @{}
foreach($line in $logContent) {
    $json = ConvertFrom-Json -InputObject $line
    if($json.event -eq "Bounty") {
        $timeStamp = $json.timestamp
        $time = Get-Date -Date $timeStamp -Format 'yyyy-MM-dd-HH'
        if($bountiesPerHour.ContainsKey($time)) {
            $bountiesPerHour[$time] += 1
        } else {
            $bountiesPerHour[$time] = 1
        }
    }
}

$bountiesPerHour.GetEnumerator() | Sort-Object Name | Format-Table -AutoSize
