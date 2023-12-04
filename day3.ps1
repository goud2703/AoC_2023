$data = Get-Content "$( $PSScriptRoot )/input3.txt"

function Get-Row-Special-Character([string]$RowValues, [int]$RowIndex, [string]$Regex = "[^\.|\d]")
{
    $SpecialCaracters = [regex]::Matches($RowValues, $Regex)
    $SpecialCaracters.Captures | ForEach-Object {
        @{
            row = $RowIndex
            column = $_.Index
        }
    } | Where-Object -Property column -NE $null
}

$SpecialCharacters = $data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Row-Special-Character -RowIndex $counter -RowValues $_
    $counter++
}

$Gears = $data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Row-Special-Character -RowIndex $counter -RowValues $_ -Regex "\*"
    $counter++
}

function Test-Near-Number([int]$SpecialCharacterRow, [int]$SpecialCharacterColumn, [int]$NumberRow, [int]$NumberColumn)
{
    ($NumberRow -in ([int]$SpecialCharacterRow - 1)..([int]$SpecialCharacterRow + 1)) -and
            ($NumberColumn -in ([int]$SpecialCharacterColumn - 1)..([int]$SpecialCharacterColumn + 1))
}

function Get-Row-Numbers([string]$RowValues, [int]$RowIndex)
{
    $RowNumbers = [regex]::Matches($RowValues, "(\d+)")
    $RowNumbers.Captures | ForEach-Object {
        @{
            value = [int]$_.Value
            row = $RowIndex
            column = $_.Index
        }
    } | Where-Object -Property value -ne $null
}

function Test-Number-Near-Special-Charater([int]$NumberRow, [int]$NumberColumn, [string]$NumberValue)
{
    (0..($NumberValue.Length - 1) | Foreach-Object {
        $NumberCount = $_
        $SpecialCharacters | ForEach-Object {
            $result = Test-Near-Number -SpecialCharacterRow $_.row -SpecialCharacterColumn $_.column -NumberRow $NumberRow -NumberColumn ($NumberColumn + $NumberCount)
            #            Write-Host $_.row $_.column $NumberRow ($NumberColumn + $NumberCount) $result
            return $result
        }
    }) -contains $true
}

$Numbers = $data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Row-Numbers -RowValues $_ -RowIndex $counter
    $counter++
}

# Part 1
$data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Row-Numbers -RowValues $_ -RowIndex $counter
    $counter++
} | Where-Object {
    Test-Number-Near-Special-Charater -NumberRow $_.row -NumberColumn $_.column -NumberValue $_.value
} | ForEach-Object {
    [int]$_.value
} | Measure-Object -Sum

# Part 2
$Gears | ForEach-Object {
    $Gear = $_
    $CloseNumbers = $Numbers | Where-Object {
        #        Test-Near-Number -SpecialCharacterRow $Gear.row -SpecialCharacterColumn $Gear.column -NumberRow $_.row -NumberColumn $_.column
        $CurrentNumber = $_
        (0..(([string]$_.Value).Length - 1) | Foreach-Object {
            $NumberCount = $_
            Test-Near-Number -SpecialCharacterRow $Gear.row -SpecialCharacterColumn $Gear.column -NumberRow $CurrentNumber.row -NumberColumn ($CurrentNumber.column + $NumberCount)
        }) -contains $true
    }
    $FoundNumbers = $CloseNumbers | ForEach-Object { $_.value }

    if ($FoundNumbers.Count -eq 2)
    {
        return [int]($FoundNumbers[0] * $FoundNumbers[1])
    }
} | Measure-Object -Sum
