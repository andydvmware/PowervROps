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

$reportdefinitionid = '547eba86-0598-4c16-9bca-b1ed330f93ac'

if ($token -ne "") {
	$createReport = createReport -token $token -resthost $resthost -reportdefinitionid $reportdefinitionid -objectid 656052ca-f4ee-462a-967c-529057e269f0
}
elseif ($credentials -ne "") {
	$createReport = createReport -credentials $credentials -resthost $resthost -reportdefinitionid $reportdefinitionid -objectid 656052ca-f4ee-462a-967c-529057e269f0
}






if ($createReport.status -eq 'QUEUED') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}







$testname = 'getReport'
$teststate = 'FAIL'





	$t = 0
	Do {
	
	if ($token -ne "") {

	$getReport = getReport -token $token -resthost $resthost -reportid $createReport.id
}
elseif ($credentials -ne "") {
	$getReport = getReport -credentials $credentials -resthost $resthost -reportid $createReport.id
}
	
	
	
	start-sleep 1
	$t++
	
	}
	Until (($t -eq 120) -or ($getReport.status -eq 'COMPLETED'))
	
	
	
	
	
	
	if ($getReport.status -eq 'COMPLETED') {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}




$testname = 'downloadReport'
$teststate = 'FAIL'

$testfile = 'c:\users\taguser\downloads\testreport.csv'

if ((get-item $testfile -erroraction silentlycontinue) -ne $null) {


remove-item $testfile -confirm:$false
}

if ($token -ne "") {

	$downloadreport = downloadReport -token $token -resthost $resthost -reportid $getreport.id -format 'csv' -outputfile $testfile
}
elseif ($credentials -ne "") {
	$downloadreport = downloadReport -credentials $credentials -resthost $resthost -reportid $getreport.id -format 'csv' -outputfile $testfile
}

start-sleep 5

if ((get-item $testfile -erroraction silentlycontinue) -ne $null) {
$teststate = 'SUCCESS'
write-host ($testname + ": " + $teststate) -foregroundcolor green 

}
else {
write-host ($testname + ": " + $teststate) -foregroundcolor red
}



