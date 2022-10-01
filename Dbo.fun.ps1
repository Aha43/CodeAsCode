
function Write-Dbo-Class {
    param (
        $Using,
        $Ns,
        $Name
    )

    if (-not (Test-Path 'Dbo' -PathType Container))
    {
        mkdir 'Dbo'
    }
    Push-Location 'Dbo'

        $Dir = Get-Location
        $File = Join-Path -Path $Dir -ChildPath ($Name + '.cs')

        $Ns = Get-Qualified-Namespace -LocalNameSpace $Ns

        if (-not (Test-Path -Path $File))
        {
            $t = [char]9
            ('namespace ' + $Ns + '.Dbo') | Out-File -FilePath $File
            ('{')  | Out-File -FilePath $File -Append
            ($t + 'public class ' + $Name + 'Dbo') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Implement the class ' + $Ns + '.' + $Name)
        }
    
    Pop-Location # Dbo
}
