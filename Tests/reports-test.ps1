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
$testname = 'createReport'
$teststate = 'FAIL'



if ($token -ne "") {
	$createReport = createReport -token $token -resthost vrops-01a.cloudkindergarten.local -reportid 4eaae8d7-c57a-4e0a-a2bc-e103d63d1aaf -objectid f44eae09-b99a-4e85-9b8f-457739789ba1
}
elseif ($credentials -ne "") {
	$createReport = createReport -credentials $credentials -resthost vrops-01a.cloudkindergarten.local -reportid 4eaae8d7-c57a-4e0a-a2bc-e103d63d1aaf -objectid f44eae09-b99a-4e85-9b8f-457739789ba1
}







if ($createReport.status -eq 'QUEUED') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}

