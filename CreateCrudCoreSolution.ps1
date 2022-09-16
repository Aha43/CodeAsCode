$SolutionDirParent = './Test'

$SolutionName = 'TheAmazingThing'
$StemNameSpace = 'No.Super.Corp'

$Types = Get-Content -Path "./Test/Types.txt"
$Stack = Get-Content -Path "./Test/Stack.txt"

#
# Functions that generate intial code
#

function Get_Qualified_Namespace {
    param (
        $StemNameSpace,
        $LocalNameSpace
    )
    if ($StemNameSpace.Length -gt 0)
    {
        return $StemNameSpace + '.' + $LocalNameSpace
    }
    return $LocalNameSpace
}

function Write-Dto-Interface {
    param (
        $Path,
        $StemNs,
        $Ns,
        $Name,
        [Switch]$NoId
    )

    $Ns = Get_Qualified_Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

    $File = Join-Path -Path $Path -ChildPath ('I' + $Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface I' + $Name) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        if ($NoId -eq $false)
        {
            ($t + $t + 'int Id { get; }') | Out-File -FilePath $File -Append
        }
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }
}

function Write-Dto-Class {
    param (
        $Path,
        $Using,
        $StemNs,
        $Ns,
        $Name,
        $Implements,
        [switch]$NoId
    )

    $Ns = Get_Qualified_Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

    $File = Join-Path -Path $Path -ChildPath ($Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('using ' + $StemNs + '.' + $Using + ';') | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public class ' + $Name + ' : ' + $Implements) | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        if ($NoId -eq $false)
        {
            ($t + $t + 'public int Id { get; init; }') | Out-File -FilePath $File -Append
        }
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }
}

