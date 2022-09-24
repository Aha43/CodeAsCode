. ($PSScriptRoot + '/Common.fun.ps1')

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

function StacksGotTire {
    param (
        $Tier
    )
    if ($FrontendStack.Contains($Tier)) {
        return $true
    }
    return $BackendStack.Contains($Tier)
}

$MakeRepositorySpec = (StacksGotTire -Tier 'application-web-api') -or (StacksGotTire -Tier 'repository-sql')

$Business = $false # read | detect later
if ($FrontendStack.Contains('business') -or 
    $FrontendStack.Contains('application-blazor-server-mud')) {
    $Business = $true
}

#
# Functions that generate code
#

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

function Write-ViewModel-Interface {
    param (
        $Name
    )

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewModel')

    Push-And-Ensure -Name 'ViewModel'

        $File = ('I' + $Name + 'ViewModel.cs')
        if (-not (Test-Path -Path $File))
        {
            $t = [char]9
            ('namespace ' + $Ns) | Out-File -FilePath $File
            ('{')  | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'ViewModel') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
            ($t + $t + 'int Id { get; }') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Define the ' + $Name + ' ViewModel by modifing the interface ' + $Ns + '.I' + $Name + 'ViewModel')
        }
    Pop-Location
}

function Write-ViewController-Interfaces {
    param (
        $Name
    )

    $VmNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewModel')
    $Ns = Get-Qualified-Namespace -LocalNameSpace  ($SolutionName + '.Specification.Business.ViewController')

    Push-And-Ensure -Name 'ViewController'

        $File = ('I' + $Name + 'ViewController.cs')
        if (-not (Test-Path -Path $File))
        {
            $t = [char]9

            ('using ' + $VmNs + ';') | Out-File -FilePath $File
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{')  | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'ViewController') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
            ($t + $t + 'Task LoadAsync(int id, CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
            ($t + $t + 'I' + $Name + 'ViewModel ' + $Name + ' { get; }') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Define the ' + $Name + ' ViewController by modifing the interface ' + $Ns + '.I' + $Name + 'ViewController')
        }

        $File = ('I' + $Name + 'sViewController.cs')
        if (-not (Test-Path -Path $File))
        {
            $t = [char]9

            ('using ' + $VmNs + ';') | Out-File -FilePath $File
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{')  | Out-File -FilePath $File -Append
            ($t + 'public interface I' + $Name + 'sViewController') | Out-File -FilePath $File -Append
            ($t + '{') | Out-File -FilePath $File -Append
            ($t + $t + 'Task LoadAsync(CancellationToken cancellationToken = default);') | Out-File -FilePath $File -Append
            ($t + $t + 'IEnumerable<I' + $Name + 'ViewModel> ' + $Name + 's { get; }') | Out-File -FilePath $File -Append
            ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Define the ' + $Name + 's ViewController by modifing the interface ' + $Ns + '.I' + $Name + 'sViewController')
        }

    Pop-Location
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

function Write-ViewModel {
    param(
        $Name
    )

    $VmInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewModel');
    $ModelInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Domain.Model');
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Business.ViewModel')

    Push-And-Ensure -Name 'ViewModel'

        $Class = $Name + 'ViewModel'
        
        $File = ($Class + 'ViewModel.cs')
        if (-not (Test-Path -Path $File)) {
            $t = [char]9

            $ModelInterface = ('I' + $Name)
            $Interface = ('I' + $Name + 'ViewModel')

            ('using ' + $VmInterfaceNs + ';') | Out-File -FilePath $File
            ('using ' + $ModelInterfaceNs + ';') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{')  | Out-File -FilePath $File -Append
                ($t + 'public class ' + $Class + ' : ' + $Interface) | Out-File -FilePath $File -Append
                ($t + '{') | Out-File -FilePath $File -Append
                    ($t + $t + 'private readonly ' + $ModelInterface + '? _model;') | Out-File -FilePath $File -Append
                    ('') | Out-File -FilePath $File -Append
                    ($t + $t + 'public ' + $Class + '(' + $ModelInterface + '? model = null) => _model = model;') | Out-File -FilePath $File -Append
                    ($t + $t + 'public int Id => _model?.Id ?? 0;') | Out-File -FilePath $File -Append
                    ('') | Out-File -FilePath $File -Append
                    ($t + $t + 'public static ' + $Class + ' Empty => new();') | Out-File -FilePath $File -Append
                ($t + '}') | Out-File -FilePath $File -Append 
            ('} ') | Out-File -FilePath $File -Append

            Write-ToDo -Item ('Implement the ' + $Class)
        }

    Pop-Location # ViewModel
}

function Write-ViewControllers {
    param (
        $Name
    )
    
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + 'Business.ViewController')
    $VmInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewModel');
    $VmCntInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewController');

    Push-And-Ensure -Name 'ViewController'

        $Class = ($Name + 'ViewController')
        $File = ($Class + '.cs')
        if (-not (Test-Path -Path $File -PathType Leaf)) {

            $t = [char]9

            ('using ' + $VmInterfaceNs + ';') | Out-File -FilePath $File
            ('using ' + $VmCntInterfaceNs + ';') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{') | Out-File -FilePath $File -Append
                ($t + 'public class ' + $Class + ' : I' + $Class) | Out-File -FilePath $File -Append
                ($t + '{') | Out-File -FilePath $File -Append
                    ($t + $t + 'public I' + $Name + 'ViewModel ' + $Name + ' => throw new NotImplementedException();') | Out-File -FilePath $File -Append
                    ('') | Out-File -FilePath $File -Append
                    ($t + $t + 'public async Task LoadAsync(int id, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                    ($t + $t + '{') | Out-File -FilePath $File -Append
                        ($t + $t + $t + 'throw new NotImplementedException();') | Out-File -FilePath $File -Append
                    ($t + $t + '}') | Out-File -FilePath $File -Append
                ($t + '}') | Out-File -FilePath $File -Append
            ('}') | Out-File -FilePath $File -Append
        }

        $Class = ($Name + 'sViewController')
        $File = ($Class + 's.cs')
        if (-not (Test-Path -Path $File -PathType Leaf)) {

            $t = [char]9

            ('using ' + $VmInterfaceNs + ';') | Out-File -FilePath $File
            ('using ' + $VmCntInterfaceNs + ';') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{') | Out-File -FilePath $File -Append
                ($t + 'public class ' + $Class + ' : I' + $Class) | Out-File -FilePath $File -Append
                ($t + '{') | Out-File -FilePath $File -Append
                    ($t + $t + 'public IEnumerable<I' + $Name + 'ViewModel> ' + $Name + 's => throw new NotImplementedException();') | Out-File -FilePath $File -Append
                    ('') | Out-File -FilePath $File -Append
                    ($t + $t + 'public async Task LoadAsync(CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                    ($t + $t + '{') | Out-File -FilePath $File -Append
                        ($t + $t + $t + 'throw new NotImplementedException();') | Out-File -FilePath $File -Append
                    ($t + $t + '}') | Out-File -FilePath $File -Append
                ($t + '}') | Out-File -FilePath $File -Append
            ('}') | Out-File -FilePath $File -Append
        }

    Pop-Location # ViewController
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

function Write-Application-IoC {
    param (
        $Ns,
        $ApiTier,
        $ApiTierType
    )
    
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Services')

    Push-And-Ensure -Name 'Services'

        $t = [char]9

        $File = Join-Path -Path (Get-Location) -ChildPath 'IoCConf.cs'
        if (-not (Test-Path -Path $File -PathType Leaf)) {
            $LocalApiNs = ($SolutionName + ".Infrastructure." + $ApiTier + '.' + $ApiTierType + '.Services')
            $ApiServicesNs = (Get-Qualified-Namespace -LocalNameSpace $LocalApiNs)

            ('using ' + $ApiServicesNs + ';') | Out-File -FilePath $File -Append
            #('using Microsoft.Extensions.Configuration;') | Out-File -FilePath $File -Append
            #('using Microsoft.Extensions.DependencyInjection;') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
            ('namespace ' + $Ns) | Out-File -FilePath $File -Append
            ('{') | Out-File -FilePath $File -Append
                ($t + 'public static class IoCConf') | Out-File -FilePath $File -Append
                ($t + '{') | Out-File -FilePath $File -Append
                    ($t + $t + 'public static IServiceCollection AddApplicationServices(this IServiceCollection services, IConfiguration configuration)') | Out-File -FilePath $File -Append
                    ($t + $t + '{') | Out-File -FilePath $File -Append

                        $ApiServicesMethod = ("Add" + $ApiTierType + $ApiTier + "Services")
                        ($t + $t + $t + 'services.' + $ApiServicesMethod + '(configuration);') | Out-File -FilePath $File -Append            

                        ($t + $t + $t + 'return services;') | Out-File -FilePath $File -Append
                    ($t + $t + '}') | Out-File -FilePath $File -Append
                ($t + '}') | Out-File -FilePath $File -Append
            ('}') | Out-File -FilePath $File -Append
        }

    Pop-Location # Services
}

function Edit-ApplicationProgramFile {
    param (
        $Ns
    )
    $File = 'Program.cs'
    $ProgramContent = Get-Content -Path $File
    
    ('using ' + (Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Services;'))) | Out-File -FilePath $File

    foreach ($Line in $ProgramContent) {
        $Line | Out-File -FilePath $File -Append
        if ($Line -like '*Add services*')
        {
            ('') | Out-File -FilePath $File -Append
            ('builder.Services.AddApplicationServices(builder.Configuration);') | Out-File $File -Append
            ('') | Out-File -FilePath $File -Append
        }
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

function Write-Api-IoC {
    param (
        $Ns,
        $Tier,
        $Type,
        [switch] $UseHttp
    )

    $Ns = Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Services')
    
    Push-And-Ensure 'Services'

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
        [switch] $HttpClient,
        $ApiTier,
        $ApiType
    )

    $ProjectDir = ($SolutionName + '.' + $Name)
    Push-And-Ensure -Name $ProjectDir

        Write-Readme -Header $Name

        $ProjectFile = ($ProjectDir + ".csproj")
        if (-not (Test-Path -Path $ProjectFile -PathType Leaf)) {
            
            $tmp = $StemNameSpace + '.' + $ProjectDir

            if ($Type -eq 'application-blazor-server-mud')
            {
                dotnet new mudblazor --host Server -n $tmp -o '.'
            }
            else {
                dotnet new $Type -n $tmp -o '.'
            }
            
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

            if ($Type -eq 'classlib') {
                Remove-Item Class1.cs
            }

            if ($Specification) {
                dotnet add reference ('../' + $SpecificationProjectDir + "/" + $SpecificationProjectDir + ".csproj")
            }
            if ($Domain) {
                dotnet add reference ('../' + $DomainProjectDir + "/" + $DomainProjectDir + ".csproj")
            }
            if ($Configuration) {
                dotnet add package Microsoft.Extensions.Configuration.Abstractions
            }
            if ($Injection) {
                dotnet add package Microsoft.Extensions.DependencyInjection.Abstractions
            }
            if ($HttpClient) {
                dotnet add package Microsoft.Extensions.Http
            }
            if ($ApiTier) {
                $ApiProject = ($SolutionName + '.Infrastructure.' + $ApiTier + '.' + $ApiType)
                dotnet add reference ('../' + $ApiProject + "/" + $ApiProject + ".csproj")
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
    if (-not (Test-Path -Path $File)) {
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
    if (-not (Test-Path -Path $File)) {
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

            $SpecificationProjectDir = (Add-Project-And-Push-Location -Name 'Specification' -Type 'classlib')[-1]

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

                            foreach ($Name in $Types)
                            {
                                Write-Crud-IRepository -Name $Name
                            }

                        Pop-Location # Repository
                    }
                    
                Pop-Location # API
                
            Pop-Location # Specification project folder

            $DomainProjectDir = (Add-Project-And-Push-Location -Name 'Domain' -Type 'classlib' -Specification)[-1]

                foreach ($Name in $Types)
                {
                    Write-Dto-Class -Name $Name
                }

                foreach ($Name in $Types)
                {
                    $Using = $SpecificationProjectDir + '.Domain.Param.' + $Name
                    $Ns = $DomainProjectDir + '.Param.' + $Name
                    
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Create' -NoId
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Read'
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Update'
                    Write-Dto-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Delete'
                }

            Pop-Location # DomainProjectDir

            if (StacksGotTire -Tier 'repository-sql')
            {
                $ApiProject =
                $SqlDatabaseProjDir = (Add-Project-And-Push-Location -Name 'Infrastructure.Repository.Db' -Type 'classlib' -Specification -Domain -Configuration -Injection)[-1]

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

            if ($BackendStack.Contains('application-web-api'))
            {
                $WebApiProjDir = (Add-Project-And-Push-Location -Name 'WebApi' -Type 'webapi' -Domain -Specification -ApiTier 'Repository' -ApiType 'Db')[-1]

                    Write-Application-IoC -Ns $WebApiProjDir -ApiTier 'Repository' -ApiTierType 'Db'

                    Edit-ApplicationProgramFile -Ns $WebApiProjDir

                    Push-Location 'Controllers'
                        foreach ($Name in $Types)
                        {
                            Write-WebApi-Controller -Ns $WebApiProjDir -Name $Name -ApiTier 'Repository' -ApiType 'Db'
                        }
                    Pop-Location       

                Pop-Location # WebApiProjDir

                $WebApiClientProjDir = (Add-Project-And-Push-Location -Name 'Infrastructure.Repository.WebApiClient' -Type 'classlib' -Specification -Domain -Configuration -Injection -HttpClient)[-1]

                    foreach ($Name in $Types)
                    {
                        Write-Crud-Implemenation -Ns $WebApiClientProjDir -Name $Name -Tier 'Repository' -Type 'WebApiClient' 
                    }

                    Write-Api-IoC -Ns $WebApiClientProjDir -Tier 'Repository' -Type 'WebApiClient' -UseHttp

                Pop-Location # WebApiClientProjDir
            }

            if ($Business)
            {
                $WebApiClientProjDir = (Add-Project-And-Push-Location -Name 'Business' -Type 'classlib' -Specification)[-1]

                        foreach ($Name in $Types) {
                            Write-ViewModel -Name $Name
                            Write-ViewControllers -Name $Name
                        }

                Pop-Location # Business project dir
            }

            if ($FrontendStack.Contains('application-blazor-server-mud'))
            {
                $MudBlazorServerProjDir = (Add-Project-And-Push-Location -Name 'MudBlazorServer' -Type 'application-blazor-server-mud' -Specification)[-1]

                Pop-Location # 
            }

        Pop-Location # src

        dotnet build

        Write-Readme -Header $SolutionName

    Pop-Location # solution dir

Pop-Location # solution parent dir
