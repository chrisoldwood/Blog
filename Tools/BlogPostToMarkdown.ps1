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
$labels = $dom.QuerySelectorAll('.post-labels') | foreach {
        $_.QuerySelectorAll('a') | foreach {
        $_.TextContent.Trim()
    }
}

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
    $body = $body -replace '<br>', "`r`n"

    $body = $body -replace '</?strong>', '**'
    $body = $body -replace '</?em>', '_'
    $body = $body -replace '<a href="([^"]+)"[^>]*>(.*?)</a>', '[$2]($1)'

    $body = $body -replace '&amp;', '&'
    $body = $body -replace '&gt;', '>'
    $body = $body -replace '&lt;', '<'

    $body = $body -replace '<ol>', "`r`n"
    $body = $body -replace '<li>', '- '
    $body = $body -replace '</li>', "`r`n"
    $body = $body -replace '</ol>', "`r`n"

    # Handle monospaced text.
    $body = $body -replace '<span style="font-family:courier new;">(.+)(.*?)</span>', '`$1`\'

    # Ignore weird spans.
    $body = $body -replace '<span class="blsp-spelling-error" id="SPELLING_ERROR_[0-9]+">', ''
    $body = $body -replace '<span class="blsp-spelling-corrected" id="SPELLING_ERROR_[0-9]+">', ''

    # Remove default text style.
    $body = $body -replace '<span>', ''
    $body = $body -replace '<span style="font-family:trebuchet ms;">', ''
    $body = $body -replace '<span style="font-family:verdana;">', ''
    $body = $body -replace '</span>', ''

    # Remove trailing <div style="clear: both;"></div>
    $body = $body -replace '<div[^>]*>', ''
    $body = $body -replace '</div>', ''

    return $body
}

WriteContent "# $title"
WriteContent ''
WriteContent (BodyToMarkdown $body)
WriteContent '---'
WriteContent "Published: $date at $time\"
WriteContent "Labels: $($labels -join ', ')"
