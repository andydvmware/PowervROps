function Disconnect-VropsServer {
    if (!$Global:vROpsConnection){
        throw "No connection to a vROps server has been saved"
    }
    $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/auth/token/release'
    $method = 'POST'
    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
    if ($response.length -gt 0) {
        throw $response
    }
    Remove-Variable -Name vROpsConnection -Scope Global -Force -ErrorAction SilentlyContinue 
}