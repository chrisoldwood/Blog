Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$posts = @(
    @{ InputDate = '2009/04'; InputUrl='apology-to-raymond-chen.html'; OutputDate = '2009/04'; OutputFile='an-apology-to-raymond-chen.md' }
    @{ InputDate = '2009/05'; InputUrl='who-is-accu.html'; OutputDate = '2009/05'; OutputFile='who-is-the-accu.md' }
    @{ InputDate = '2009/05'; InputUrl='potted-history-of-my-windows-framework.html'; OutputDate = '2009/05'; OutputFile='potted-history-of-my-windows-framework.md' }
    @{ InputDate = '2009/05'; InputUrl='bcs-talk-introduction-to-f.html'; OutputDate = '2009/05'; OutputFile='bcs-talk-introduction-to-fsharp.md' }
)

$baseUrl = 'https://chrisoldwood.blogspot.com'

$posts | ForEach-Object {
    $inputUrl = "$($_.InputDate)/$($_.InputUrl)"
    $outputPath = "$($_.OutputDate)/$($_.OutputFile)"

    Write-Host "Archiving '$inputUrl' as '$outputPath'"
    if (!(Test-Path $_.OutputDate)) { mkdir $_.OutputDate | Out-Null }
    .\Tools\BlogPostToMarkdown.ps1 "$baseUrl/$inputUrl" "$outputPath"
}
