function Get-VropsResources {
    Param (
        [parameter(Mandatory=$false)][String]$name,
        [parameter(Mandatory=$false)][String]$regex,
        [parameter(Mandatory=$false)][String]$adapterkind,
        [parameter(Mandatory=$false)][String]$resourcekind,
        [parameter(Mandatory=$false)][String]$collectorname,
        [parameter(Mandatory=$false)][String]$collectorid,
        [parameter(Mandatory=$false)][String]$adapterinstanceid,
        [parameter(Mandatory=$false)][String]$resultsperpage = 1000
    )


  



   

    $urlparameters = New-Object -TypeName "System.Collections.ArrayList"
    foreach ($key in $PsBoundParameters.Keys) {
        $thisurlparameter = @{}
        $thisurlparameter.key = $key
        $thisurlparameter.value = $PsBoundParameters[$key]
        $urlparameters.add($thisurlparameter) | out-null
    }



    
    





    $results = New-Object -TypeName "System.Collections.ArrayList"

    $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources'

  


    for ($i=0;$i-lt$urlparameters.count;$i++) {
        if ($i -eq 0) {
            $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources' + '?' + $urlparameters[$i].key + '=' + $urlparameters[$i].value
        }
        else {
            $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources' + '&' + $urlparameters[$i].key + '=' + $urlparameters[$i].value
        }

    }


   

   
    $method = 'GET'

   



    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token




  

  foreach ($resource in $response.resourceList) {
    $results.add($resource) | out-null 
  }

  


    if ($response.pageInfo.totalCount -lt $resultsperpage) {
       
    }
    else {
        
        $totalpages = [math]::ceiling($response.pageInfo.totalCount/$resultsperpage)
      
        for ($i=1;$i-lt$totalpages;$i++) {
            if ($i -eq 1) {
                if ($url -match '=') {
                    $url = $url + '&page=' + $i
                }
                else {
                    $url = $url + '?page=' + $i
                }
                $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
                foreach ($resource in $response.resourceList) {
                    $results.add($resource) | out-null
                }
             
            }
            else {
                $spliturl = $url -split 'page='
                $url = $spliturl[0] + 'page=' + $i
                $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
                foreach ($resource in $response.resourceList) {
                    $results.add($resource) | out-null
                }
      
            }
        }
    }

 

    foreach ($resource in $results) {
        [PSCustomObject]@{
            name = $resource.resourcekey.name
            adapterKindKey = $resource.resourcekey.adapterKindKey
            resourceKindKey = $resource.resourcekey.resourceKindKey
            identifier = $resource.identifier
            creationtime = $resource.creationtime
            resourceHealth = $resource.resourceHealth
            resourceHealthValue = $resource.resourceHealthValue
            
        }
    }


  

}





