function Get-VropsAlertPluginsOfType {
    Param (
        [parameter(Mandatory=$false)]$alertplugintype
    )
    if ($alertplugintype) {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/alertplugins?pluginTypeId=' + $alertplugintype
    }
    else {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/alertplugins'
    }
    $method = 'GET'
    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
    foreach ($notificationPluginInstance in $response.notificationPluginInstances) {
        [PSCustomObject]@{
            PluginTypeId = $notificationPluginInstance.pluginTypeId
            PluginId = $notificationPluginInstance.pluginId
            Name = $notificationPluginInstance.name
            Description = $notificationPluginInstance.description
            Version = $notificationPluginInstance.version
            Enabled = $notificationPluginInstance.enabled
            ConfigValues = $notificationPluginInstance.configValues
        }
    }
}