class ScriptProperties {
    $PropertyMap = @{}
    $Crud = @('c', 'r', 'u', 'd')

    ScriptProperties(
        [string]$JsonFile
    ) {
        if (Test-Path -Path $JsonFile) {
            [string]$Json = Get-Content -Path $JsonFile
            (ConvertFrom-Json $json).psobject.properties | ForEach-Object { 
                $this.PropertyMap[$_.Name] = $_.Value 
            }
        }

        if ($this.PropertyMap.ContainsKey('CRUD')) {
            $this.Crud = $this.PropertyMap['CRUD'].Split(',')
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

}