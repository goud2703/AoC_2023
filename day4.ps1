$data = Get-Content "$( $PSScriptRoot )/input4.txt"

##part 1
#$data | ForEach-Object {
#    $Game = $_ -split ":" -split "\|"
#    $WinningNumbers = [regex]::Matches($Game[1], "\d+").captures | ForEach-Object { $_.Value }
#    $DrawedNumbers = [regex]::Matches($Game[2], "\d+").captures | ForEach-Object { $_.Value }
#    $Wins = Compare-Object -ReferenceObject $WinningNumbers -DifferenceObject $DrawedNumbers -PassThru -IncludeEqual -ExcludeDifferent
#    if($Wins.Count -gt 0){
#        $Result = 1
#        1..($Wins.Count) | ForEach-Object {$Result = $Result * 2}
#        return $Result / 2
#    }
#    return 0
#} | Measure-Object -Sum

#part 2
$CardValues = $data | ForEach-Object {
    $Game = $_ -split ":" -split "\|"
    $GameNumber = [regex]::Match($Game[0], "(\d+)").Value
    return @{
        gameNumber = $GameNumber
        win = $false
        totalWinCount = 0
    }
}
$data | ForEach-Object {
    $Game = $_ -split ":" -split "\|"
    $GameNumber = [regex]::Match($Game[0], "(\d+)").Value
    $WinningNumbers = [regex]::Matches($Game[1], "\d+").captures | ForEach-Object { $_.Value }
    $DrawedNumbers = [regex]::Matches($Game[2], "\d+").captures | ForEach-Object { $_.Value }
    $Wins = Compare-Object -ReferenceObject $WinningNumbers -DifferenceObject $DrawedNumbers -PassThru -IncludeEqual -ExcludeDifferent
    $CurrentCard = $CardValues | Where-Object -Property gameNumber -EQ $GameNumber
    $CurrentCard.totalWinCount ++
    if ($Wins.Count -gt 0)
    {

        $CurrentCard.win = $true
        1..($Wins.Count) | ForEach-Object {
            $NextIndex = $_
            $NextCardValue = $CardValues | Where-Object {
                $_.gameNumber -eq ($NextIndex + $GameNumber)
            }
            $NextCardValue.totalWinCount += $CurrentCard.totalWinCount
        }
    }
}

$CardValues | ForEach-Object {
    [int]$_.totalWinCount
} | Measure-Object -Sum