$data = Get-Content "$($PSScriptRoot)/input1.txt"
$numbers = 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'

function Format-Number([string] $value, [string] $regex) {
    return [regex]::Match($_, $regex).Value + [regex]::Match($_, $regex, [System.Text.RegularExpressions.RegexOptions]::RightToLeft).Value
}
 
function Update-String-To-Number([string] $value) {
    $numbers | ForEach-Object {
        $value = $value -replace $_, ($numbers.IndexOf($_) + 1)
    }
    return $value
}

#part 1
$data | ForEach-Object {
    Format-Number -value $_ -regex '\d'
} | Measure-Object -Sum

#part 2 
$data | ForEach-Object {
    Format-Number -value $_ -regex ('\d' + '|' + ($numbers -join '|'))
} | ForEach-Object {
    Update-String-To-Number -value $_
} | Measure-Object -Sum
