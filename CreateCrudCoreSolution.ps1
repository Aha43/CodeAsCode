$SolutionDirParent = './Test'

$SolutionName = 'TheAmazingThing'

$Types = Get-content -Path "./Test/Types.txt"

#
# Functions that generate intial code
#

function Write-Interface {
    param (
        $Path,
        $Ns,
        $Name
    )

    $File = Join-Path -Path $Path -ChildPath ('I' + $Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface I' + $Name) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }
}

function Write-Class {
    param (
        $Path,
        $Using,
        $Ns,
        $Name,
        $Implements
    )

    $File = Join-Path -Path $Path -ChildPath ($Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('using ' + $Using + ';') | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public class ' + $Name + ' : ' + $Implements) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-Api {
    param (
        $Ns,
        $Path
    )

    $t = [char]9

    $File = Join-Path -Path $Path -ChildPath 'ICreate.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface ICreate<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> ReadAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = Join-Path -Path $Path -ChildPath 'IRead.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IRead<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<IEnumerable<T>> ReadAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = Join-Path -Path $Path -ChildPath 'IUpdate.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IUpdate<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> UpdateAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = Join-Path -Path $Path -ChildPath 'IDelete.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IDelete<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> DeleteAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = Join-Path -Path $Path -ChildPath 'ICrud.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface ICrud<T, Cp, Rp, Up, Dp> : ICreate<T, Cp>, IRead<T, Rp>, IUpdate<T, Up>, IDelete<T, Dp> where T : class where Cp : class where Rp : class where Up : class where Dp : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

}

#
# Script starts
#

Push-Location -Path $SolutionDirParent

    if (-not (Test-Path -Path $SolutionName -PathType Container))
    {
        mkdir $SolutionName 
    }
    Push-Location -Path $SolutionName

        if (-not (Test-Path -Path '.gitignore' -PathType Leaf))
        {
            dotnet new gitignore
        }

        if (-not (Test-Path -Path ($SolutionName + '.sln') -PathType Leaf))
        {
            dotnet new sln
        }

        if (-not (Test-Path -Path 'src' -PathType Container))
        {
            mkdir src
        }
        Push-Location 'src' 

            #
            # ENSURE SPECIFICATION PROJECT
            #
            $SpecificationProjectDir = ($SolutionName + '.Specification')
            if (-not (Test-Path -Path $SpecificationProjectDir -PathType Container))
            {
                mkdir $SpecificationProjectDir
            }
            Push-Location $SpecificationProjectDir

                if (-not (Test-Path -Path ($SpecificationProjectDir + ".csproj")))
                {
                    dotnet new classlib  
                    dotnet sln ('../../' + $SolutionName + '.sln') add ($SpecificationProjectDir + ".csproj")
                    Remove-Item Class1.cs
                }

                if (-not (Test-Path -Path 'Domain' -PathType Container))
                {
                    mkdir 'Domain'
                }
                Push-Location 'Domain'

                    if (-not (Test-Path -Path 'Model' -PathType Container))
                    {
                        mkdir 'Model'
                    }
                    Push-Location 'Model'
                            
                        $Ns = ($SpecificationProjectDir + '.Domain.Model')
                        $Dir = Get-Location
                        foreach ($Name in $Types)
                        {
                            Write-Interface -Path $Dir -Ns $Ns -Name $Name
                        }

                    Pop-Location # Model

                    if (-not (Test-Path 'Param' -PathType Container))
                    {
                        mkdir 'Param'
                    } 
                    Push-Location 'Param'

                        foreach ($Name in $Types)
                        {
                            if (-not (Test-Path $Name -PathType Container))
                            {
                                mkdir $Name
                            }
                            Push-Location $Name

                                $Ns = ($SpecificationProjectDir + '.Domain.Param.' + $Name)
                                $Dir = Get-Location
                                
                                Write-Interface -Path $Dir -Ns $Ns -Name ('Create' + $Name + 'Param')
                                Write-Interface -Path $Dir -Ns $Ns -Name ('Read' + $Name + 'Param')
                                Write-Interface -Path $Dir -Ns $Ns -Name ('Update' + $Name + 'Param')
                                Write-Interface -Path $Dir -Ns $Ns -Name ('Delete' + $Name + 'Param')
                                
                            Pop-Location # $Name
                        }

                    Pop-Location # Param

                Pop-Location # Domain

                if (-not (Test-Path -Path 'Api' -PathType Container))
                {
                    mkdir 'Api'
                }
                Push-Location 'Api'

                    if (-not (Test-Path -Path 'Abstraction'))
                    {
                        mkdir 'Abstraction'
                    }
                    Push-Location 'Abstraction'

                        $Dir = Get-Location
                        $Ns = ($SpecificationProjectDir + '.Api.Abstraction')
                        Write-Crud-Api -Path $Dir -Ns $Ns

                    Pop-Location # Abstraction

                Pop-Location # API
                
            Pop-Location # Specification project folder

            #
            # ENSURE DOMAIN PROJECT
            #
            $DomainProjectDir = ($SolutionName + '.Domain')
            if (-not (Test-Path -Path $DomainProjectDir -PathType Container))
            {
                mkdir $DomainProjectDir
            }
            Push-Location $DomainProjectDir

                if (-not (Test-Path -Path ($DomainProjectDir + ".csproj")))
                {
                    dotnet new classlib  

                    dotnet add reference ('../' + $SpecificationProjectDir + "/" + $SpecificationProjectDir + ".csproj")

                    dotnet sln ('../../' + $SolutionName + '.sln') add ($DomainProjectDir + ".csproj")
                    Remove-Item Class1.cs
                }
                

                if (-not (Test-Path -Path 'Model'))
                {
                    mkdir 'Model'
                }
                Push-Location 'Model'

                    $Ns = $DomainProjectDir + '.Model'
                    $Using = $SpecificationProjectDir + '.Domain.Model'
                    $Dir = Get-Location
                    foreach ($Name in $Types)
                    {
                        Write-Class -Path $Dir -Using $Using -Ns $Ns -Implements ('I' + $Name) -Name $Name
                    }

                Pop-Location # Model

                if (-not (Test-Path -Path 'Param'))
                {
                    mkdir 'Param'
                }
                Push-Location 'Param'

                    foreach ($Name in $Types)
                    {
                        if (-not (Test-Path -Path $Name))
                        {
                            mkdir $Name
                        }
                        Push-Location $Name
                            $Dir = Get-Location
                            $Using = $SpecificationProjectDir + '.Domain.Param.' + $Name
                            $Ns = $DomainProjectDir + '.Param.' + $Name
                            
                            Write-Class -Path $Dir -Using $Using -Ns $Ns -Implements ('IRead' + $Name + 'Param') -Name ('Read' + $Name + 'Param')
                            Write-Class -Path $Dir -Using $Using -Ns $Ns -Implements ('ICreate' + $Name + 'Param') -Name ('Create' + $Name + 'Param')
                            Write-Class -Path $Dir -Using $Using -Ns $Ns -Implements ('IUpdate' + $Name + 'Param') -Name ('Update' + $Name + 'Param')
                            Write-Class -Path $Dir -Using $Using -Ns $Ns -Implements ('IDelete' + $Name + 'Param') -Name ('Delete' + $Name + 'Param')
                        Pop-Location # Name
                    }

                Pop-Location # Param

            Pop-Location # DomainProjectDir

        Pop-Location # src

    Pop-Location # from solution dir

Pop-Location # from solution parent dir
