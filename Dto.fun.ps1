function Write-Dto-Interface {
    param (
        $Name,
        $CrudParam,
        [Switch]$NoId
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
        if ($NoId -eq $false) {
            ($t + $t + 'int Id { get; }') | Out-File -FilePath $File -Append
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
        $CrudParam,
        [Switch]$NoId
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
        if ($NoId -eq $false) {
            ($t + $t + 'public int Id { get; init; }') | Out-File -FilePath $File -Append
        }
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append

        Write-ToDo -Item ('Define the ' + $TypeName + ' class')
    }

    Pop-Location
    if ($CrudParam) {
        Pop-Location
    }
}
