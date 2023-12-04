$data = Get-Content "$( $PSScriptRoot )/input2.txt"
$MaxCubeCount = @{ red = 12; green = 13; blue = 14; }

function Get-Color-Value([string] $Subset, [string] $Color)
{
    $Subset -match "(?<$( $Color )>\d+) $( $Color )" | Out-Null
    $Matches[$Color] ?? 0
}

function Test-Subset-Validity([Array]$Subsets)
{
    $IsValid = $Subsets | Foreach-Object {
        ([int](Get-Color-Value -Subset $_ -Color "red") -le $MaxCubeCount.red) -and
                ([int](Get-Color-Value -Subset $_ -Color "green") -le $MaxCubeCount.green) -and
                ([int](Get-Color-Value -Subset $_ -Color "blue") -le $MaxCubeCount.blue)
    }
    return $IsValid -notcontains $false
}

function Get-Subsets-Maximum-Value([Array]$Subsets, [string]$Color)
{
    $SubsetMaximumValue = $Subsets | Foreach-Object {
        [int](Get-Color-Value -Subset $_ -Color $Color)
    } | Measure-Object -Maximum
    return $SubsetMaximumValue.Maximum
}

#part 1
$data | Where-Object {
    $_ -match "Game (\d+):(.*)" | Out-Null
    $Subsets = $Matches[2] -split ";"
    Test-Subset-Validity -Subsets $Subsets
} | ForEach-Object {
    $_ -match "Game (\d+)" | Out-Null
    $Matches[1]
} | Measure-Object -Sum

#part 2
$data | ForEach-Object {
    $_ -match "Game (\d+):(.*)" | Out-Null
    $Subsets = $Matches[2] -split ";"
    $MaxRed = Get-Subsets-Maximum-Value -Subsets $Subsets -Color "red"
    $MaxGreen = Get-Subsets-Maximum-Value -Subsets $Subsets -Color "green"
    $MaxBlue = Get-Subsets-Maximum-Value -Subsets $Subsets -Color "blue"
    $MaxRed * $MaxGreen * $MaxBlue
} | Measure-Object -Sum