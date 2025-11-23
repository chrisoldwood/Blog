Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path -Path $MyInvocation.MyCommand.Path) Posts.ps1)

$baseUrl = 'https://chrisoldwood.blogspot.com'

$Posts | ForEach-Object {
    $inputUrl = "$($_.InputDate)/$($_.InputUrl)"
    $outputPath = "$($_.OutputDate)/$($_.OutputFile)"

    Write-Host "Archiving '$inputUrl' as '$outputPath'"
    if (!(Test-Path $_.OutputDate)) { mkdir $_.OutputDate | Out-Null }
    .\Tools\BlogPostToMarkdown.ps1 "$baseUrl/$inputUrl" "$outputPath"
}
