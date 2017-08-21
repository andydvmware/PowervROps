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
$testname = 'getResources-filter-resourcekind'
$teststate = 'FAIL'



if ($token -ne "") {
	$getResourcesresourcekind = getResources -resthost $resthost -token $token -resourceKind 'ClusterComputeResource'
}
elseif ($credentials -ne "") {
	$getResourcesresourcekind = getResources -resthost $resthost -credentials $credentials -resourceKind 'ClusterComputeResource'
}


if (($getResourcesresourcekind.resourceList).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}









$testname = 'getResources-filter-name'
$teststate = 'FAIL'


if ($token -ne "") {
	$getResourcesname = getResources -resthost $resthost -token $token -name $getResourcesresourcekind.resourceList[0].resourceKey.name
}
elseif ($credentials -ne "") {
	$getResourcesname = getResources -resthost $resthost -credentials $credentials -name $getResourcesresourcekind.resourceList[0].resourceKey.name
}










if (($getResourcesname.resourcelist.resourceKey.name) -eq ($getResourcesresourcekind.resourceList[0].resourceKey.name)) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}








$testname = 'getResources-filter-id'
$teststate = 'FAIL'


if ($token -ne "") {
	$getResourcesid = getResources -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
}
elseif ($credentials -ne "") {
	$getResourcesid = getResources -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
}






if (($getResourcesid.resourceList.identifier) -eq ($getResourcesresourcekind.resourceList[0].identifier)) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


$testname = 'markResourceAsBeingMaintained'
$teststate = 'FAIL'

if ($token -ne "") {
	$putresourceintomaintenancemode = markResourceAsBeingMaintained -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
}
elseif ($credentials -ne "") {
	$putresourceintomaintenancemode = markResourceAsBeingMaintained -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
}

start-sleep 5

if ($token -ne "") {
	$getResourcesafterentermaintenance = getResource -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
}
elseif ($credentials -ne "") {
	$getResourcesafterentermaintenance = getResource -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
}
$inmaintenancemode = $false
foreach ($resourcestate in $getResourcesafterentermaintenance.resourceStatusStates) {
	if ($resourcestate.resourcestate -eq 'MAINTAINED_MANUAL') {
		$inmaintenancemode = $true
		Break
	}
}




