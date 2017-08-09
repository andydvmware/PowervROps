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






if ($token -ne "") {
	$getResourcesresourcekind = getResources -resthost $resthost -token $token -resourceKind 'ClusterComputeResource'
}
elseif ($credentials -ne "") {
	$getResourcesresourcekind = getResources -resthost $resthost -credentials $credentials -resourceKind 'ClusterComputeResource'
}


$testname = 'addStats'
$teststate = 'FAIL'


$statvalue = Get-Random -minimum 1 -maximum 10000


		$body = @{ # Create the json payload to add the statistics to the virtual machine
			'stat-content' = @( @{
				'statKey' = 'PowervROPsTesting|TestStat'
				'timestamps' = @(getTimeSinceEpoch)
				'data' = @($statvalue)
				'others' = @()
				'otherAttributes' = @{}
				}
			)
		} | convertto-json -depth 5



if ($token -ne "") {
	$addStats = addStats -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier -body $body
}
elseif ($credentials -ne "") {
	$addStats = addStats -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier -body $body
}

start-sleep -seconds 30

#$getResourcesresourcekind.resourceList[0].identifier

if ($token -ne "") {
	$getLatestStatsofResources = getLatestStatsofResources -resthost $resthost -token $token -objectid $getResourcesresourcekind.resourceList[0].identifier -statkey 'PowervROPsTesting|TestStat'
}
elseif ($credentials -ne "") {
	$getLatestStatsofResources = getLatestStatsofResources -resthost $resthost -credentials $credentials -objectid $getResourcesresourcekind.resourceList[0].identifier -statkey 'PowervROPsTesting|TestStat'
}



if ($getLatestStatsofResources.values.'stat-list'.stat.data -eq $statvalue) {
$teststate = 'SUCCESS'
$addedstat = $true
write-host ($testname + ": " + $teststate) -foregroundcolor green 
}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


$testname = 'getLatestStatsofResources'
$teststate = 'FAIL'

if ($addedstat -eq $true) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}





