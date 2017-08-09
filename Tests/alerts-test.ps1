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
$testname = 'getAlerts'
$teststate = 'FAIL'







if ($token -ne "") {
	$alerts = getAlerts -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$alerts = getAlerts -resthost $resthost -credentials $credentials
}







if ($alerts.pageInfo.totalCount -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}










$testname = 'getAlert'
$teststate = 'FAIL'







if ($token -ne "") {
	$alert = getAlert -resthost $resthost -token $token -alertid $alerts.alerts[0].alertid
}
elseif ($credentials -ne "") {
	$alert = getAlert -resthost $resthost -credentials $credentials -alertid $alerts.alerts[0].alertid
}






if ($alert -ne 'The remote server returned an error: (400) Bad Request.') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}