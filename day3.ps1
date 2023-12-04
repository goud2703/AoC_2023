$data = Get-Content "$( $PSScriptRoot )/input3.txt"

function Get-Parts([string]$RowValues, [int]$RowIndex, [string]$Regex)
{
    $SpecialCaracters = [regex]::Matches($RowValues, $Regex)
    $SpecialCaracters.Captures | ForEach-Object {
        @{
            row = $RowIndex
            column = $_.Index
            value = $_.Value
        }
    } | Where-Object -Property column -NE $null
}

function Validate-Part($Part, $SpecialCharacter)
{
    $ContainsColumn = Compare-Object -ReferenceObject $Part.columns -DifferenceObject $SpecialCharacter.columns -PassThru -IncludeEqual -ExcludeDifferent
    $ContainsRow = Compare-Object -ReferenceObject $Part.row -DifferenceObject $SpecialCharacter.rows -PassThru -IncludeEqual -ExcludeDifferent
    return $ContainsColumn.Count -gt 0 -and $ContainsRow.Count -gt 0
}

$SpecialCharacters = $data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Parts -RowIndex $counter -RowValues $_ -Regex "[^\.\d]"
    $counter++
} | ForEach-Object {
    @{
        value = $_.value
        column = $_.column
        row = $_.row
        rows = ($_.row - 1)..($_.row + 1)
        columns = ($_.column - 1)..($_.column + 1)
    }
}

$Gears = $SpecialCharacters | Where-Object  -Property Value -EQ "*"

$Numbers = $data | ForEach-Object -Begin { $counter = 0 } -Process {
    Get-Parts -RowIndex $counter -RowValues $_ -Regex "\d+"
    $counter++
} | ForEach-Object {
    @{
        value = $_.value
        column = $_.column
        row = $_.row
        columns = $_.column..($_.column + $_.value.length - 1)
    }
}

#part 1
$Numbers | Where-Object {
    $CurrentNumber = $_
    $SpecialCharacters | Where-Object {
        Validate-Part -Part $CurrentNumber -SpecialCharacter $_
    }
} | ForEach-Object {
    [int]$_.value
} | Measure-Object -Sum

#part 2
$Gears | Foreach-Object {
    $CurrentGear = $_
    $MatchingGears = $Numbers | Where-Object {
        Validate-Part -Part $_ -SpecialCharacter $CurrentGear
    } | Foreach-Object {
        [int]$_.value
    }
    if ($MatchingGears.Count -eq 2)
    {
        $MatchingGears[0] * $MatchingGears[1]
    }
} | Measure-Object -Sum
