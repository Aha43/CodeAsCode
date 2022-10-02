. ($PSScriptRoot + '/Common.fun.ps1')
. ($PSScriptRoot + '/IoC.fun.ps1')
. ($PSScriptRoot + '/Dto.fun.ps1')
. ($PSScriptRoot + '/Business.fun.ps1')
. ($PSScriptRoot + '/Crud.fun.ps1')
. ($PSScriptRoot + '/Dbo.fun.ps1')
. ($PSScriptRoot + '/WebApi.fun.ps1')
. ($PSScriptRoot + '/ScriptProperties.class.ps1')

if ($args.Count -eq 0){
    Write-Error -Message 'No solution name given as input argument' -ErrorAction Stop
}

#
# Global variables
#
$SolutionName = $args[0]

$SolutionsParentDir = $env:codeascode_repo_dir

$SpecDir = Join-Path -Path $env:codeascode_spec_dir -ChildPath $SolutionName

#$Types = Get-Content -Path (Join-Path -Path $SpecDir -ChildPath 'Types.txt')

$Properties = [ScriptProperties]::new(($SpecDir + '/Properties.json'))

#
# Script starts
#

Push-Location -Path $SolutionsParentDir

    Push-And-Ensure -Name $SolutionName

        if (-not (Test-Path -Path '.gitignore' -PathType Leaf)) {
            dotnet new gitignore
        }

        if (-not (Test-Path -Path ($SolutionName + '.sln') -PathType Leaf)) {
            dotnet new sln
        }

        Copy-JsonTestData

        Push-And-Ensure -Name 'src'

            $SpecificationProjectDir = ($SolutionName + '.Specification')
            Add-Project-And-Push-Location -Name $SpecificationProjectDir -Type 'classlib'

                Push-And-Ensure -Name 'Domain'
                            
                    foreach ($Name in $Properties.Types) {
                        Write-Dto-Interface -Name $Name
                    }

                    foreach ($Name in $Properties.Types) {       
                        Write-Param-Interface -Name $Name -CrudParam 'Create'
                        Write-Param-Interface -Name $Name -CrudParam 'Read'
                        Write-Param-Interface -Name $Name -CrudParam 'Update'
                        Write-Param-Interface -Name $Name -CrudParam 'Delete'
                    }

                Pop-Location # Domain

                if ($Properties.MakeBusiness()) {
                    Push-And-Ensure 'Business'

                        foreach ($Name in $Properties.Types) {
                            Write-ViewModel-Interface -Name $Name
                            Write-ViewController-Interfaces -Name $Name
                        }

                    Pop-Location # Business
                }

                Push-And-Ensure 'Api'

                    Push-And-Ensure 'Abstraction'

                        Write-Crud-Abstract-Api

                    Pop-Location # Abstraction

                    foreach ($Name in $Properties.Types) {
                        Write-Crud-Api -Name $Name
                    }

                    if ($Properties.MakeRepositorySpec() -eq $true) {
                        Push-And-Ensure 'Repository'

                            foreach ($Name in $Properties.Types) {
                                Write-Crud-IRepository -Name $Name
                            }

                        Pop-Location # Repository
                    }
                    
                Pop-Location # API
                
            Pop-Location # Specification project folder

            $DomainProjectDir = ($SolutionName + '.Domain')
            Add-Project-And-Push-Location -Name $DomainProjectDir -Type 'classlib' -Specification

                foreach ($Name in $Properties.Types) {
                    Write-Dto-Class -Name $Name
                }

                foreach ($Name in $Properties.Types) {
                    $Using = $SpecificationProjectDir + '.Domain.Param.' + $Name
                    $Ns = $DomainProjectDir + '.Param.' + $Name
                    
                    Write-Param-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Create'
                    Write-Param-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Read'
                    Write-Param-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Update'
                    Write-Param-Class -Using $Using -Ns $Ns -Name $Name -CrudParam 'Delete'
                }

            Pop-Location # DomainProjectDir

            if ($Properties.BackendStack.Contains('repository-sql')) {
                $SqlDatabaseProjDir = ($SolutionName + '.Infrastructure.Repository.Db')
                Add-Project-And-Push-Location -Name $SqlDatabaseProjDir -Type 'classlib' -Specification -Domain -Configuration -Injection

                    dotnet add package Dapper

                    foreach ($Name in $Properties.Types) {
                        Write-Dbo-Class -Ns $SqlDatabaseProjDir -Name $Name
                    }

                    foreach ($Name in $Properties.Types) {
                        Write-Crud-Api-Implementation -Ns $SqlDatabaseProjDir -Name $Name -Tier 'Repository' -Type 'Db'
                    }

                    Write-Api-IoC -Ns $SqlDatabaseProjDir -Tier 'Repository' -Type 'Db' 

                Pop-Location # SqlDatabaseProjDir
            }

            if ($Properties.BackendStack.Contains('application-web-api')) {
                $WebApiProjDir = ($SolutionName + '.WebApi')
                $ProjectExisted = (Test-Path -Path $WebApiProjDir)
                Add-Project-And-Push-Location -Name $WebApiProjDir -Type 'webapi' -Domain -Specification -ApiTier 'Repository' -ApiType 'Db'

                    Write-Application-IoC -Ns $WebApiProjDir -ApiTier 'Repository' -ApiTierType 'Db'

                    if (-not $ProjectExisted) {
                        Edit-ApplicationProgramFile -Ns $WebApiProjDir
                    }

                    Push-Location 'Controllers'
                        foreach ($Name in $Properties.Types) {
                            Write-WebApi-Controller -Ns $WebApiProjDir -Name $Name -ApiTier 'Repository' -ApiType 'Db'
                        }
                    Pop-Location       

                Pop-Location # WebApiProjDir

                $WebApiClientProjDir = ($SolutionName + '.Infrastructure.Repository.WebApiClient')
                Add-Project-And-Push-Location -Name $WebApiClientProjDir -Type 'classlib' -Specification -Domain -Configuration -Injection -HttpClient

                    foreach ($Name in $Properties.Types) {
                        Write-Crud-Api-Implementation -Ns $WebApiClientProjDir -Name $Name -Tier 'Repository' -Type 'WebApiClient' 
                    }

                    Write-Api-IoC -Ns $WebApiClientProjDir -Tier 'Repository' -Type 'WebApiClient' -UseHttp

                Pop-Location # WebApiClientProjDir
            }

            if ($Properties.MakeBusiness()) {
                $BusinessClientProjDir = ($SolutionName + '.Infrastructure.Business')
                Add-Project-And-Push-Location -Name $BusinessClientProjDir -Type 'classlib' -Specification -Injection -Configuration

                        foreach ($Name in $Properties.Types) {
                            Write-ViewModel -Name $Name
                            Write-ViewControllers -Name $Name
                        }

                        Write-Business-IoC

                Pop-Location # BusinessClientProjDir
            }

            if ($Properties.FrontendStack.Contains('application-blazor-server-mud')) { 

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