function Write-Dbo-Class {
    param (
        $Path,
        $Using,
        $StemNs,
        $Ns,
        $Name
    )

    $Ns = Get_Qualified_Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

    $File = Join-Path -Path $Path -ChildPath ($Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public class ' + $Name + 'Dbo') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'public int Id { get; set; }') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-Abstract-Api {
    param (
        $SolutionName,
        $Path,
        $StemNs
    )

    $Ns = Get_Qualified_Namespace -StemNameSpace $StemNs -LocalNameSpace ($SolutionName + '.Specification.Api.Abstraction')

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

function Write-Crud-Api {
    param (
        $SolutionName,
        $Name,
        $Path,
        $StemNs
    )

    $Ns = Get_Qualified_Namespace -StemNameSpace $StemNs -LocalNameSpace $SolutionName

    $t = [char]9
    
    $File = Join-Path -Path $Path -ChildPath ('I' + $Name + 'Api.cs')
    if (-not (Test-Path -Path $File))
    {
        ('using ' + $Ns + '.Specification.Api.Abstraction;') | Out-File -FilePath $File
        ('using ' + $Ns + '.Specification.Domain.Model;') | Out-File -FilePath $File -Append
        ('using ' + $Ns + '.Specification.Domain.Param.' + $Name +';') | Out-File -FilePath $File -Append
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns + '.Specification.Api') | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append

        $M = 'I' + $Name;
        $C = 'ICreate' + $Name + 'Param'
        $R = 'IRead' + $Name + 'Param'
        $U = 'IUpdate' + $Name + 'Param'
        $D = 'IDelete' + $Name + 'Param'

        ($t + 'public interface I' + $Name + 'Api : ICrud<' + $M + ', ' + $C + ', ' + $R + ', ' + $U + ', ' + $D + '> {}') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}

function Add-Project-And-Push-Location {
    param (
        $Name,
        $Type,
        $StemNs,
        [switch] $Specification,
        [switch] $Domain
    )

    $ProjectDir = ($SolutionName + '.' + $Name)
    if (-not (Test-Path -Path $ProjectDir -PathType Container))
    {
        mkdir $ProjectDir
    }
    Push-Location $ProjectDir

        if (-not (Test-Path -Path ($ProjectDir + ".csproj")))
        {
            $tmp = $StemNameSpace + '.' + $ProjectDir
            dotnet new $Type -n $tmp -o '.'

            Move-Item -Path ('.\' + $tmp + ".csproj") -Destination ('.\' + $ProjectDir + ".csproj")

            dotnet sln ('../../' + $SolutionName + '.sln') add ($ProjectDir + ".csproj")
            if ($Type -eq 'classlib')
            {
                Remove-Item Class1.cs
            }
        }

        if ($Specification)
        {
            dotnet add reference ('../' + $SpecificationProjectDir + "/" + $SpecificationProjectDir + ".csproj")
        }
        if ($Domain)
        {
            dotnet add reference ('../' + $DomainProjectDir + "/" + $DomainProjectDir + ".csproj")
        }
    
    return $ProjectDir
}

# function Add-IoCConf {
#     param (
#         $Name
#     )
    
#     if (-not (Test-Path -Path 'Config' -PathType Container))
#     {
#         mkdir 'Config'
#     }
#     Push-Location 'Config'

#         $t = [char]9
    
#         $File = 'IoCConf.cs'
#         if (-not (Test-Path -Path $File -PathType Leaf))
#         {
#             ('namespace ')
#             ('public static class IoConf') | Out-File -FilePath $File
#             ('{') | Out-File -FilePath $File -Append
#             ($t + 'public static IServiceCollection Configure' + $Name + 'Services(this IServiceCollection services, IConfiguration configuration)')

#             ('}') | Out-File -FilePath $File -Append
#         }

#     Pop-Location # Config

# }

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

            $SpecificationProjectDir = (Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'Specification' -Type 'classlib')[-1]

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
                            Write-Dto-Interface -Path $Dir -StemNs $StemNameSpace -Ns $Ns -Name $Name
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
                                
                                Write-Dto-Interface -Path $Dir -StemNs $StemNameSpace -Ns $Ns -Name ('Create' + $Name + 'Param') -NoId
                                Write-Dto-Interface -Path $Dir -StemNs $StemNameSpace -Ns $Ns -Name ('Read' + $Name + 'Param')
                                Write-Dto-Interface -Path $Dir -StemNs $StemNameSpace -Ns $Ns -Name ('Update' + $Name + 'Param')
                                Write-Dto-Interface -Path $Dir -StemNs $StemNameSpace -Ns $Ns -Name ('Delete' + $Name + 'Param')
                                
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
                        Write-Crud-Abstract-Api -StemNs $StemNameSpace -Path $Dir -SolutionName $SolutionName

                    Pop-Location # Abstraction

                    $Dir = Get-Location
                    foreach ($Name in $Types)
                    {
                        Write-Crud-Api -StemNs $StemNameSpace -SolutionName $SolutionName -Path $Dir -Name $Name
                    }

                Pop-Location # API
                
            Pop-Location # Specification project folder

            $DomainProjectDir = (Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'Domain' -Type 'classlib' -Specification)[-1]

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
                        Write-Dto-Class -Path $Dir -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('I' + $Name) -Name $Name
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
                            
                            Write-Dto-Class -Path $Dir -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('ICreate' + $Name + 'Param') -Name ('Create' + $Name + 'Param') -NoId
                            Write-Dto-Class -Path $Dir -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IRead' + $Name + 'Param') -Name ('Read' + $Name + 'Param')
                            Write-Dto-Class -Path $Dir -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IUpdate' + $Name + 'Param') -Name ('Update' + $Name + 'Param')
                            Write-Dto-Class -Path $Dir -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IDelete' + $Name + 'Param') -Name ('Delete' + $Name + 'Param')
                        Pop-Location # Name
                    }

                Pop-Location # Param

            Pop-Location # DomainProjectDir

            if ($Stack.Contains('application-web-api'))
            {
                Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'WebApi' -Type 'webapi' -Specification -Domain

                Pop-Location # WebApi project dir

                Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'Infrastructure.WebApiClient' -Type 'classlib' -Specification -Domain

                Pop-Location 
            }

            if ($Stack.Contains('repository-sql'))
            {
                Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'Infrastructure.Repository.SqlDatabase' -Type 'classlib' -Specification -Domain

                dotnet add package Dapper

                if (-not (Test-Path -Path 'Dbo'))
                {
                    mkdir 'Dbo'
                }
                Push-Location 'Dbo'

                    $Dir = Get-Location
                    foreach ($Name in $Types)
                    {
                        Write-Dbo-Class -Path $Dir -StemNs $StemNameSpace -Ns 'Infrastructure.Repository.SqlDatabase.Dbo' -Name $Name
                    }

                Pop-Location

                Pop-Location
            }

        Pop-Location # src

        dotnet build

    Pop-Location # from solution dir

Pop-Location # from solution parent dir
