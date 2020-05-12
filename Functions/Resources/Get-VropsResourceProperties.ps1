function Get-VropsResourceProperties {
    <#
    .SYNOPSIS
    Retrieves a list of properties from a vROps object
    
    .DESCRIPTION
    Takes a single vROps ID, and returns all of the properties for that object
    
    .PARAMETER id
    vROps ID
    
    .EXAMPLE
    $response = Get-VropsResourceProperties -id '1536925b-2ee6-440b-9b3d-17c735876708'
    
    #>
    Param (
        [parameter(Mandatory=$true)][String]$id
    )
    $url = 'https://' + $Global:vROpsConnection.server + '/suite-api/api/resources/' + $id + '/properties'
    $method = 'GET'
    $response = Invoke-VropsRestMethod -method $method -url $url -token $Global:vROpsConnection.token
    foreach ($property in $response.property) {
       [PSCustomObject]@{
            name = $property.name
            value = $property.value   
        }
    }
}



