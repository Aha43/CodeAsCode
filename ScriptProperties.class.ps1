class ScriptProperties {
    $PropertyMap = @{}
    $FrontendStack = @()
    $BackendStack = @()
    $Types = @()

    ScriptProperties(
        [string]$JsonFile
    ) {
        if (Test-Path -Path $JsonFile) {
            [string]$Json = Get-Content -Path $JsonFile
            (ConvertFrom-Json $json).psobject.properties | ForEach-Object { 
                $this.PropertyMap[$_.Name] = $_.Value 
            }
        }

        if ($this.PropertyMap.ContainsKey('FrontendStack')) {
            $this.FrontendStack = $this.PropertyMap['FrontendStack'].Split(',')
        }
        if ($this.PropertyMap.ContainsKey('BackendStack')) {
            $this.BackendStack = $this.PropertyMap['BackendStack'].Split(',')
        }

        if ($this.PropertyMap.ContainsKey('Types')) {
            $this.Types = $this.PropertyMap['Types'].Split(',')
        }
    }

    [string] GetValueOrEmpty(
        [string]$Key
    ) {
        if ($this.PropertyMap.ContainsKey($Key)) {
            return $this.PropertyMap[$Key]
        }
        return ''
    }

    [string] GetStemNamespace() {
        return $this.GetValueOrEmpty('StemNamespace')
    }

    [bool] ShouldWriteCrud(
        [string] $CrudName
    ) {
        if ($CrudName -eq 'Create') {
            return $this.Crud.Contains('c')
        }
        if ($CrudName -eq 'Read') {
            return $this.Crud.Contains('r')
        }
        if ($CrudName -eq 'Update') {
            return $this.Crud.Contains('u')
        }
        if ($CrudName -eq 'Delete') {
            return $this.Crud.Contains('d')
        }

        return $false
    }

    [bool]StacksGotTire(
        [string]$Tier
    ) {
        return ($this.BackendStack.Contains($Tier) -or $this.FrontendStack.Contains($Tier))
    }

    [bool]MakeRepositorySpec() {
        return ($this.StacksGotTire('repository-sql') -or $this.StacksGotTire('application-web-api')) 
    }

    [bool]MakeBusiness() {
        return $this.FrontendStack.Contains('business') -or $this.FrontendStack.Contains('application-blazor-server-mud')
    }

    [bool]MakeCrud(
        [string]$Name,
        [string]$Action
    ) {
        [string]$Key = ($Name + '.Crud')
        if ($this.PropertyMap.ContainsKey($Key)) {
            return $this.PropertyMap[$Key].Split(',').Contains($Action)
        }
        return $true
    }

    [bool]MakeFullCrud(
        [string]$Name
    ) {
        if (-not $this.MakeCrud($Name, 'c')) {
            return $false
        }
        if (-not $this.MakeCrud($Name, 'r')) {
            return $false
        }
        if (-not $this.MakeCrud($Name, 'u')) {
            return $false
        }
        if (-not $this.MakeCrud($Name, 'd')) {
            return $false
        }
        return $true
    }

}