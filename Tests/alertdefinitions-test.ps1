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
$testname = 'getAlertDefinitions'
$teststate = 'FAIL'







if ($token -ne "") {
	$alertdefinitions = getAlertDefinitions -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$alertdefinitions = getAlertDefinitions -resthost $resthost -credentials $credentials
}







if ($alertdefinitions.pageInfo.totalCount -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}









$testname = 'getAlertDefinitionById'
$teststate = 'FAIL'



if ($token -ne "") {
	$alertdefinitionbyid = getAlertDefinitionById -resthost $resthost -token $token -alertdefinitionid $alertdefinitions.alertdefinitions[0].id
}
elseif ($credentials -ne "") {
	$alertdefinitionbyid = getAlertDefinitionById -resthost $resthost -credentials $credentials -alertdefinitionid $alertdefinitions.alertdefinitions[0].id
}




if ($alertdefinitionbyid -ne 'The remote server returned an error: (404) Not Found.') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}