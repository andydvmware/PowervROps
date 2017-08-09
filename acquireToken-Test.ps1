if (get-module 'PowervROps -eq $null) {
import-module 'C:\Users\taguser\Documents\GitHub\PowervROps\powervrops.psm1'
}
$resthost = 'vrops-01a.cloudkindergarten.local'
$username = 'admin'
$password = 'VMware1!'
$authSource = 'local'
$token = acquireToken -resthost $resthost -username $username -password $password -authSource $authSource
$token