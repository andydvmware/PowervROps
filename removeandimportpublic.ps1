remove-module powervrops -erroraction ignore
remove-module PowervROpsPublic -erroraction ignore
remove-module credentials -erroraction ignore
import-module 'C:\Users\taguser\Documents\GitHub\PowervROps\PowervROpsPublic.psm1'
import-module 'C:\Users\taguser\Documents\GitHub\PowervROps\credentials.psm1'