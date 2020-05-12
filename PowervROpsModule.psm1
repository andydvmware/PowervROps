foreach ($Publicfunction in Get-ChildItem -Path "$($PSScriptRoot)\Functions\*.ps1" -Recurse -Verbose:$VerbosePreference) {
    . $PublicFunction.FullName
    $functionName = [System.IO.Path]::GetFileNameWithoutExtension($PublicFunction)
    Export-ModuleMember -Function ($functionName)
}

$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-Variable -Name vROpsConnection -Scope Global -Force -ErrorAction SilentlyContinue 
}