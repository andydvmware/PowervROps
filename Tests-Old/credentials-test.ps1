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
$testname = 'getCredentialKinds'
$teststate = 'FAIL'


if ($token -ne "") {
	$credentialkinds = getCredentialKinds -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$credentialkinds = getCredentialKinds -resthost $resthost -credentials $credentials
}







if (($credentialkinds.credentialtypes).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}




$testname = 'getCredentials'
$teststate = 'FAIL'



if ($token -ne "") {
	$getcredentials = getCredentials -resthost $resthost -token $token -accept json
}
elseif ($credentials -ne "") {
	$getcredentials = getCredentials -resthost $resthost -credentials $credentials -accept json
}






if (($getcredentials.credentialinstances).count -gt 0) {

$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}


