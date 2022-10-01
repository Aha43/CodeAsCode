
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

function Write-ViewModel {
    param(
        $Name
    )

    $VmInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Business.ViewModel');
    $ModelInterfaceNs = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Specification.Domain.Model');
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Infrastructure.Business.ViewModel')

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
    
    $Ns = Get-Qualified-Namespace -LocalNameSpace ($SolutionName + '.Infrastructure.Business.ViewController')
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
