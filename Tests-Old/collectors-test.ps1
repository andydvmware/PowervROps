param(
	[parameter(Mandatory=$false)][string]$token,
	[parameter(Mandatory=$false)]$credentials,
	[parameter(Mandatory=$true)][string]$resthost
	)
if ($credentials -eq $true) {
	$username = 'admin'
	$authenticationdirectory = 'c:\temp\'
	$pwdTxt = 'VMware1!'
	$password = get-content C:\temp\adminpassword.txt | convertto-securestring
	$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
}
if ((get-module 'PowervROps') -eq $null) {
import-module 'C:\Users\taguser\Documents\GitHub\PowervROps\powervrops.psm1'
}
$testname = 'getCollectors'
$teststate = 'FAIL'


if ($token -ne "") {
	$collectors = getCollectors -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$collectors = getCollectors -resthost $resthost -credentials $credentials
}




if (($collectors.collector).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}




$testname = 'getAdaptersonCollector'
$teststate = 'FAIL'


if ($token -ne "") {
	$adaptersoncollector = getAdaptersOnCollector -resthost $resthost -token $token -collectorid $collectors.collector.id
}
elseif ($credentials -ne "") {
	$adaptersoncollector = getAdaptersOnCollector -resthost $resthost -credentials $credentials -collectorid $collectors.collector.id
}










if (($adaptersoncollector.adapterInstancesInfoDto).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}





$testname = 'enumerateAdapterInstances'
$teststate = 'FAIL'






if ($token -ne "") {
	$enumerateAdapterInstances = enumerateAdapterInstances -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$enumerateAdapterInstances = enumerateAdapterInstances -resthost $resthost -credentials $credentials
}



#$enumerateAdapterInstances


#if ($adapterinstances -ne $null) {
	#foreach ($adapterinstance in $adapterinstances.adapterInstancesInfoDto) {
	#	if ($adapterinstance.resourceKey.adapterKindKey -eq 'VMWARE') {
			#$currentadapterid = $adapterinstance.id	
	#	}
	#}
#}








if (($enumerateAdapterInstances.adapterInstancesInfoDto.count) -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}




$testname = 'enumerateAdapterInstances-filter-adapterKindKey'
$teststate = 'FAIL'






if ($token -ne "") {
	$enumerateAdapterInstance = enumerateAdapterInstances -resthost $resthost -token $token -adapterKindKey VMWARE
}
elseif ($credentials -ne "") {
	$enumerateAdapterInstance = enumerateAdapterInstances -resthost $resthost -credentials $credentials -adapterKindKey VMWARE
}






foreach ($adapterinstance in $enumerateAdapterInstance.adapterInstancesInfoDto) {
	if ($adapterinstance.resourceKey.name  -eq 'vcsa-01a') {
		$adapterid = $adapterinstance.id
	
	}



}


if (($enumerateAdapterInstance.adapterInstancesInfoDto.count) -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}



$testname = 'createResourceUsingAdapterKind'
$teststate = 'FAIL'




		$body = @{
			'description' = 'New resource for testing PowervROps'
			'resourceKey' = @{
				'name' = 'New resource for testing PowervROps'
				'adapterKindKey' = 'VMWARE'
				'resourceKindKey' = 'CustomDatacenter'
				'resourceIdentifiers' = @( @{
					'identifierType' = @{
						'name' = 'UniqueName'
						'dataType' = 'STRING'
						'isPartOfUniqueness' = $true
						'others' = @()
						'otherAttributes' = @{}
					}
					'value' = 'New resource for testing PowervROps'
					'others' = @()
					'otherAttributes' = @{}
				}
				)
			}
			'dtEnabled' = $true
		'resourceStatusStates' = @()
		'monitoringInterval' = 5
		'badges' = @()
		'others' = @()
		'otherAttributes' = @{}
		} | convertto-json -depth 5



#$response = createResourceUsingAdapterKind -resthost $resthost -credentials $vropscreds -body $bodycontent -restcontenttype 'json' -responseformat 'json' -adapterID $currentadapterid


if ($token -ne "") {
	$createResourceUsingAdapterKind = createResourceUsingAdapterKind -resthost $resthost -token $token -body $body -adapterID $adapterid
}
elseif ($credentials -ne "") {
	$createResourceUsingAdapterKind = createResourceUsingAdapterKind -resthost $resthost -credentials $credentials -body $body -adapterID $adapterid
}






if (($createResourceUsingAdapterKind.identifier).length -eq 36) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}



$testname = 'getResource'
$teststate = 'FAIL'

if ($token -ne "") {
	$getResource = getResource -resthost $resthost -token $token -objectid $createResourceUsingAdapterKind.identifier
}
elseif ($credentials -ne "") {
	$getResource = getResource -resthost $resthost -credentials $credentials -objectid $createResourceUsingAdapterKind.identifier
}



$resourcecreatedsuccessfully = $false

if ($getResource.identifier -eq $createResourceUsingAdapterKind.identifier) {
$teststate = 'SUCCESS'
$resourcecreatedsuccessfully = $true
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}





$testname = 'deleteResource'
$teststate = 'FAIL'


if ($resourcecreatedsuccessfully -eq $true) {


if ($token -ne "") {
	$deleteResource = deleteResource -resthost $resthost -token $token -objectid $createResourceUsingAdapterKind.identifier
	start-sleep 15
	$deletedResource = getResource -resthost $resthost -token $token -objectid $createResourceUsingAdapterKind.identifier
}
elseif ($credentials -ne "") {
	$deleteResource = deleteResource -resthost $resthost -credentials $credentials -objectid $createResourceUsingAdapterKind.identifier
	start-sleep 15
	$deletedResource = getResource -resthost $resthost -credentials $credentials -objectid $createResourceUsingAdapterKind.identifier
}











if ($deletedResource -eq 'The remote server returned an error: (404) Not Found.') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


}
else {

write-host ($testname + ": " + $teststate) -foregroundcolor red

}





