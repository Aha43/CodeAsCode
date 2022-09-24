
function Push-And-Ensure {
    param (
        $Name
    )
    
    if (-not (Test-Path -Path $Name -PathType Container)) {
        mkdir $Name
    }
    Push-Location $Name
}

function Get-Qualified-Namespace {
    param (
        $LocalNameSpace
    )
    if ($StemNameSpace.Length -gt 0) {
        return $StemNameSpace + '.' + $LocalNameSpace
    }
    return $LocalNameSpace
}

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