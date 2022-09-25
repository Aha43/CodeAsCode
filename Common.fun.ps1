
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

function Test-Stacks-Got-Tire {
    param (
        $Tier
    )
    if ($FrontendStack.Contains($Tier)) {
        return $true
    }
    return $BackendStack.Contains($Tier)
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
        [switch] $Business,
        $ApiTier,
        $ApiType
    )

    Push-And-Ensure -Name $Name

        Write-Readme -Header $Name

        $ProjectFile = ($Name + ".csproj")
        if (-not (Test-Path -Path $ProjectFile -PathType Leaf)) {
            
            $tmp = $StemNameSpace + '.' + $Name

            if ($Type -eq 'application-blazor-server-mud')
            {
                dotnet new mudblazor --host Server -n $tmp -o '.'
            }
            else {
                dotnet new $Type -n $tmp -o '.'
            }
            
            Move-Item -Path ('.\' + $tmp + ".csproj") -Destination ('.\' + $Name + ".csproj")

            $xml = [xml](Get-Content $ProjectFile)
            
            $NamespaceElement = $xml.CreateElement("RootNamespace");
            $NamespaceElement.AppendChild($xml.CreateTextNode(($StemNameSpace + '.' +$Name)))
            $xml.Project.PropertyGroup.AppendChild($NamespaceElement)

            $AssemblyNameElement = $xml.CreateElement("AssemblyName")
            $AssemblyNameElement.AppendChild($xml.CreateTextNode(($StemNameSpace + '.' +$Name)))
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
            if ($Business) {
                dotnet add reference ('../' + $SolutionName + '.Infrastructure.Business/' + $SolutionName + '.Infrastructure.Business.csproj')
            }
        }
    }

    function Edit-ApplicationProgramFile {
        param (
            $Ns
        )
        $File = 'Program.cs'
        $ProgramContent = Get-Content -Path $File
        
        ('using ' + (Get-Qualified-Namespace -LocalNameSpace ($Ns + '.Services;'))) | Out-File -FilePath $File
        ('') | Out-File -FilePath $File -Append
    
        foreach ($Line in $ProgramContent) {
            $Line | Out-File -FilePath $File -Append
            if ($Line -like '*Add services*')
            {
                ('') | Out-File -FilePath $File -Append
                ('builder.Services.AddApplicationServices(builder.Configuration);') | Out-File $File -Append
            }
        }
    }

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
