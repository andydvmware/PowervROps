function set-RestHeaders {
	<#
		.SYNOPSIS
			Function to set the rest headers to allow rest methods to be executed
		.DESCRIPTION
			To enable standardisation of execution, all of the functions that are performing
			tasks on the vROps instance use standard means of performing that execution.
			These functions (invokeRestMethod & invokeWebRequest) need certain headers setting
			based on the format that requests and responses are executed but also because there
			certain calls which require a special header value to be set
		.EXAMPLE
			setRestHeaders -accept json -token $token -contenttype json
		.EXAMPLE
			setRestHeaders -accept json -contenttype json -useinternalapi $true
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER useinternalapi
			Used only by functions that are accessing vROps internal api. This sets the value of the header
			parameter 'X-vRealizeOps-API-use-unsupported' to 'true'.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',	
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet($true,$false)][string]$useinternalapi = $false
		
		)
	Process {
		$restheaders = @{}
		$restheaders.Add('Accept','application/'+$accept)
		if ($contenttype -ne $null) {
			$restheaders.Add('Content-Type','application/'+$contenttype)
		}
		if ($token -ne $null) {
			$restheaders.Add('Authorization',('vRealizeOpsToken ' + $token))
		}
		if ($useinternalapi -eq $true) {
			$restheaders.Add("X-vRealizeOps-API-use-unsupported","true")
		}
		foreach ($header in $restheaders) {
			write-verbose ("Header: " + $header)
		}
		return $restheaders
	}
}