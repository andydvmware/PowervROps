remove-module PowervROps
import-module 'C:\users\Administrator\Documents\GitHub\PowervROps\powervrops.psd1'
Connect-VropsServer -vropsserver 'vropslab-01a.corp.local' -username admin -authsource local -ignoressl

$response = Get-VropsResourceProperties -id 'f71863f6-2fec-4467-baf8-0029be478f49'

$response | format-table

Disconnect-VropsServer