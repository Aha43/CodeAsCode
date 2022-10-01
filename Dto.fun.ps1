
function Write-Properties {
    param (
        [string]$Name,
        [bool]$Class = $true
    )

    $SpecFile = ($Name + '.props.txt')
    $SpecPath = Join-Path -Path $SpecDir -ChildPath $specFile
    if (Test-Path -Path $specPath -PathType Leaf) {
        $PropsLines = Get-Content -Path $specPath
        foreach ($Line in $PropsLines) {
            $Tokens = $Line.Split()
            $IsCollection = (($Tokens.Count -gt 2) -and ($Tokens[2] -eq '*'))
            $Code = ($t + $t + 'public ')
            if ($IsCollection) {
                $Code = ($Code + 'IEnumerable<' + $Tokens[0] + '>')
            } else {
                $Code = ($Code + $Tokens[0])
            }
            $Code = ($Code + ' ' + $Tokens[1] + ' { get; ')
            if ($Class) {
                $Code = ($Code + 'init; ')
            }
            $Code = ($Code + '}')
            $Code | Out-File -FilePath $File -Append
        }
    }
}



function Write-Dto-Interface {
    param (
        $Name,
        $CrudParam
    )

    $TypeName = $Name

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Domain.')
    if ($CrudParam) {
        Push-And-Ensure -Name 'Param'
        Push-And-Ensure -Name $Name
        $Ns += ('Param.' + $Name)
        $TypeName = ($CrudParam + $Name + 'Param')
    }
    else {
        Push-And-Ensure -Name 'Model'
        $Ns += 'Model'
    }

    $File = ('I' + $TypeName + '.cs')
    if (-not (Test-Path -Path $File)) {
        $t = [char]9
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface I' + $TypeName) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append

        if ((-not $CrudParam) -or (($CrudParam -eq 'Create') -or ($CrudParam -eq 'Update'))) {
            Write-Properties -Name $Name -Class $false
        }

        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append

        Write-ToDo -Item ('Define the ' + $TypeName + ' interface')
    }

    Pop-Location
    if ($CrudParam) {
        Pop-Location
    }
}

function Write-Dto-Class {
    param (
        $Name,
        $CrudParam
    )

    $TypeName = $Name
    $Implements = ('I' + $Name)
    $Using = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Domain.Model')

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Domain.')
    if ($CrudParam) {
        Push-And-Ensure -Name 'Param'
            Push-And-Ensure -Name $Name
                $Ns += ('Param.' + $Name)
                $TypeName = ($CrudParam + $Name + 'Param')
                $Implements = ('I' + $TypeName)
                $Using = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Domain.Param.' + $Name)
    }
    else {
        Push-And-Ensure -Name 'Model'
            $Ns += 'Model'
    }

    $File = ($TypeName + '.cs')
    if (-not (Test-Path -Path $File)) {

        $t = [char]9
        ('using ' + $Using + ';') | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public class ' + $TypeName + ' : ' + $Implements) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append

        Write-Properties -Name $Name

        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append

        Write-ToDo -Item ('Define the ' + $TypeName + ' class')
    }

    Pop-Location
    if ($CrudParam) {
        Pop-Location
    }
}
