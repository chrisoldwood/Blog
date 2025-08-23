param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $URL,
    [Parameter(Mandatory=$false, Position=1)]
    [string] $OutputFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

If (-not (Get-Module -ErrorAction Ignore -ListAvailable PSParseHTML)) {
  Write-Host "Installing PSParseHTML module for the current user..."
  Install-Module -Scope CurrentUser PSParseHTML
}

$dom = ConvertFrom-Html -Engine AngleSharp -Url $URL
$title = $dom.QuerySelector('.post-title').TextContent.Trim()
$body = $dom.QuerySelectorAll('.post-body').InnerHtml.Trim()
$date = $dom.QuerySelectorAll('.date-header').TextContent.Trim()
$time = $dom.QuerySelectorAll('.published').TextContent.Trim()

if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
}

function WriteContent([string] $content) {
    if ($OutputFile) {
        $content | Out-File -FilePath $OutputFile -Encoding UTF8 -Append
    } else {
        $content | Out-Default
    }
}

function BodyToMarkdown([string] $body) {
    $body = $body -replace '</?span[^>]*>', ''

    $body = $body -replace '<br>', "`n"

    $body = $body -replace '</?em>', '_'
    $body = $body -replace '<a href="([^"]+)"[^>]*>(.*?)</a>', '[$2]($1)'

    $body = $body -replace '&amp;', '&'

    # Remove trailing <div style="clear: both;"></div>
    $body = $body -replace '<div[^>]*>', ''
    $body = $body -replace '</div>', ''

    return $body
}

WriteContent "# $title"
WriteContent ''
WriteContent (BodyToMarkdown $body)
WriteContent '---'
WriteContent "Published: $date at $time"
