remove-module PowervROps
import-module 'C:\users\Administrator\Documents\GitHub\PowervROps\powervrops.psd1'
Connect-VropsServer -vropsserver 'vropslab-01a.corp.local' -username admin -authsource local -ignoressl

$response = Get-VropsAdapterInstances
$response | format-table









Disconnect-VropsServer