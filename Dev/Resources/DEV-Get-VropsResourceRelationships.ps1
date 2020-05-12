remove-module PowervROps
import-module 'C:\users\Administrator\Documents\GitHub\PowervROps\powervrops.psd1'
Connect-VropsServer -vropsserver 'vropslab-01a.corp.local' -username admin -authsource local -ignoressl

$response = Get-VropsRelationships -id 'ed08fe0f-a31b-46eb-a54a-70fdd5ca169d'

$response | format-table

Disconnect-VropsServer