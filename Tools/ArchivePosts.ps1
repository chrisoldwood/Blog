param (
    [Parameter(Mandatory=$false)]
    [string] $BaseURL = 'https://chrisoldwood.blogspot.com',
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

function InDateRange([string] $date, [string] $from, [string] $to)
{
    ($date -ge $from) -and ($date -lt $to)
}

$Posts | where { InDateRange $_.OutputDate $FromDate $ToDate } | foreach {
    $inputUrl = "$($_.InputDate)/$($_.InputUrl)"
    $outputPath = "$($_.OutputDate)/$($_.OutputFile)"

    Write-Information "Archiving '$inputUrl' as '$outputPath'" -InformationAction Continue
    if (!(Test-Path $_.OutputDate)) { mkdir $_.OutputDate | Out-Null }
    .\Tools\BlogPostToMarkdown.ps1 "$BaseURL/$inputUrl" "$outputPath"
}
