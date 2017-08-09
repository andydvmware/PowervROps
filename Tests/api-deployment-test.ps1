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
$testname = 'getLicenceKeysForProduct'
$teststate = 'FAIL'


if ($token -ne "") {
	$licencekeys = getLicenceKeysForProduct -resthost $resthost -token $token
}
elseif ($credentials -ne "") {
	$licencekeys = getLicenceKeysForProduct -resthost $resthost -credentials $credentials
}






if (($licencekeys.solutionLicenses).count -gt 0) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}