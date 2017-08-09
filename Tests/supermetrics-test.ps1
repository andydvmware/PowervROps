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
$testname = 'getSuperMetrics'
$teststate = 'FAIL'




if ($token -ne "") {
	$getSuperMetrics = getSuperMetrics -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$getSuperMetrics = getSuperMetrics -resthost $resthost -credentials $credentials
}







if (($getSuperMetrics.superMetrics).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}








$testname = 'getSuperMetrics-filter-name'
$teststate = 'FAIL'



if ($token -ne "") {
	$getSuperMetricsbyName = getSuperMetrics -resthost $resthost -token $token -name $getSuperMetrics.superMetrics[0].Name
}
elseif ($credentials -ne "") {
	$getSuperMetricsbyName = getSuperMetrics -resthost $resthost -credentials $credentials -name $getSuperMetrics.superMetrics[0].Name
}






if (($getSuperMetricsbyName.superMetrics).count  -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}





$testname = 'getSuperMetric'
$teststate = 'FAIL'


if ($token -ne "") {
	$getSuperMetric = getSuperMetric -resthost $resthost -token $token -supermetricid $getSuperMetrics.superMetrics[0].id
}
elseif ($credentials -ne "") {
	$getSuperMetric = getSuperMetric -resthost $resthost -credentials $credentials -supermetricid $getSuperMetrics.superMetrics[0].id
}







if ($getSuperMetric.id -eq $getSuperMetrics.superMetrics[0].id) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

