
if ($args.Count -eq 0)
{
    Write-Error -Message 'No solution name given as input argument' -ErrorAction Stop
}

#
# Global variables
#
$SolutionName = $args[0]

$SolutionsParentDir = $env:codeascode_repo_dir

$SpecDir = Join-Path -Path $env:codeascode_spec_dir -ChildPath $SolutionName

$StemNameSpace = [Io.File]::ReadAllText((Join-Path -Path $SpecDir -ChildPath 'StemNamespace.txt').Trim())

$Types = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'Types.txt')
$Stack = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'Stack.txt')

$MakeRepositorySpec = ($Stack.Contains('application-web-api') -or $Stack.Contains('repository-sql'))

#
# Functions that generate code
#

function Get-Qualified-Namespace {
    param (
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
        $Ns,
        $Name,
        [Switch]$NoId
    )

    $Path = Get-Location

    $Ns = Get-Qualified-Namespace -LocalNameSpace $Ns

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

        Write-ToDo -Item ('Define the ' + $Name + ' by adding properties to the interface ' + $Ns + '.I' + $Name)
    }
}

function Write-Dto-Class {
    param (
        $Using,
        $Ns,
        $Name,
        $Implements,
        [switch]$NoId
    )

    $Ns = Get-Qualified-Namespace -LocalNameSpace $Ns

    $Path = Get-Location
    $File = Join-Path -Path $Path -ChildPath ($Name + '.cs')
    if (-not (Test-Path -Path $File))
    {
        $t = [char]9
        ('using ' + $StemNameSpace + '.' + $Using + ';') | Out-File -FilePath $File
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

        Write-ToDo -Item ('Implement the class ' + $Ns + '.' + $Name)
    }
}

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
            ($t + $t + 'public int Id { get; set; }') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Implement the class ' + $Ns + '.' + $Name)
        }
    
    Pop-Location # Dbo
}