if ($inmaintenancemode -eq $true) {
	$teststate = 'SUCCESS'
	write-host ($testname + ": " + $teststate) -foregroundcolor green 
	$testname = 'unmarkResourceAsBeingMaintained'
	$teststate = 'FAIL'
	if ($token -ne "") {
		$takeresourceoutofmaintenancemode = unmarkResourceAsBeingMaintained -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	elseif ($credentials -ne "") {
		$takeresourceoutofmaintenancemode = unmarkResourceAsBeingMaintained -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	start-sleep 5
	if ($token -ne "") {
		$response = getResource -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	elseif ($credentials -ne "") {
		$response = getResource -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	
	#$response
	#write-host $response.resourceStatusStates

	$outofmaintenancemode = $false
	foreach ($resourcestate in $response.resourceStatusStates) {
		if ($resourcestate.resourcestate -eq 'STARTED') {
			$outofmaintenancemode = $true
		}
	}
	
	if ($outofmaintenancemode -eq $true) {
		$teststate = 'SUCCESS'
	write-host ($testname + ": " + $teststate) -foregroundcolor green 
	}
	else {
		write-host ($testname + ": " + $teststate) -foregroundcolor red
	}





}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
$testname = 'unmarkResourceAsBeingMaintained'
$teststate = 'FAIL'
write-host ($testname + ": " + $teststate) -foregroundcolor red
}








# ------------------------------------------------------------
# Tests for stopMonitoringResource and startMonitoringResource
# ------------------------------------------------------------
$testname = 'stopMonitoringResource'
$teststate = 'FAIL'
if ($getResourcesresourcekind.resourceList[0].resourceStatusStates.resourceState -eq 'STARTED') {
	if ($token -ne "") {
		$stopMonitoringResource = stopMonitoringResource -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	elseif ($credentials -ne "") {
		$stopMonitoringResource = stopMonitoringResource -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	if ($token -ne "") {
		$getResourcesidtemp = getResources -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	elseif ($credentials -ne "") {
		$getResourcesidtemp = getResources -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	if ($getResourcesidtemp.resourceList.resourceStatusStates.resourceState -eq 'STOPPED') {
		$teststate = 'SUCCESS'
		write-host ($testname + ": " + $teststate) -foregroundcolor green 
	}
	else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

start-sleep 5

	$testname = 'startMonitoringResource'
	$teststate = 'FAIL'
	if ($getResourcesidtemp.resourceList.resourceStatusStates.resourceState -eq 'STOPPED') {
		if ($token -ne "") {
			$startMonitoringResource = startMonitoringResource -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
		}
		elseif ($credentials -ne "") {
			$startMonitoringResource = startMonitoringResource -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
		}
		if ($token -ne "") {
			$getResourcesidtempstart = getResources -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
		}
		elseif ($credentials -ne "") {
			$getResourcesidtempstart = getResources -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
		}
		if ($getResourcesidtempstart.resourceList.resourceStatusStates.resourceState -eq 'STARTED') {
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
}
else {
write-host ($testname + ": " + $teststate + " - The resource was not in the started state when beginning the stop monitoring state") -foregroundcolor red
$testname = 'startMonitoringResource'
	$teststate = 'FAIL'
	write-host ($testname + ": " + $teststate + " - The resource was not in the started state when beginning the stop monitoring state") -foregroundcolor red
}
# ------------------------------------------------------------
# Tests for getResourceProperties
# ------------------------------------------------------------
$testname = 'getResourceProperties'
$teststate = 'FAIL'
if ($token -ne "") {
	$getResourceProperties = getResourceProperties -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
}
elseif ($credentials -ne "") {
	$getResourceProperties = getResourceProperties -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
}
if (($getResourceProperties.property.count) -gt 1) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}
# ------------------------------------------------------------
# Tests for addProperties
# ------------------------------------------------------------
$testname = 'addProperties'
$teststate = 'FAIL'


$characterlist = @('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
$code = ""
for ($i = 0;$i -lt 10;$i++) {
	$code += $characterlist[(Get-Random -Minimum 1 -Maximum 26)]
}
if (($getResourceProperties.property.count) -gt 1) {
	$body = @{
		'property-content' = @( @{
			'statKey' = 'PowervROpsTest|' + $code
			'timestamps' = @(getTimeSinceEpoch)
			'values' = @(1)
			'others' = @()
			'otherAttributes' = @{}
			}
		)
	} | convertto-json -depth 5
	if ($token -ne "") {
		$addProperties = addProperties -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier -body $body
	}
	elseif ($credentials -ne "") {
		$addProperties = addProperties -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier -body $body
	}
	#$addProperties
	start-sleep -seconds 20
	if ($token -ne "") {
		$getResourcesidtempproperty = getResource -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	elseif ($credentials -ne "") {
		$getResourcesidtempproperty = getResource -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier
	}
	if ($token -ne "") {
		$getResourcePropertiestemp = getResourceProperties -resthost $resthost -token $token -objectid $getResourcesidtempproperty.identifier
	}	
	elseif ($credentials -ne "") {
		$getResourcePropertiestemp = getResourceProperties -resthost $resthost -credentials $credentials -objectid $getResourcesidtempproperty.identifier
	}
	if (($getResourcePropertiestemp.property.count) -gt ($getResourceProperties.property.count)) {
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



if ($token -ne "") {
	$getCustomDataCenters = getResources -resthost $resthost -token $token -resourceKind 'CustomDatacenter'
}
elseif ($credentials -ne "") {
	$getCustomDataCenters = getResources -resthost $resthost -credentials $credentials -resourceKind 'CustomDatacenter'
}







#getRelationship




$testname = 'getRelationship'
$teststate = 'FAIL'


if ($token -ne "") {
	$getRelationship = getRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}
elseif ($credentials -ne "") {
	$getRelationship = getRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}






if (($getRelationship.resourceList).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}







#SETRELATIONSHIP






$testname = 'setRelationship'
$teststate = 'FAIL'

$body = @{'uuids' = @($getCustomDataCenters.resourceList[0].identifier,$getResourcesresourcekind.resourceList[0].identifier)} | convertto-json # Create the JSON object

if ($token -ne "") {
	$setRelationship = setRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children -body $body
}
elseif ($credentials -ne "") {
	$setRelationship = setRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children -body $body
}




start-sleep -seconds 20


if ($token -ne "") {
	$getRelationshipafterset = getRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}
elseif ($credentials -ne "") {
	$getRelationshipafterset = getRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}




if ((($getRelationshipafterset.resourceList).count -eq 1) -and ($getRelationshipafterset.resourceList.identifier -eq $getResourcesresourcekind.resourceList[0].identifier)) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

#ADDRELATIONSHIP


$testname = 'addRelationship'
$teststate = 'FAIL'

$body = @{'uuids' = @($getCustomDataCenters.resourceList[0].identifier,$getResourcesresourcekind.resourceList[1].identifier)} | convertto-json # Create the JSON object

if ($token -ne "") {
	$addRelationship = addRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children -body $body
}
elseif ($credentials -ne "") {
	$addRelationship = addRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children -body $body
}

start-sleep -seconds 20

if ($token -ne "") {
	$getRelationshipafteradd = getRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}
elseif ($credentials -ne "") {
	$getRelationshipafteradd = getRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}



if ($getRelationshipafteradd.resourceList.count -eq 2) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

$testname = 'deleteRelationship'
$teststate = 'FAIL'

if ($token -ne "") {
	$addRelationship = deleteRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relatedid $getResourcesresourcekind.resourceList[1].identifier -relationship children
}
elseif ($credentials -ne "") {
	$addRelationship = deleteRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relatedid $getResourcesresourcekind.resourceList[1].identifier -relationship children
}


start-sleep -seconds 20

if ($token -ne "") {
	$getRelationshipafterdelete = getRelationship -resthost $resthost -token $token -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}
elseif ($credentials -ne "") {
	$getRelationshipafterdelete = getRelationship -resthost $resthost -credentials $credentials -objectid $getCustomDataCenters.resourceList[0].identifier -relationship children
}



$relationshipstillexists = $false
foreach ($relationship in $getRelationshipafterdelete.resourceList) {
	if ($relationship.identifier -eq $getResourcesresourcekind.resourceList[1].identifier) {
		$relationshipstillexists = $true
		Break
	}
	


}


if ($relationshipstillexists -eq $false) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

