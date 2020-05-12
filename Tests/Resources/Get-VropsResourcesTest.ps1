


$response = get-vropsresources -name 'vSphere World'


write-host ("response zero: " + $response[0])



$response.count

$response.name
$response.identifier


foreach ($vropsobject in $response) {

    write-host ("Name: " + $vropsobject.name)

}

$response.adapterKindKey





$response = get-vropsresources -adapterkind 'VMWARE'


$response.count

$response.name