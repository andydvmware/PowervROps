function Get-VropsRelationships {
    Param (
        [parameter(Mandatory=$true)][String]$id,
        [parameter(Mandatory=$false)][ValidateSet('PARENT','CHILD','ALL')][String]$relationshiptype,
        [parameter(Mandatory=$false)][String]$resultsperpage = 1000
    )


    if ($relationshiptype) {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources/' + $id + '/relationships?relationshipType=' + $relationshiptype
    }
    else {
        $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources/' + $id + '/relationships'
    }
     



    
    $method = 'GET'
   
    
    
    
    
    $results = New-Object -TypeName "System.Collections.ArrayList"



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
            badges = $resource.badges
            dtEnabled = $resource.dtEnabled
            
        }
    }
}