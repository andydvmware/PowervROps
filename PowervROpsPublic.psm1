# PowervROps


function getTimeSinceEpoch {
	$epoch = (get-date -Date "01/01/1970").ToUniversalTime()
	$timenow = (get-date).ToUniversalTime()
	$timesinceepoch = [math]::floor(($timenow - $epoch).TotalMilliseconds)
	return $timesinceepoch
}
function setRestHeaders {
Param	(
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',	
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet($true,$false)][string]$useinternalapi = $false
		)
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
return $restheaders
}
function invokeRestMethod {
	Param (
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)]$credentials,	
		[parameter(Mandatory=$true)]$url,
		[parameter(Mandatory=$true)][ValidateSet('GET','PUT','POST')][string]$method,
		[parameter(Mandatory=$false)]$body,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',	
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet($true,$false)][string]$useinternalapi = $false
	)
	if (($credentials -eq $null) -and ($token -eq $null)) {
		return "No credentials or bearer token supplied"
	}
	elseif ($token -ne $null) {
		if ($useinternalapi -eq $true) {
			$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype -useinternalapi $true
		}
		else {
			$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype -useinternalapi $true
		}
	}
	else {
		if ($useinternalapi -eq $true) {
			$restheaders = setRestHeaders -accept $accept -contenttype $contenttype -useinternalapi $true
		}
		else {
			$restheaders = setRestHeaders -accept $accept -contenttype $contenttype -useinternalapi $true
		}
	}
	write-host $restheaders
	
	if ($body -ne $null) {
		if ($token -ne $null) {
			Try {
				write-host "about to invoke rest method"
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -ErrorAction Stop
				write-host $response
				return $response
			}
			Catch {
				return $_.Exception.Message	
			}	
		}
		else {
			Try {
				write-host "about to invoke rest method"
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -redential $credentials -ErrorAction Stop
				write-host $response
				return $response
			}
			Catch {
				write-host $response
				return $_.Exception.Message	
			}
		}
	}
	else {
		if ($token -ne $null) {
			Try {
				write-host "about to invoke rest method"
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -ErrorAction Stop
				write-host $response
				return $response
			}
			Catch {
				return $_.Exception.Message	
			}	
		}
		else {
			Try {
				write-host "about to invoke rest method"
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders-redential $credentials -ErrorAction Stop
				write-host $response
				return $response
			}
			Catch {
				return $_.Exception.Message	
			}
		}
	}	
}
function invokeWebRequest {
}




#/api/actiondefinitions



#/api/actions



# /api/adapterkinds




# /api/adapters



# /api/alertdefinitions





# /api/alertplugins


	
# /api/alerts	


# /api/auth

function acquireToken {
	Param	(
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$username,
		[parameter(Mandatory=$false)][string]$authSource,
		[parameter(Mandatory=$false)][string]$password
		)
	$restheaders = setRestHeaders -accept $accept -contenttype 'json'
	$resturl = 'https://' + $resthost + '/suite-api/api/auth/token/acquire'
	$body = @{
			'username' = $username
			'authSource' = $authSource
			'password' = $password
			'others' = @()
			'otherAttributes' = @{}
			} | convertto-json
	Try {
		$reponse = Invoke-RestMethod -Method 'POST' -Uri $resturl -Headers $restheaders -body $body -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse.token
}

# /api/collectorgroups


# /api/collectors
# ---------------






# /api/credentialkinds




# /api/credentials

# /api/deployment

# /api/events

# /api/maintenanceschedules

# /api/notifications

# /api/recommendations

# /api/reportdefinitions

# /api/reports

# /api/resources


# /api/supermetrics


function getSuperMetric {
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$id	
		)
	$url = 'https://' + $resthost + '/suite-api/api/supermetrics/' + $id	
	write-host $url
	if ($token -ne $null) {
		$getsupermetricresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getsupermetricresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getsupermetricresponse
}

function getSuperMetrics {
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$name	
		)
	if (($credentials -eq $null) -and ($token -eq $null)) {
		return "No credentials or bearer token supplied"
	}
	else {
		$restheaders = setRestHeaders -accept $accept -token $token
		if (($name -eq $null) -or ($name -eq "")) {
			$resturl = 'https://' + $resthost + '/suite-api/api/supermetrics'
		}
		else {
			$resturl = 'https://' + $resthost + '/suite-api/api/supermetrics?name=' + $name
		}
		Try {
			$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -ErrorAction Stop
		}
		Catch {
			return $_.Exception.Message	
		}
		return $reponse
	}
}





# /api/symptomdefinitions

# /api/symptoms

# /api/tasks

# /api/versions


# /internal/resources
function getCustomGroup {
	<#
	.SYNOPSIS
		TBC
	.DESCRIPTION
		TBC
		NEED TO ADD IN ALL POSSIBLE ACCEPTED PARAMETERS
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		TBC
	.PARAMETER resthost
		TBC
	.PARAMETER responseformat
		TBC
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		)	
	if (($credentials -eq $null) -and ($token -eq $null)) {
		return "No credentials or bearer token supplied"
	}
	else {
		$restheaders = setRestHeaders -accept $accept -token $token -useinternalapi $true
		$resturl = 'https://' + $resthost + '/suite-api/internal/resources/groups'
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse	
	}
	
	
	
}

function createCustomGroup {
	<#
	.SYNOPSIS
		TBC
	.DESCRIPTION
		TBC
		NEED TO ADD IN ALL POSSIBLE ACCEPTED PARAMETERS
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		TBC
	.PARAMETER resthost
		TBC
	.PARAMETER responseformat
		TBC
	#> 
		Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$body
		)
	$resturl = 'https://' + $resthost + '/suite-api/internal/resources/groups'
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$accept)
	$restheaders.Add("X-vRealizeOps-API-use-unsupported","true")
	$contenttype = 'application/' + $restcontenttype

	Try {
		$reponse = Invoke-WebRequest -Method 'POST' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse	

}

function getMembersOfGroup {




	<#
	.SYNOPSIS
		TBC
	.DESCRIPTION
		TBC
		NEED TO ADD IN ALL POSSIBLE ACCEPTED PARAMETERS
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		TBC
	.PARAMETER resthost
		TBC
	.PARAMETER responseformat
		TBC
	#>
Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
		)
	$resturl = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $objectid + '/members'
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$accept)
	$restheaders.Add("X-vRealizeOps-API-use-unsupported","true")
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse






}

function deleteCustomGroup {
	<#
	.SYNOPSIS
		TBC
	.DESCRIPTION
		TBC
		NEED TO ADD IN ALL POSSIBLE ACCEPTED PARAMETERS
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		TBC
	.PARAMETER resthost
		TBC
	.PARAMETER responseformat
		TBC
	#>
Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
		)
	$resturl = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $objectid
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$accept)
	$restheaders.Add("X-vRealizeOps-API-use-unsupported","true")
	Try {
		$reponse = Invoke-RestMethod -Method 'DELETE' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse
}



export-modulemember -function 'update*'
export-modulemember -function 'get*'
export-modulemember -function 'create*'
export-modulemember -function 'add*'
export-modulemember -function 'set*'
export-modulemember -function 'delete*'
export-modulemember -function 'start*'
export-modulemember -function 'acquire*'
export-modulemember -function 'invoke*'




