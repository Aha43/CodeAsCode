
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