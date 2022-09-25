. ($PSScriptRoot + '/Common.fun.ps1')
. ($PSScriptRoot + '/IoC.fun.ps1')
. ($PSScriptRoot + '/Dto.fun.ps1')
. ($PSScriptRoot + '/Business.fun.ps1')

if ($args.Count -eq 0){
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
$FrontendStack = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'FrontendStack.txt')
$BackendStack = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'BackendStack.txt')

$MakeRepositorySpec = (Test-Stacks-Got-Tire -Tier 'application-web-api') -or (Test-Stacks-Got-Tire -Tier 'repository-sql')

$Business = $false # read | detect later
if ($FrontendStack.Contains('business') -or 
    $FrontendStack.Contains('application-blazor-server-mud')) {
    $Business = $true
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

    $File = 'ICreate.cs'
    if (-not (Test-Path -Path $File)) {

        $t = [char]9

        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface ICreate<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> CreateAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = 'IRead.cs'
    if (-not (Test-Path -Path $File)) {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IRead<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<IEnumerable<T>> ReadAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = 'IUpdate.cs'
    if (-not (Test-Path -Path $File)) {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IUpdate<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> UpdateAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = 'IDelete.cs'
    if (-not (Test-Path -Path $File)) {
        ('namespace ' + $Ns) | Out-File -FilePath $File
        ('{')  | Out-File -FilePath $File -Append
        ($t + 'public interface IDelete<T, P> where T : class where P : class') | Out-File -FilePath $File -Append
        ($t + '{') | Out-File -FilePath $File -Append
        ($t + $t + 'Task<T> DeleteAsync(P param, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
        ($t + '}') | Out-File -FilePath $File -Append 
        ('} ') | Out-File -FilePath $File -Append
    }

    $File = 'ICrud.cs'
    if (-not (Test-Path -Path $File)) {
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
    
    $File = ('I' + $Name + 'Api.cs')
    if (-not (Test-Path -Path $File)) {
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

    $Ns = Get-Qualified-Namespace -LocalNameSpace $SolutionName

    $File = ($Name + 'Repository.cs')
    if (-not (Test-Path -Path $File -PathType Leaf)) {
        ('namespace ' + $Ns + '.Specification.Api.Repository') | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'Repository : I' + $Name + 'Api { }') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}

function Write-Crud-Api-Implementation {
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
    $File = ($ClassName + '.cs')
    if (-not (Test-Path -Path $File -PathType Leaf)) {
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

function Write-WebApi-Controller {
    param (
        $Ns,
        $Name,
        $ApiTier
    )
    
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Controllers')

    $StemNs = Get-Qualified-Namespace -LocalNameSpace $SolutionName

    $t = [char]9

    $ApiName = ('I' + $Name + $ApiTier)

    $ClassName = ($Name + 'Controller')
    $File = ($ClassName + '.cs')
    
    if (-not (Test-Path -Path $File -PathType Leaf)) {
        ('using Microsoft.AspNetCore.Mvc;') | Out-File -FilePath $File -Append
        ('using ' + $StemNs + '.Domain.Param.' + $Name +';') | Out-File -FilePath $File -Append
        ('using ' + $StemNs + '.Specification.Api.' + $ApiTier +';') | Out-File -FilePath $File -Append
        ('') | Out-File -FilePath $File -Append
        ('namespace ' + $Ns) | Out-File -FilePath $File -Append
        ('{') | Out-File -FilePath $File -Append
            ($t + '[ApiController]') | Out-File -FilePath $File -Append
            ($t + '[Route("[controller]")]') | Out-File -FilePath $File -Append
            ($t + 'public class ' + $ClassName + ' : ControllerBase') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
                ($t + $t + 'private readonly ' + $ApiName + ' _api;') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append
                ($t + $t + 'public ' + $ClassName + '(' + $ApiName + ' api) => _api = api;') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append
                
                ($t + $t + '[HttpPost] public async Task<IActionResult> PostAsync([FromBody] Create' + $Name + 'Param param) => Ok(await _api.CreateAsync(param).ConfigureAwait(false));') | Out-File -FilePath $File -Append
                ($t + $t + '[HttpGet] public async Task<IActionResult> GetAsync([FromQuery] Read' + $Name + 'Param param) => Ok(await _api.ReadAsync(param).ConfigureAwait(false));') | Out-File -FilePath $File -Append
                ($t + $t + '[HttpPut] public async Task<IActionResult> PutAsync([FromBody] Update' + $Name + 'Param param) => Ok(await _api.UpdateAsync(param).ConfigureAwait(false));') | Out-File -FilePath $File -Append
                ($t + $t + '[HttpDelete] public async Task<IActionResult> DeleteAsync([FromQuery] Delete' + $Name + 'Param param) => Ok(await _api.DeleteAsync(param).ConfigureAwait(false));') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}

#
# Script starts
#

Push-Location -Path $SolutionsParentDir

    Push-And-Ensure -Name $SolutionName

        if (-not (Test-Path -Path '.gitignore' -PathType Leaf))
        {
            dotnet new gitignore
        }

        if (-not (Test-Path -Path ($SolutionName + '.sln') -PathType Leaf))
        {
            dotnet new sln
        }

        Push-And-Ensure -Name 'src'

            $SpecificationProjectDir = ($SolutionName + '.Specification')
            Add-Project-And-Push-Location -Name $SpecificationProjectDir -Type 'classlib'

                Push-And-Ensure -Name 'Domain'
                            
                    foreach ($Name in $Types) {
                        Write-Dto-Interface -Name $Name
                    }

                    foreach ($Name in $Types) {       
                        Write-Dto-Interface -Name $Name -NoId -CrudParam 'Create'
                        Write-Dto-Interface -Name $Name -CrudParam 'Read'
                        Write-Dto-Interface -Name $Name -CrudParam 'Update'
                        Write-Dto-Interface -Name $Name -CrudParam 'Delete'
                    }

                Pop-Location # Domain

                if ($Business)
                {
                    Push-And-Ensure 'Business'

                        foreach ($Name in $Types)
                        {
                            Write-ViewModel-Interface -Name $Name
                            Write-ViewController-Interfaces -Name $Name
                        }

                    Pop-Location # Business
                }

                Push-And-Ensure 'Api'

                    Push-And-Ensure 'Abstraction'

                        Write-Crud-Abstract-Api

                    Pop-Location # Abstraction

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Api -Name $Name
                    }

                    if ($MakeRepositorySpec -eq $true)
                    {
                        Push-And-Ensure 'Repository'

                            foreach ($Name in $Types) {
                                Write-Crud-IRepository -Name $Name
                            }

                        Pop-Location # Repository
                    }
                    
                Pop-Location # API
                
            Pop-Location # Specification project folder

            $DomainProjectDir = ($SolutionName + '.Domain')
            Add-Project-And-Push-Location -Name $DomainProjectDir -Type 'classlib' -Specification

                foreach ($Name in $Types) {
                    Write-Dto-Class -Name $Name
                }

                foreach ($Name in $Types) {
                    $Using = $SpecificationProjectDir + '.Domain.Param.' + $Name
                    $Ns = $DomainProjectDir + '.Param.' + $Name
                    
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Create' -NoId
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Read'
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Update'
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Delete'
                }

            Pop-Location # DomainProjectDir

            if (Test-Stacks-Got-Tire -Tier 'repository-sql') {
                $SqlDatabaseProjDir = ($SolutionName + '.Infrastructure.Repository.Db')
                Add-Project-And-Push-Location -Name $SqlDatabaseProjDir -Type 'classlib' -Specification -Domain -Configuration -Injection

                    dotnet add package Dapper

                    foreach ($Name in $Types) {
                        Write-Dbo-Class -Ns $SqlDatabaseProjDir -Name $Name
                    }

                    foreach ($Name in $Types) {
                        Write-Crud-Api-Implementation -Ns $SqlDatabaseProjDir -Name $Name -Tier 'Repository' -Type 'Db'
                    }

                    Write-Api-IoC -Ns $SqlDatabaseProjDir -Tier 'Repository' -Type 'Db' 

                Pop-Location # SqlDatabaseProjDir
            }

            if ($BackendStack.Contains('application-web-api')) {
                $WebApiProjDir = ($SolutionName + '.WebApi')
                $ProjectExisted = (Test-Path -Path $WebApiProjDir)
                Add-Project-And-Push-Location -Name $WebApiProjDir -Type 'webapi' -Domain -Specification -ApiTier 'Repository' -ApiType 'Db'

                    Write-Application-IoC -Ns $WebApiProjDir -ApiTier 'Repository' -ApiTierType 'Db'

                    if (-not $ProjectExisted) {
                        Edit-ApplicationProgramFile -Ns $WebApiProjDir
                    }

                    Push-Location 'Controllers'
                        foreach ($Name in $Types) {
                            Write-WebApi-Controller -Ns $WebApiProjDir -Name $Name -ApiTier 'Repository' -ApiType 'Db'
                        }
                    Pop-Location       

                Pop-Location # WebApiProjDir

                $WebApiClientProjDir = ($SolutionName + '.Infrastructure.Repository.WebApiClient')
                Add-Project-And-Push-Location -Name $WebApiClientProjDir -Type 'classlib' -Specification -Domain -Configuration -Injection -HttpClient

                    foreach ($Name in $Types) {
                        Write-Crud-Api-Implementation -Ns $WebApiClientProjDir -Name $Name -Tier 'Repository' -Type 'WebApiClient' 
                    }

                    Write-Api-IoC -Ns $WebApiClientProjDir -Tier 'Repository' -Type 'WebApiClient' -UseHttp

                Pop-Location # WebApiClientProjDir
            }

            if ($Business) {
                $BusinessClientProjDir = ($SolutionName + '.Infrastructure.Business')
                Add-Project-And-Push-Location -Name $BusinessClientProjDir -Type 'classlib' -Specification -Injection -Configuration

                        foreach ($Name in $Types) {
                            Write-ViewModel -Name $Name
                            Write-ViewControllers -Name $Name
                        }

                        Write-Business-IoC

                Pop-Location # BusinessClientProjDir
            }

            if ($FrontendStack.Contains('application-blazor-server-mud')) {
                $MudBlazorServerProjDir = ($SolutionName + '.MudBlazorServer')
                $ProjectExisted = (Test-Path -Path $MudBlazorServerProjDir)
                Add-Project-And-Push-Location -Name $MudBlazorServerProjDir -Type 'application-blazor-server-mud' -Specification -Business

                Write-Application-IoC -Ns $MudBlazorServerProjDir -ApiTier 'Business'

                if (-not $ProjectExisted) {
                    Edit-ApplicationProgramFile -Ns $MudBlazorServerProjDir
                }

                Pop-Location # MudBlazorServerProjDir
            }

        Pop-Location # src

        dotnet build

        Write-Readme -Header $SolutionName

    Pop-Location # solution dir

Pop-Location # solution parent dir
