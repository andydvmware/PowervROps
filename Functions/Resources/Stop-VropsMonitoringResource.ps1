function Stop-VropsMonitoringResource {
    <#
    .SYNOPSIS
    Stops an individaual resource from being monitoring in vRops
    
    .DESCRIPTION
    Stops an individaual resource from being monitoring in vRops
    
    .PARAMETER id
    vROps ID

    .PARAMETER adapterID
    The optional query parameter adapterId determines which of the Adapters need to be informed to stop monitoring the Resource. If this is not specified, then all of the Adapters will stop monitoring the Resource.
    
    .EXAMPLE
    Stop-VropsMonitoringResource -id '1536925b-2ee6-440b-9b3d-17c735876708'
    
    #>
    Param (
        [parameter(Mandatory=$false)][String]$adapterid,
        [parameter(Mandatory=$true)][String]$id
    )

    if ($adapterid) {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources/' + $id + '/monitoringstate/stop?adapterid=' + $adapterid
    }
    else {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources/' + $id + '/monitoringstate/stop'
    }
    
    $method = 'PUT'
    Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token

}