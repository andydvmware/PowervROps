function invokeRestMethod {
	<#
		.SYNOPSIS
			Function to invoke the rest method, from other functions within the module
		.DESCRIPTION
			To standardise the module, all functions use the invokeRestMethod for the actual
			rest call.
		.EXAMPLE
			invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		.EXAMPLE
			invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		.EXAMPLE
			invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -contenttype $contenttype -body $body
		.EXAMPLE
			invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -contenttype $contenttype -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER url
			The url against which the request will be performed. This will be passed to the cmdlet by the originating
			request and does not need any user modification.
		.PARAMETER method
			The request type, valid values are (currently) 'GET', 'PUT', 'POST', 'DELETE'
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER useinternalapi
			Used only by functions that are accessing vROps internal api. This sets the value of the header
			parameter 'X-vRealizeOps-API-use-unsupported' to 'true'.
		.PARAMETER timeoutsec
			Number of seconds to wait before timing out the request
		.NOTES
			Added in version 0.3
	#>
	Param (
	#	[parameter(Mandatory=$false)]$credentials,	
		[parameter(Mandatory=$true)]$token,
		[parameter(Mandatory=$true)]$url,
		[parameter(Mandatory=$false)][ValidateSet('GET','PUT','POST','DELETE')][string]$method,
		[parameter(Mandatory=$false)]$body,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',	
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet($true,$false)][string]$useinternalapi = $false,
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][int]$timeoutsec = 30
	)
	Process {
	#	if (!$token) {
	#		Write-Host ("ERROR: ") -ForegroundColor red -nonewline; Write-Host 'No credentials or bearer token supplied' -ForegroundColor White;
	#		return
	#	}
	#	else  {
			if ($useinternalapi -eq $true) {
				$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype -useinternalapi $true
			}
			else {
				$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype
			}
	#	}
#		else {
#			if ($useinternalapi -eq $true) {
#				$restheaders = setRestHeaders -accept $accept -contenttype $contenttype -useinternalapi $true
#			}
#			else {
#				$restheaders = setRestHeaders -accept $accept -contenttype $contenttype
#			}
#		}
	#	if ($body -ne $null) {
		if ($body) {

			write-host "this is a body...."

		#	if ($token -ne $null) {
		#	if ($token) {
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					Write-Host ("StatusCode:" + $_.Exception.Response.StatusCode.value__)
					Write-Host ("StatusDescription:" + $_.Exception.Response.StatusDescription)
				#	$e = $_.Exception
				#	$msg = $e.Message
				#	while ($e.InnerException) {
				#		$e = $e.InnerException
				#		$msg += "`n" + $e.Message
					}
				#	write-host $msg
				#	return $_.Exception.Message
				}	
		#	}
	#		else {
	#			Try {
	#				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
	#				return $response
	#			}
	#			Catch {
	#				Write-Host ("StatusCode:" + $_.Exception.Response.StatusCode.value__)
	#				Write-Host ("StatusDescription:" + $_.Exception.Response.StatusDescription)
	#				$e = $_.Exception
	#				$msg = $e.Message
	#				while ($e.InnerException) {
	#					$e = $e.InnerException
	#					$msg += "`n" + $e.Message
	#				}
	#			write-host $msg	
	#			return $_.Exception.Message	
	#			}
	#		}
		}
		else {
			#	if ($token -ne $null) {
		#	if ($token) {

				
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					Write-Host ("StatusCode:" + $_.Exception.Response.StatusCode.value__)
					Write-Host ("StatusDescription:" + $_.Exception.Response.StatusDescription)
			#		$e = $_.Exception
			#		$msg = $e.Message
			#		while ($e.InnerException) {
			#			$e = $e.InnerException
			#			$msg += "`n" + $e.Message
					}
			#	$msg
			#	return $_.Exception.Message
				}	
		#	}
		#	else {
		#		Try {
		#			$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
		#			return $response
		#		}
		#		Catch {
#
#					Write-Host ("StatusCode:" + $_.Exception.Response.StatusCode.value__)
 #   				Write-Host ("StatusDescription:" + $_.Exception.Response.StatusDescription)
#
#					$e = $_.Exception
#					$msg = $e.Message
#					while ($e.InnerException) {
#						$e = $e.InnerException
#						$msg += "`n" + $e.Message
#					}
#					write-host $msg
#					return $_.Exception.Message
#				}
#			}
	#	}
	}
}