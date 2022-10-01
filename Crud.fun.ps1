
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

    $JsonDataFile = (Join-Path -Path $SpecDir -ChildPath ($Name + ".data.json"))
    $SrcJsonDataFile = ('..\\..\\test-data\\' + $Name + '.data.json')

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
        if (Test-Path -Path $JsonDataFile -PathType Leaf) {
            ('using System.Text.Json;') | Out-File -FilePath $File -Append
        }
        
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

                $JsonDataFile = (Join-Path -Path $SpecDir -ChildPath ($Name + ".data.json"))
                if (Test-Path -Path $JsonDataFile -PathType Leaf) {
                    #$CodePath = $JsonDataFile.Replace('\', '\\')
                    ($t + $t + $t + 'using FileStream openStream = File.OpenRead("' + $SrcJsonDataFile + '");') | Out-File -FilePath $File -Append
                    ($t + $t + $t + 'var data = await JsonSerializer.DeserializeAsync<IEnumerable<' + $Name + '>>(openStream);') | Out-File -FilePath $File -Append
                    ($t + $t + $t + 'return data;') | Out-File -FilePath $File -Append
                } else {
                    ($t + $t + $t + 'return await Task.FromResult(new List<' + $Name + '>() { new ' + $Name + ' { } });') | Out-File -FilePath $File -Append
                }

                
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<I' + $Name +'> UpdateAsync(IUpdate' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new ' + $Name + ' { });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

                ($t + $t + 'public async Task<I' + $Name +'> DeleteAsync(IDelete' + $Name + 'Param param, CancellationToken cancellationToken = default)') | Out-File -FilePath $File -Append
                ($t + $t + '{') | Out-File -FilePath $File -Append
                ($t + $t + $t + 'return await Task.FromResult(new ' + $Name + ' { });') | Out-File -FilePath $File -Append
                ($t + $t + '}') | Out-File -FilePath $File -Append
                ('') | Out-File -FilePath $File -Append

            ($t + '}') | Out-File -FilePath $File -Append
            ('') | Out-File -FilePath $File -Append
        ('}') | Out-File -FilePath $File -Append
    }
}
