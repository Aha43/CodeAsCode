

if ($args.Count -eq 0)
{
    Write-Error -Message 'No solution name given as input argument' -ErrorAction Stop
}

$SolutionName = $args[0]

$SolutionsParentDir = $env:codeascode_repo_dir

$SpecDir = Join-Path -Path $env:codeascode_spec_dir -ChildPath $SolutionName

$StemNameSpace = [Io.File]::ReadAllText((Join-Path -Path $SpecDir -ChildPath 'StemNamespace.txt').Trim())

$Types = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'Types.txt')
$Stack = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'Stack.txt')

$MakeRepositorySpec = ($Stack.Contains('application-web-api') -or $Stack.Contains('repository-sql'))

#
# Functions that generate intial code
#

function Get-Qualified-Namespace {
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
        $StemNs,
        $Ns,
        $Name,
        [Switch]$NoId
    )

    $Path = Get-Location

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

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
        $Using,
        $StemNs,
        $Ns,
        $Name,
        $Implements,
        [switch]$NoId
    )

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

    $Path = Get-Location
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
        $Using,
        $StemNs,
        $Ns,
        $Name
    )

    $File = Join-Path -Path (Get-Location) -ChildPath ($Name + '.cs')

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $Ns

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
        $StemNs
    )

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace ($SolutionName + '.Specification.Api.Abstraction')

    $t = [char]9

    $Path = Get-Location

    $File = Join-Path -Path $Path -ChildPath 'ICreate.cs'
    if (-not (Test-Path -Path $File))
    {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface ICreate<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> CreateAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
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
        $StemNs
    )

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $SolutionName

    $t = [char]9

    $Path = Get-Location
    
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

            ($t + 'public interface I' + $Name + 'Api : ICrud<' + $M + ', ' + $C + ', ' + $R + ', ' + $U + ', ' + $D + '> { }') | Out-File -FilePath $File -Append

        ('}') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-IRepository {
    param (
        $SolutionName,
        $Name,
        $StemNs
    )

    $t = [char]9

    $Path = Get-Location

    $Ns = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $SolutionName

    $File = Join-Path -Path $Path -ChildPath ($Name + 'Repository.cs')
    if (-not (Test-Path -Path $File -PathType Leaf))
    {
        ('namespace ' + $Ns + '.Specification.Api.Repository') | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'Repository : I' + $Name + 'Api {}') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-Implemenation {
    param (
        $SolutionName,
        $Name,
        $Type,
        $Tier,
        $Ns,
        $StemNs
    )

    $t = [char]9

    $RootNs = Get-Qualified-Namespace -StemNameSpace $StemNs -LocalNameSpace $SolutionName

    $ClassName = ($Name + $Type + $Tier)
    $File = Join-Path -Path (Get-Location) -ChildPath ($ClassName + '.cs')
    if (-not (Test-Path -Path $File -PathType Leaf))
    {
        ('using ' + $RootNs + '.Domain.Model;') | Out-File -FilePath $File -Append
        ('using ' + $RootNs + '.Specification.Api.' + $Tier +';') | Out-File -FilePath $File -Append
        ('using ' + $RootNs + '.Specification.Domain.Model;') | Out-File -FilePath $File -Append
        ('using ' + $RootNs + '.Specification.Domain.Param.' + $Name + ';') | Out-File -FilePath $File -Append
        
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $RootNs + '.' + $Ns) | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + 'public class ' + $ClassName + ' : I' + $Name + $Tier) | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<I' + $Name +'> CreateAsync(ICreate' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new ' + $Name + ' { });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<IEnumerable<I' + $Name +'>> ReadAsync(IRead' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new List<' + $Name + '>() { new ' + $Name + ' { Id = param.Id } });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<I' + $Name +'> UpdateAsync(IUpdate' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new ' + $Name + ' { Id = param.Id });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<I' + $Name +'> DeleteAsync(IDelete' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new ' + $Name + ' { Id = param.Id });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

            ($t + '}') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
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

        $ProjectFile = ($ProjectDir + ".csproj")
        if (-not (Test-Path -Path $ProjectFile -PathType Leaf))
        {
            $tmp = $StemNameSpace + '.' + $ProjectDir
            dotnet new $Type -n $tmp -o '.'
            Move-Item -Path ('.\' + $tmp + ".csproj") -Destination ('.\' + $ProjectDir + ".csproj")

            $xml = [xml](Get-Content $ProjectFile)
            
            $NamespaceElement = $xml.CreateElement("RootNamespace");
            $NamespaceElement.AppendChild($xml.CreateTextNode(($StemNs + '.' +$ProjectDir)))
            $xml.Project.PropertyGroup.AppendChild($NamespaceElement)

            $AssemblyNameElement = $xml.CreateElement("AssemblyName")
            $AssemblyNameElement.AppendChild($xml.CreateTextNode(($StemNs + '.' +$ProjectDir)))
            $xml.Project.PropertyGroup.AppendChild($AssemblyNameElement)
    
            $location = Get-Location
            $SavePath = Join-Path -Path $location -ChildPath $ProjectFile
            $xml.Save($SavePath)
            

            dotnet sln ('../../' + $SolutionName + '.sln') add $ProjectFile

            if ($Type -eq 'classlib')
            {
                Remove-Item Class1.cs
            }

            if ($Specification)
            {
                dotnet add reference ('../' + $SpecificationProjectDir + "/" + $SpecificationProjectDir + ".csproj")
            }
            if ($Domain)
            {
                dotnet add reference ('../' + $DomainProjectDir + "/" + $DomainProjectDir + ".csproj")
            }
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

Push-Location -Path $SolutionsParentDir

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
                        foreach ($Name in $Types)
                        {
                            Write-Dto-Interface -StemNs $StemNameSpace -Ns $Ns -Name $Name
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
                                
                                Write-Dto-Interface -StemNs $StemNameSpace -Ns $Ns -Name ('Create' + $Name + 'Param') -NoId
                                Write-Dto-Interface -StemNs $StemNameSpace -Ns $Ns -Name ('Read' + $Name + 'Param')
                                Write-Dto-Interface -StemNs $StemNameSpace -Ns $Ns -Name ('Update' + $Name + 'Param')
                                Write-Dto-Interface -StemNs $StemNameSpace -Ns $Ns -Name ('Delete' + $Name + 'Param')
                                
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

                        Write-Crud-Abstract-Api -StemNs $StemNameSpace -SolutionName $SolutionName

                    Pop-Location # Abstraction

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Api -StemNs $StemNameSpace -SolutionName $SolutionName -Name $Name
                    }

                    if ($MakeRepositorySpec -eq $true)
                    {
                        if (-not (Test-Path -Path 'Repository'))
                        {
                            mkdir 'Repository'  
                        }
                        Push-Location 'Repository'

                            foreach ($Name in $Types)
                            {
                                Write-Crud-IRepository -SolutionName $SolutionName -Name $Name -StemNs $StemNameSpace
                            }

                        Pop-Location # Repository
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
                    foreach ($Name in $Types)
                    {
                        Write-Dto-Class -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('I' + $Name) -Name $Name
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
                            $Using = $SpecificationProjectDir + '.Domain.Param.' + $Name
                            $Ns = $DomainProjectDir + '.Param.' + $Name
                            
                            Write-Dto-Class -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('ICreate' + $Name + 'Param') -Name ('Create' + $Name + 'Param') -NoId
                            Write-Dto-Class -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IRead' + $Name + 'Param') -Name ('Read' + $Name + 'Param')
                            Write-Dto-Class -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IUpdate' + $Name + 'Param') -Name ('Update' + $Name + 'Param')
                            Write-Dto-Class -Using $Using -StemNs $StemNameSpace -Ns $Ns -Implements ('IDelete' + $Name + 'Param') -Name ('Delete' + $Name + 'Param')
                        Pop-Location # Name
                    }

                Pop-Location # Param

            Pop-Location # DomainProjectDir

            

            if ($Stack.Contains('application-web-api'))
            {
                Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'WebApi' -Type 'webapi' -Specification -Domain

                Pop-Location # WebApi project dir

                Add-Project-And-Push-Location -StemNs $StemNameSpace -Name 'Infrastructure.Repository.WebApiClient' -Type 'classlib' -Specification -Domain

                foreach ($Name in $Types)
                {
                    Write-Crud-Implemenation -Name $Name -SolutionName $SolutionName -Type 'Client' -Tier 'Repository' -StemNs $StemNameSpace -Ns 'Infrastructure.Repository.WebApiClient' 
                }

                Pop-Location # WebApi client dir
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

                        foreach ($Name in $Types)
                        {
                            Write-Dbo-Class -StemNs $StemNameSpace -Ns ($SolutionName + '.Infrastructure.Repository.SqlDatabase.Dbo') -Name $Name
                        }

                    Pop-Location # Dbo

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Implemenation -Name $Name -SolutionName $SolutionName -Type 'Db' -Tier 'Repository' -StemNs $StemNameSpace -Ns 'Infrastructure.Repository.SqlDatabase' 
                    }

                Pop-Location # repository sql project dir
            }

        Pop-Location # src

        dotnet build

    Pop-Location # from solution dir

Pop-Location # from solution parent dir
