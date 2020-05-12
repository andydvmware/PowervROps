function Connect-VropsServer {
    Param (
        [parameter(Mandatory=$true)][String]$vropsserver,
        [parameter(Mandatory=$true)][String]$username,
        [parameter(Mandatory=$true)][String]$authsource,
        [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][SecureString]$Password,
        [Switch]$ignoressl
    )








    $plainPassword = (New-Object System.Management.Automation.PSCredential("emptyusername", $Password)).GetNetworkCredential().Password





    $token = Get-VropsToken -resthost 'vropslab-01a.corp.local' -username $username -authSource $authsource -password $plainPassword






if ($ignoressl) {

if ( -not ("TrustAllCertsPolicy" -as [type])) {

    Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
}
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
} 




    if ($token) {
        $Global:vROpsConnection = [PSCustomObject] @{
            Server = $vropsserver
            Token = $token
        }
        Write-Output $vROpsConnection
    }
    else {
        Write-Error ("Unable to create connection to vROps Server - " + $vropsserver)
    }


   
}