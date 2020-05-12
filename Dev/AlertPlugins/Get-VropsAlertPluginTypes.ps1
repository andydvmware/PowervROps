function Get-VropsAlertPluginTypes {
    $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/alertplugins/types'
    $method = 'GET'
    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
    Foreach ($notificationplugin in $response.notificationPluginType) {
       [PSCustomObject]@{
            PluginType = $notificationplugin
        }
    }
}











