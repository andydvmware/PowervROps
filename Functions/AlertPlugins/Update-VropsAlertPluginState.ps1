function Update-VropsAlertPluginState {
    Param (
        [parameter(Mandatory=$true)][string]$pluginId,
        [parameter(Mandatory=$true)][ValidateSet('Enabled','Disabled')][string]$state
    )
    if ($state -eq 'Enabled') {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/alertplugins/' + $pluginId + '/enable/true'
    }
    elseif ($state -eq 'Disabled') {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/alertplugins/' + $pluginId + '/enable/false'
        }
    $method = 'PUT'
    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
    if ($response.length -gt 0) {
        throw $response
    }
}