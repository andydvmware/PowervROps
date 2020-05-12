function Get-VropsAdapterInstances {
    Param (
        [parameter(Mandatory=$false)][String]$adapterkindkey
    )




    if ($adpaterkindkey) {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/adapters?adapterkindkey=' + $adapterkindkey
    }
    else {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/adapters/'
    }



  


    $method = 'GET'



    Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token

}