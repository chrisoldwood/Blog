Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path (Split-Path -Path $MyInvocation.MyCommand.Path) Posts.ps1)

function Reverse
{
    $array = @($input)
    [array]::reverse($array)
    $array
}

$section = $null

$Posts | Reverse | foreach {
    $year = $_.InputDate.Substring(0, 4)
    if ($section -ne $year) {
        $section = $year
        "### $section`n"
    }

    $outputPath = "$($_.OutputDate)/$($_.OutputFile)"
    $title = (Get-Content $outputPath | select -First 1) -replace '^#\s*',''
    "* [$title]($outputPath)"
}
