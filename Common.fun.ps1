
function Push-And-Ensure {
    param (
        $Name
    )
    
    if (-not (Test-Path -Path $Name -PathType Container)) {
        mkdir $Name
    }
    Push-Location $Name
}

function Get-Qualified-Namespace {
    param (
        $LocalNameSpace
    )
    if ($StemNameSpace.Length -gt 0) {
        return $StemNameSpace + '.' + $LocalNameSpace
    }
    return $LocalNameSpace
}
