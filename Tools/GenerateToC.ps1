[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string] $FromDate = '2000/01',
    [Parameter(Mandatory=$false)]
    [string] $ToDate = '3000/01'
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ( ($FromDate -notmatch '^\d{4}/\d{2}$') -or ($ToDate -notmatch '^\d{4}/\d{2}$') ) {
    Write-Error "-FromDate and -ToDate must be in the format 'YYYY/MM'."
}

. (Join-Path (Split-Path -Path $MyInvocation.MyCommand.Path) Posts.ps1)

function Reverse
{
    $array = @($input)
    [array]::reverse($array)
    $array
}

function InDateRange([string] $date, [string] $from, [string] $to)
{
    ($date -ge $from) -and ($date -lt $to)
}

$section = $null

$Posts | where { InDateRange $_.OutputDate $FromDate $ToDate } | Reverse | foreach {
    $year = $_.InputDate.Substring(0, 4)
    if ($section -ne $year) {
        $section = $year
        "### $section`n"
    }

    $outputPath = "$($_.OutputDate)/$($_.OutputFile)"
    $title = (Get-Content $outputPath | select -First 1) -replace '^[#]+\s*',''
    "* [$title]($outputPath)"
}
