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
$testname = 'getCustomGroups'
$teststate = 'FAIL'


if ($token -ne "") {
	$getCustomGroups = getCustomGroups -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$getCustomGroups = getCustomGroups -resthost $resthost -credentials $credentials
}


if (($getCustomGroups.values).count -gt 0) {

$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


$testname = 'createCustomGroup'
$teststate = 'FAIL'
$groupcreated = $false









	$body = @{ # Create the json payload
		'resourceKey' = @{
			'name' = 'PowervROps Test Group'
			'adapterKindKey' = 'Container'
			'resourceKindKey' = 'PowervROps Testing'
			'resourceIdentifiers' = @()
			}
		'membershipDefinition' = @{
		'includedResources' = @()
		'excludedResources' = @()
		'rules' = @(@{
		'resourceKindKey' = @{
			'resourceKind' = 'VirtualMachine'
			'adapterKind' = 'VMWARE'
		}
		'attributeRules' = @(@{
			'type' = 'PROPERTY_CONDITION'
			'compareOperator' = 'CONTAINS'
			'stringValue' = 'PowervROPS Testing'
			'key' = 'summary|tag'
			})
		'resourceNameRules' = @()
		'relationshipRules' = @()
		}
	)
		}
	} | convertto-json -depth 5
	

	
if ($token -ne "") {
	$createCustomGroup = createCustomGroup -resthost $resthost -token $token -body $body
}
elseif ($credentials -ne "") {
	$createCustomGroup = createCustomGroup -resthost $resthost -credentials $credentials -body $body
}	
	

	
	
if (($createCustomGroup.identifier).length -eq 36) {

$groupcreated = $true

$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}
	




$testname = 'getCustomGroup'
$teststate = 'FAIL'
	
if ($token -ne "") {
	$getCustomGroup = getCustomGroup -resthost $resthost -token $token -objectid ($createCustomGroup.identifier)
}
elseif ($credentials -ne "") {
	$getCustomGroup = getCustomGroup -resthost $resthost -credentials $credentials -objectid ($createCustomGroup.identifier)
}



if (($createCustomGroup.identifier) -eq ($getCustomGroup.identifier)) {

$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


$testname = 'getMembersOfGroup'
$teststate = 'FAIL'


if ($token -ne "") {
	$getMembersOfGroup = getMembersOfGroup -resthost $resthost -token $token -objectid ($createCustomGroup.identifier)
}
elseif ($credentials -ne "") {
	$getMembersOfGroup = getMembersOfGroup -resthost $resthost -credentials $credentials -objectid ($createCustomGroup.identifier)
}





if (($getMembersOfGroup.resourceList).count -gt 0) {
$teststate = 'SUCCESS'
}
else {

}


$testname = 'deleteCustomGroup'
$teststate = 'FAIL'


if ($groupcreated -eq $true) {


if ($token -ne "") {
	$deleteCustomGroup = deleteCustomGroup -resthost $resthost -token $token -objectid ($createCustomGroup.identifier)
}
elseif ($credentials -ne "") {
	$deleteCustomGroup = deleteCustomGroup -resthost $resthost -credentials $credentials -objectid ($createCustomGroup.identifier)
}


if ($token -ne "") {
	$getCustomGroup = getCustomGroup -resthost $resthost -token $token -objectid ($createCustomGroup.identifier)
}
elseif ($credentials -ne "") {
	$getCustomGroup = getCustomGroup -resthost $resthost -credentials $credentials -objectid ($createCustomGroup.identifier)
}


if ($getCustomGroup -eq 'The remote server returned an error: (404) Not Found.') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

}



