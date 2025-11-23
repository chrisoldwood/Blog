param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $URL,
    [Parameter(Mandatory=$false)]
    [switch] $AsConfig
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

If (-not (Get-Module -ErrorAction Ignore -ListAvailable PSParseHTML)) {
  Write-Host "Installing PSParseHTML module for the current user..."
  Install-Module -Scope CurrentUser PSParseHTML
}

$dom = ConvertFrom-Html -Engine AngleSharp -Url $URL
$history = $dom.QuerySelectorAll('.archivedate') | foreach {
    $href = $_.QuerySelector('.post-count-link').href
    if ($href -match '\d{4}/\d{2}/$') {
        $href
    }
}

function Reverse
{ 
    $array = @($input)
    [array]::reverse($array)
    $array
}

$pages = $history | sort | select -First 3 | foreach {
    $dom = ConvertFrom-Html -Engine AngleSharp -Url $_
    $links = $dom.QuerySelectorAll('.archivedate .expanded') | foreach {
        $_.QuerySelectorAll('.posts') | foreach {
            $_.QuerySelectorAll('li') | foreach {
                $_.QuerySelectorAll('a') | foreach {
                    $_.href
                }
            }
        }
    }
    $links | Reverse
}

$pages | foreach {
    if ($AsConfig) {
        $date = & { $_ -match '/(\d{4}/\d{2})/' | Out-Null; $Matches[1] }
        $title = & { $_ -match '/([a-z0-9-]+).html$' | Out-Null; $Matches[1] }
        "    @{{ InputDate = '{0}'; InputUrl='{1}.html'; OutputDate = '{0}'; OutputFile='{1}.md' }}" -f $date,$title
    } else {
        $_
    }
}
