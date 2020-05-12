param(
	[parameter(Mandatory=$true)][ValidateSet('token','credentials')][string]$authtype,
	[parameter(Mandatory=$true)][string]$resthost
	)
clear	
$alltests = get-childitem 'c:\users\administrator\documents\github\powervrops\tests'	
if ($authtype -eq 'token') {

if ((get-module 'PowervROps') -eq $null) {
import-module 'C:\Users\administrator\Documents\GitHub\PowervROps\powervrops.psm1'
}
$teststate = 'FAIL'
$testname = 'getAllActions'
$username = 'admin'
$password = '5eRen!ty'
$authSource = 'local'
$token = acquireToken -resthost $resthost -username $username -password $password -authSource $authSource
if ($token.length -eq 74) {
$teststate = 'SUCCESS'
}
else {

}
if ($teststate -eq 'SUCCESS') {
Foreach ($test in $alltests) {
$command = (($test.fullname) + ' -token ' + $token + ' -resthost ' + $resthost)
invoke-expression $command
}

}




}
elseif ($authtype -eq 'credentials') {













Foreach ($test in $alltests) {
$command = (($test.fullname) + ' -credentials ' + $true + ' -resthost ' + $resthost)
invoke-expression $command
}





}	