function Write-Crud-Abstract-Api {

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Api.Abstraction')

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
        $Name
    )

    $Ns = Get-Qualified-Namespace -LocalNameSpace $SolutionName

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
        $Name
    )

    $t = [char]9

    $Path = Get-Location

    $Ns = Get-Qualified-Namespace -LocalNameSpace $SolutionName

    $File = Join-Path -Path $Path -ChildPath ($Name + 'Repository.cs')
    if (-not (Test-Path -Path $File -PathType Leaf))
    {
        ('namespace ' + $Ns + '.Specification.Api.Repository') | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'Repository : I' + $Name + 'Api { }') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-Implemenation {
    param (
        $Ns,
        $Name,
        $Tier,
        $Type
    )

    $t = [char]9

    $Ns = Get-Qualified-Namespace -LocalNameSpace $Ns
    $RootNs = Get-Qualified-Namespace -LocalNameSpace $SolutionName

    $ClassName = ($Name + $Type + $Tier)
    $File = Join-Path -Path (Get-Location) -ChildPath ($ClassName + '.cs')
    if (-not (Test-Path -Path $File -PathType Leaf))
    {
        Write-ToDo -Item ('Implement the class ' + $Ns + '.' + $ClassName)

        ('using ' + $RootNs + '.Domain.Model;') | Out-File -FilePath $File
        ('using ' + $RootNs + '.Specification.Api.' + $Tier +';') | Out-File -FilePath $File -Append
        ('using ' + $RootNs + '.Specification.Domain.Model;') | Out-File -FilePath $File -Append
        ('using ' + $RootNs + '.Specification.Domain.Param.' + $Name + ';') | Out-File -FilePath $File -Append
        
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
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

function Write-Api-IoC {
    param (
        $Ns,
        $Tier,
        $Type,
        [switch] $UseHttp
    )

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Services')
    
    if (-not (Test-Path -Path 'Services' -PathType Container))
    {
        mkdir 'Services'
    }
    Push-Location 'Services'

        $t = [char]9
    
        $File = Join-Path -Path (Get-Location) -ChildPath 'IoCConf.cs'
        if (-not (Test-Path -Path $File -PathType Leaf))
        {
            ('using Microsoft.Extensions.Configuration;') | Out-File -FilePath $File
            ('using Microsoft.Extensions.DependencyInjection;') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{') | Out-File -FilePath $File -Append
                ($t + 'public static class IoCConf') | Out-File -FilePath $File -Append
                ($t + '{') | Out-File -FilePath $File -Append
                    ($t + $t + 'public static IServiceCollection Add' + $Type + $Tier + 'Services(this IServiceCollection services, IConfiguration configuration)') | Out-File -FilePath $File -Append
                    ($t + $t + '{') | Out-File -FilePath $File -Append
                        if ($UseHttp)
                        {
                            (($t + $t + $t + 'services.AddHttpClient();') | Out-File -FilePath $File -Append) | Out-File -FilePath $File -Append
                        }
                        (($t + $t + $t + 'services.AddApiServices();') | Out-File -FilePath $File -Append) | Out-File -FilePath $File -Append
                        ($t + $t + $t + 'return services;') | Out-File -FilePath $File -Append
                    ($t + $t + '}') | Out-File -FilePath $File -Append
                ($t + '}') | Out-File -FilePath $File -Append
            ('}') | Out-File -FilePath $File -Append
        }

        $File = Join-Path -Path (Get-Location) -ChildPath 'InternalIoCConf.cs'

        $ApiNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Api.' + $Tier)
        ('// Do not edit this file, it is generated every time codeascode script is run!') | Out-File -FilePath $File
        ('// Add implemention specific services in the IoCConf file') | Out-File -FilePath $File -Append
        ('using ' + $ApiNs + ';') | Out-File -FilePath $File -Append
        ('using Microsoft.Extensions.DependencyInjection;') | Out-File -FilePath $File -Append
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + 'internal static class InternalIoCConf') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
                ($t + $t + 'internal static IServiceCollection AddApiServices(this IServiceCollection services)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                    foreach ($Name in $Types)
                    {
                        ($t + $t + $t + 'services.AddSingleton<I' + $Name + $Tier + ', ' + $Name + $Type + $Tier + '>();') | Out-File -FilePath $File -Append
                    }
                    ($t + $t + $t + 'return services;') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append

    Pop-Location # Config
}

#
# Functions that create projects
#

function Add-Project-And-Push-Location {
    param (
        $Name,
        $Type,
        [switch] $Specification,
        [switch] $Domain,
        [switch] $Configuration,
        [switch] $Injection,
        [switch] $HttpClient
    )

    $ProjectDir = ($SolutionName + '.' + $Name)
    if (-not (Test-Path -Path $ProjectDir -PathType Container))
    {
        mkdir $ProjectDir
    }
    Push-Location $ProjectDir

        Write-Readme -Header $Name

        $ProjectFile = ($ProjectDir + ".csproj")
        if (-not (Test-Path -Path $ProjectFile -PathType Leaf))
        {
            $tmp = $StemNameSpace + '.' + $ProjectDir
            dotnet new $Type -n $tmp -o '.'
            Move-Item -Path ('.\' + $tmp + ".csproj") -Destination ('.\' + $ProjectDir + ".csproj")

            $xml = [xml](Get-Content $ProjectFile)
            
            $NamespaceElement = $xml.CreateElement("RootNamespace");
            $NamespaceElement.AppendChild($xml.CreateTextNode(($StemNameSpace + '.' +$ProjectDir)))
            $xml.Project.PropertyGroup.AppendChild($NamespaceElement)

            $AssemblyNameElement = $xml.CreateElement("AssemblyName")
            $AssemblyNameElement.AppendChild($xml.CreateTextNode(($StemNameSpace + '.' +$ProjectDir)))
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
            if ($Configuration)
            {
                dotnet add package Microsoft.Extensions.Configuration.Abstractions
            }
            if ($Injection)
            {
                dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions
            }
            if ($HttpClient)
            {
                dotnet add package Microsoft.Extensions.Http
            }
        }

        return $ProjectDir
}

#
# Functions that write no code files
#

function Write-ToDo {
    param (
        $Item
    )
    
    $File = ($SolutionsParentDir + '/' + $SolutionName + '/ToDo.md')
    if (-not (Test-Path -Path $File))
    {
        ('# ToDo') | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append
    }
    ('- [ ] ' + $Item) | Out-File -FilePath $File -Append
}

function Write-Readme {
    param (
        $Header
    )
    $File = "README.md"
    if (-not (Test-Path -Path $File))
    {
        ('# ' + $Header) | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append

        $loc = Get-Location
        Write-ToDo -Item ('Write content for the README file: ' + $loc + '\README.md')
    }
}

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

            $SpecificationProjectDir = (Add-Project-And-Push-Location -Name 'Specification' -Type 'classlib')[-1]

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
                            Write-Dto-Interface -Ns $Ns -Name $Name
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
                                
                                Write-Dto-Interface -Ns $Ns -Name ('Create' + $Name + 'Param') -NoId
                                Write-Dto-Interface -Ns $Ns -Name ('Read' + $Name + 'Param')
                                Write-Dto-Interface -Ns $Ns -Name ('Update' + $Name + 'Param')
                                Write-Dto-Interface -Ns $Ns -Name ('Delete' + $Name + 'Param')
                                
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

                        Write-Crud-Abstract-Api

                    Pop-Location # Abstraction

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Api -Name $Name
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
                                Write-Crud-IRepository -Name $Name
                            }

                        Pop-Location # Repository
                    }
                    
                Pop-Location # API
                
            Pop-Location # Specification project folder

            $DomainProjectDir = (Add-Project-And-Push-Location -Name 'Domain' -Type 'classlib' -Specification)[-1]

                if (-not (Test-Path -Path 'Model'))
                {
                    mkdir 'Model'
                }
                Push-Location 'Model'

                    $Ns = $DomainProjectDir + '.Model'
                    $Using = $SpecificationProjectDir + '.Domain.Model'
                    foreach ($Name in $Types)
                    {
                        Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -Implements ('I' + $Name) 
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
                            
                            Write-Dto-Class -Using $Using -Ns $Ns -Name ('Create' + $Name + 'Param') -Implements ('ICreate' + $Name + 'Param') -NoId
                            Write-Dto-Class -Using $Using -Ns $Ns -Name ('Read' + $Name + 'Param')   -Implements ('IRead' + $Name + 'Param')
                            Write-Dto-Class -Using $Using -Ns $Ns -Name ('Update' + $Name + 'Param') -Implements ('IUpdate' + $Name + 'Param')
                            Write-Dto-Class -Using $Using -Ns $Ns -Name ('Delete' + $Name + 'Param') -Implements ('IDelete' + $Name + 'Param')
                        Pop-Location # Name
                    }

                Pop-Location # Param

            Pop-Location # DomainProjectDir

            if ($Stack.Contains('application-web-api'))
            {
                $WebApiProjDir = (Add-Project-And-Push-Location -Name 'WebApi' -Type 'webapi' -Specification -Domain)[-1]

                Pop-Location # WebApiProjDir

                $WebApiClientProjDir = (Add-Project-And-Push-Location -Name 'Infrastructure.Repository.WebApiClient' -Type 'classlib' -Specification -Domain  -Configuration -Injection -HttpClient)[-1]

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Implemenation -Ns $WebApiClientProjDir -Name $Name -Tier 'Repository' -Type 'WebApiClient' 
                    }

                    Write-Api-IoC -Ns $WebApiClientProjDir -Tier 'Repository' -Type 'WebApiClient' -UseHttp

                Pop-Location # WebApiClientProjDir
            }

            if ($Stack.Contains('repository-sql'))
            {
                $SqlDatabaseProjDir = (Add-Project-And-Push-Location -Name 'Infrastructure.Repository.SqlDatabase' -Type 'classlib' -Specification -Domain -Configuration -Injection)[-1]

                    dotnet add package Dapper

                    foreach ($Name in $Types)
                    {
                        Write-Dbo-Class -Ns $SqlDatabaseProjDir -Name $Name
                    }

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Implemenation -Ns $SqlDatabaseProjDir -Name $Name -Tier 'Repository' -Type 'Db'
                    }

                    Write-Api-IoC -Ns $SqlDatabaseProjDir -Tier 'Repository' -Type 'Db'

                Pop-Location # SqlDatabaseProjDir
            }

        Pop-Location # src

        dotnet build

        Write-Readme -Header $SolutionName

    Pop-Location # from solution dir

Pop-Location # from solution parent dir
