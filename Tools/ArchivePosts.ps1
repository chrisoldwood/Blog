Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$posts = @(
    @{ Date = '2009/04'; Input='apology-to-raymond-chen.html'; Output='an-apology-to-raymond-chen.md' }
    @{ Date = '2009/05'; Input='who-is-accu.html'; Output='who-is-the-accu.md' }
    @{ Date = '2009/05'; Input='potted-history-of-my-windows-framework.html'; Output='potted-history-of-my-windows-framework.md' }
    @{ Date = '2009/05'; Input='bcs-talk-introduction-to-f.html'; Output='bcs-talk-introduction-to-fsharp.md' }
)

$baseUrl = 'https://chrisoldwood.blogspot.com'

$posts | ForEach-Object {
    Write-Host "Archiving '$($_.Date)/$($_.Input)' as '$($_.Date)/$($_.Output)'"
    .\Tools\BlogPostToMarkdown.ps1 "$baseUrl/$($_.Date)/$($_.Input)" "$($_.Date)/$($_.Output)"
}
