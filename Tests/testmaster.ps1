remove-module PowervROps
import-module 'C:\users\Administrator\Documents\GitHub\PowervROps\powervrops.psd1'
Connect-VropsServer -vropsserver 'vropslab-01a.corp.local' -username admin -authsource local -ignoressl




$script = $PSScriptRoot+"/resources/get-vropsresourcestest.ps1"
& $script