# |----------------------------------------------------------------------------------------------------------------------------|
# | Module Name: PowervROps.psm1                                                           									   |
# | Author: Andy Davies (andyd@vmware.com)                                                                        			   |
# | Date: 26th February 2019                                                                                  				   |
# | Description: PowerShell module that enables the use of the vROPs API via PowerShell cmdlets								   |
# |----------------------------------------------------------------------------------------------------------------------------|

function getTimeSinceEpoch {
	<#
		.SYNOPSIS
			Function to obtain the current time in milliseconds since the Unix epoch
		.DESCRIPTION
			Function used by other functions in the module to convert either the current date/time
			or a previous date/time into milliseconds since the Unix epoch which is what vROps uses
			for all of its time calculations
		.EXAMPLE
			getTimeSinceEpoch
		.EXAMPLE
			getTimeSinceEpoch -date (get-date -day 12 -month 06 -year 2016 -hour 14 -minute 50 -second 30)
		.EXAMPLE
			getTimeSinceEpoch -date $somepreviousvariable
		.PARAMETER date
			PowerShell date object
		.NOTES
			Added in version 0.1
			Updated to include date argument in 0.3.5
	#>
	Param	(
		[parameter(Mandatory=$false)]$date,
		[parameter(Mandatory=$false)]$hourstoadd
		)
	process {
		$epoch = (get-date -Date "01/01/1970").ToUniversalTime()
		if ($date -eq $null) {
			$referencetime = ((get-date).AddHours($hourstoadd)).ToUniversalTime()
		}
		else {
			$referencetime = $date.ToUniversalTime()
		}
		$timesinceepoch = [math]::floor(($referencetime - $epoch).TotalMilliseconds)
		return $timesinceepoch	
	}
}
function setRestHeaders {
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
		return $restheaders
	}
}
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
		[parameter(Mandatory=$false)]$credentials,	
		[parameter(Mandatory=$false)]$token,
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
		if (($credentials -eq $null) -and ($token -eq $null)) {
			Write-Host ("ERROR: ") -ForegroundColor red -nonewline; Write-Host 'No credentials or bearer token supplied' -ForegroundColor White;
			return
		}
		elseif ($token -ne $null) {
			if ($useinternalapi -eq $true) {
				$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype -useinternalapi $true
			}
			else {
				$restheaders = setRestHeaders -accept $accept -token $token -contenttype $contenttype
			}
		}
		else {
			if ($useinternalapi -eq $true) {
				$restheaders = setRestHeaders -accept $accept -contenttype $contenttype -useinternalapi $true
			}
			else {
				$restheaders = setRestHeaders -accept $accept -contenttype $contenttype
			}
		}
		if ($body -ne $null) {
			if ($token -ne $null) {
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					$e = $_.Exception
					$msg = $e.Message
					while ($e.InnerException) {
						$e = $e.InnerException
						$msg += "`n" + $e.Message
					}
					write-host $msg
					return $_.Exception.Message
				}	
			}
			else {
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					$e = $_.Exception
					$msg = $e.Message
					while ($e.InnerException) {
						$e = $e.InnerException
						$msg += "`n" + $e.Message
					}
				write-host $msg	
				return $_.Exception.Message	
				}
			}
		}
		else {
			if ($token -ne $null) {
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					$e = $_.Exception
					$msg = $e.Message
					while ($e.InnerException) {
						$e = $e.InnerException
						$msg += "`n" + $e.Message
					}
				$msg
				return $_.Exception.Message
				}	
			}
			else {
				Try {
					$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
					return $response
				}
				Catch {
					$e = $_.Exception
					$msg = $e.Message
					while ($e.InnerException) {
						$e = $e.InnerException
						$msg += "`n" + $e.Message
					}
					write-host $msg
					return $_.Exception.Message
				}
			}
		}
	}
}

function processReponse {
	Param (
		[parameter(Mandatory=$true)][String]$jsonprimarykey,
		[parameter(Mandatory=$true)][String]$xmlprimarykey,
		[parameter(Mandatory=$true)][String]$xmlsecondarykey,
		[parameter(Mandatory=$true)]$rawresponse,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept
	)
	if ($accept -eq 'json') {
		if ($rawresponse.$jsonprimarykey) {
			return $rawresponse.$jsonprimarykey
		}
		else {
			throw $getLicenceKeysForProductresponse
		}
	}
	else {
		if ($rawresponse.$xmlprimarykey) {
		
		}
	}
}

function connect-vropsserver { # TBC
	Param	(
		[parameter(Mandatory=$true)][String]$vropsserver,
		[parameter(Mandatory=$false)][PSCredential]$credential,
		[parameter(Mandatory=$false)][String]$username,
		[parameter(Mandatory=$false)][String]$password,
		[parameter(Mandatory=$false)][String]$authsource
	)


	
	#write-host $username
	#write-host $password
	#w#rite-host $vropsserver
	#write-host $authsource
	
	
	
	if ($credential) {
	
		write-host "we have some credentials"
		$credential.username
	
	
	}
	else {
	if (!$username) {
		$username = read-host "Username: "
	
	}
	if (!password) {
	
		$password = read-host "Password: "
	
	
	
	}
	if (!authsource) {
		
	
	
	
	
	}
	}
	
	
	
	  # Build cred object for default auth if user specified username/pass
  #$connection_credentials = ""
  #if($PsBoundParameters.ContainsKey("Username")) 
  #{
    # Is the -Password omitted? Prompt securely
   # if(!$PsBoundParameters.ContainsKey("Password")) {
    #  $connection_credentials = Get-Credential -UserName $Username -Message "vRealize Network Insight Platform Authentication"
   # }
    # If the password has been given in cleartext, 
   # else {
   #   $connection_credentials = New-Object System.Management.Automation.PSCredential($Username, $(ConvertTo-SecureString $Password -AsPlainText -Force))
  #  }
  #}
  # If a credential object was given as a parameter, use that
  #elseif($PSBoundParameters.ContainsKey("Credential")) 
  #{
   # $connection_credentials = $Credential
  #}
  # If no -Username or -Credential was given, prompt for credentials
 # elseif(!$PSBoundParameters.ContainsKey("Credential")) {
   # $connection_credentials = Get-Credential -Message "vRealize Network Insight Platform Authentication"
  #}
  
  
 # if (
  
	
	
	
#if (!$authsource) {

#write-host "No authsource"

#}	

#if ($globalvropsservers.count -gt 0) {

#write-host "something in the global variable"

#}
#else {

#$globalvropsservers = New-Object System.Collections.ArrayList

#write-host "Nothing in the global variable"


#}



}
#/api/actiondefinitions -------------------------------------------------------------------------------------------------------

function getAllActions {
	<#
		.SYNOPSIS
			Look up all Action Definitions in the system.
		.DESCRIPTION
			Executing will query for all available Actions defined in the system.
			This includes the data needed to populate an Action in the system.
		.EXAMPLE
			getAllActions -token $validtoken -resthost 'fqdn of vROps instance' -accept json
		.EXAMPLE
			getAllActions -credentials $validpscredentials -resthost 'fqdn of vROps instance' -accept xml
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/actiondefinitions'
		if ($token -ne $null) {
			$getAllActionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getAllActionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getAllActionsresponse
	}
}

# /api/actions ----------------------------------------------------------------------------------------------------------------

# /api/adapterkinds -----------------------------------------------------------------------------------------------------------

function getResourcesWithAdapterKinds {
	<#
		.SYNOPSIS
			Returns all the resources of a particular adapter type
		.DESCRIPTION
			Returns all the resources of a particular adapter type
		.EXAMPLE
			getResourcesWithAdapterKinds -resthost $resthost -token $token -adapterKindKey VMWARE
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER adapterKindKey
			The name of the adapter type to filter
		.NOTES
			Added in version 0.4.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$adapterKindKey
		)
	Process {
		$url = ('https://' + $resthost + '/suite-api/api/adapterkinds/' + $adapterKindKey + '/resources')
		if ($token -ne $null) {
			$getResourcesWithAdapterKindsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourcesWithAdapterKindsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getResourcesWithAdapterKindsresponse
	}
}

# /api/adapters ---------------------------------------------------------------------------------------------------------------

function enumerateAdapterInstances {
	<#
		.SYNOPSIS
			Returns all the adapter instance resources in the system.
		.DESCRIPTION
			Returns all the adapter instance resources in the system.
		.EXAMPLE
			enumerateAdapterInstances -resthost $resthost -token $token
		.EXAMPLE
			enumerateAdapterInstances -resthost $resthost -token $token -adapterKindKey VMWARE
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER adapterKindKey
			The name of the adapter type to filter
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)]$adapterKindKey
		)
	Process {
		if ($adapterKindKey -ne $null) {
			$url = 'https://' + $resthost + '/suite-api/api/adapters?adapterKindKey=' + $adapterKindKey
		}
		else {
			$url = 'https://' + $resthost + '/suite-api/api/adapters'
		}
		if ($token -ne $null) {
			$enumerateAdapterInstancesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$enumerateAdapterInstancesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $enumerateAdapterInstancesresponse
	}
}

function getResourcesOfAdapterInstance {
	<#
		.SYNOPSIS
			Returns all of the resources of a given adapter instance
		.DESCRIPTION
			Returns all of the resources of a given adapter instance
		.EXAMPLE
			getREsourcesOfAdapterInstance -resthost $resthost -token $token -adapterKindKey vRealizeOpsMgrAPI
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER adapterKindKey
			The name of the adapter type to filter
		.NOTES
			Added in version 0.4.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][Int]$pagesize = 1000,
		[parameter(Mandatory=$false)][Int]$pagetoview = 0,
		[parameter(Mandatory=$true)]$adapterID
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/adapters/' + $adapterID + '/resources' 
		$url += '?pageSize=' + $pagesize + '&page=' + $pagetoview
		if ($token -ne $null) {
			$getResourcesOfAdapterInstanceresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourcesOfAdapterInstanceresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getResourcesOfAdapterInstanceresponse
	}
}

# /api/alertdefinitions -------------------------------------------------------------------------------------------------------
	
function getAlertDefinitionById {
	<#
		.SYNOPSIS
			Gets Alert Definition using the identifier specified.
		.DESCRIPTION
			Gets Alert Definition using the identifier specified.
		.EXAMPLE
			getAlertDefinitionById -resthost $resthost -token $token -alertdefinitionid $alertdefinitionid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER alertdefinitionid
			The vROps ID of the alert definition
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$true)][String]$alertdefinitionid
		)
	$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/' + $alertdefinitionid		
	if ($token -ne $null) {
		$getAlertDefinitionByIdresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAlertDefinitionByIdresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
	}	
	return $getAlertDefinitionByIdresponse
}	
function getAlertDefinitions {
	<#
		.SYNOPSIS
			Returns a collection of Alert Definitions matching the search criteria specified.
		.DESCRIPTION
			Returns a collection of Alert Definitions matching the search criteria specified.
		.EXAMPLE
			getAlertDefinitions -resthost $resthost -token $token
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER alertdefinitionid
			The identifier(s) of the Alert Definitions to search for.
			Do not specify adapterKind or resourceKind if searching by the identifier
		.PARAMETER adapterkind
			Adapter Kind key of the Alert Definitions to search for
		.PARAMETER resourcekind
			Resource Kind key of the Alert Definitions to search for
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][String]$alertdefinitionid,
		[parameter(Mandatory=$false)][String]$adapterkind,
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][String]$resourcekind
		)
	Process {
		if (($alertdefinitionid -ne "") -and (($adapterkind -ne "") -or ($resourcekind -ne ""))) {
			write-host "alertdefinition" $alertdefintion
			write-host "WARNING - When specifying an alert definition ID, an adapterkind or resourcekind are not necessary"
			return
		}
		else {
			if ($alertdefinitionid -ne "") {
				$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/?id=' + $alertdefinitionid
			}
			elseif ($adapterkind -ne "") {
				if ($resourcekind -ne "") {
					$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/?adapterKind=' + $adapterkind + '&resourceKind=' + $resourcekind 
				}
				else {
					$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/?adapterKind=' + $adapterkind
				}
			}
			elseif ($resourcekind -ne "") {
				$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/?resourceKind=' + $resourcekind 
			}
			else {
				$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions'
			}
			if ($token -ne $null) {
				$getAlertDefinitionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
			}
			else {
				$getAlertDefinitionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
			}	
			return $getAlertDefinitionsresponse
		}
	}
}

# /api/alertplugins -----------------------------------------------------------------------------------------------------------
	
# /api/alerts -----------------------------------------------------------------------------------------------------------------

function getAlert {
	<#
		.SYNOPSIS
			Look up an Alert by its identifier.
		.DESCRIPTION
			Look up an Alert by its identifier.
		.EXAMPLE
			getAlerts -token $validtoken -resthost 'fqdn of vROps instance' -accept json -alertid 3014d718-18e4-42d5-b264-66f6b4ff4d8e
		.EXAMPLE
			getAlerts -credentials $validpscredentials -resthost 'fqdn of vROps instance' -accept xml -alertid 3014d718-18e4-42d5-b264-66f6b4ff4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER alertid
			The vROps ID of the alert to query.
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][String]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$true)][String]$alertid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/alerts/' + $alertid
		if ($token -ne $null) {
			$getAlertresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getAlertresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getAlertresponse
	}
}
function getAlerts {
	<#
		.SYNOPSIS
			Look up Alerts by their identifiers or using the identifiers of the Resources they are associated with.
		.DESCRIPTION
			Look up Alerts by their identifiers or using the identifiers of the Resources they are associated with.
		.EXAMPLE
			getAlerts -token $validtoken -resthost 'fqdn of vROps instance' -accept json
		.EXAMPLE
			getAlerts -credentials $validpscredentials -resthost 'fqdn of vROps instance' -accept xml
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/alerts'
		if ($token -ne $null) {
			$getAlertsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getAlertsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getAlertsresponse
	}
}

# /api/auth -------------------------------------------------------------------------------------------------------------------

function acquireToken {
	<#
		.SYNOPSIS
			Acquire a token to perform REST API calls.
		.DESCRIPTION
			Performing this request would yield a response object that includes token and its validity.
		.EXAMPLE
			acquireToken -resthost 'fqdn of vROps instance' -accept json -username 'admin' -password 'somepassword' -authSource 'local'
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER username
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER authSource
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER password
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][string]$username,
		[parameter(Mandatory=$false)][string]$authSource,
		[parameter(Mandatory=$false)][string]$password
	)
	Process {
		$restheaders = @{}
		$restheaders.Add('Accept','application/'+$accept)
		$restheaders.Add('Content-Type','application/'+$contenttype)
		$url = 'https://' + $resthost + '/suite-api/api/auth/token/acquire'
		if ($contenttype -eq 'json') {
			$body = @{
				'username' = $username
				'authSource' = $authSource
				'password' = $password
				'others' = @()
				'otherAttributes' = @{}
				} | convertto-json
		}
		Try {
			$response = Invoke-RestMethod -Method 'POST' -Uri $url -Headers $restheaders -body $body -ErrorAction Stop
			return $response.token
		}
		Catch {
			Write-Host ("ERROR: ") -ForegroundColor red -nonewline; Write-Host 'Token not generated' -ForegroundColor White;
			Write-Host $response
			Write-Host $Error[0].Exception

		}		
	}
}

# /api/collectorgroups --------------------------------------------------------------------------------------------------------

# /api/collectors -------------------------------------------------------------------------------------------------------------

function getAdaptersOnCollector {
	<#
		.SYNOPSIS
			Gets all the Adapters registered (bound) to a specific Collector.
		.DESCRIPTION
			Gets all the Adapters registered (bound) to a specific Collector.
		.EXAMPLE
			getAdaptersOnCollector -resthost $resthost -token $token -collectorid $collectorsid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER collectorid
			ID of the collector to query
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$collectorid
	)
	$url = 'https://' + $resthost + '/suite-api/api/collectors/' + $collectorid + '/adapters'
	if ($token -ne $null) {
		$getAdaptersOnCollectorresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAdaptersOnCollectorresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
	}	
	return $getAdaptersOnCollectorresponse
}
function getCollectors {
	<#
		.SYNOPSIS
			Gets all the Collectors registered with the vRealize Operations Manager system.
		.DESCRIPTION
			Gets all the Collectors registered with the vRealize Operations Manager system.
		.EXAMPLE
			getCollectors -resthost $resthost -token $token
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		# need to add in host as a parameter
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/collectors'
		if ($token -ne $null) {
			$getCollectorsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getCollectorsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getCollectorsresponse
	}
}

# /api/credentialkinds --------------------------------------------------------------------------------------------------------

function getCredentialKinds {
	<#
		.SYNOPSIS
			Get all Credential Kinds defined in the system. Gets all the Credential Kinds defined in the system. 
		.DESCRIPTION
			Get all Credential Kinds defined in the system. Gets all the Credential Kinds defined in the system.
		.EXAMPLE
			getCredentialKinds -resthost $resthost -token $token
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/credentialkinds'
		
		if ($token -ne $null) {
			$getCredentialKindsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getCredentialKindsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getCredentialKindsresponse
	}
}

# /api/credentials ------------------------------------------------------------------------------------------------------------

function getCredentials {
	<#
		.SYNOPSIS
			Get all Credential Instances in the system. Gets all the Credential Instances in the system. Optionally filter by adapter kind keys or credential instance identifiers.
		.DESCRIPTION
			Get all Credential Instances in the system. Gets all the Credential Instances in the system. Optionally filter by adapter kind keys or credential instance identifiers.
		.EXAMPLE
			getCredentials -resthost $resthost -token $token -accept json
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		# ID
		# AdapterKind
	)
	$url = 'https://' + $resthost + '/suite-api/api/credentials'
	if ($token -ne $null) {
		$getCredentialsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getCredentialsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
	}	
	return $getCredentialsresponse
}

# /api/deployment -------------------------------------------------------------------------------------------------------------

function getLicenceKeysForProduct {
	<#
		.SYNOPSIS
			Gets all the License Details associated with a vRealize Operations Manager instance.
		.DESCRIPTION
			Gets all the License Details associated with a vRealize Operations Manager instance.
		.EXAMPLE
			getLicenceKeysForProduct -resthost $resthost -token cac9cdc1-c2b3-487c-a51f-4ccb45e2b246::5e0ab7fa-f401-497a-acce-e2429791fe98
		.EXAMPLE
			getLicenceKeysForProduct -resthost $resthost -credentials $credentials
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/deployment/licenses'
		if ($token -ne $null) {
			$getLicenceKeysForProductresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getLicenceKeysForProductresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}
		
		
		#$processedresponse = processReponse -rawresponse $getLicenceKeysForProductresponse -accept $accept -rootkey solutionlicenses
		
		return (processReponse -rawresponse $getLicenceKeysForProductresponse -accept $accept -jsonprimarykey solutionlicenses -xmlprimarykey "'solution-licenses'" -xmlsecondarykey "'solution-license'")
		

		
		
		
		

	}
}

function getNodeStatus {
	<#
		.SYNOPSIS
			get the status of the node
		.DESCRIPTION
			If the status is ONLINE if all the services are running and responsive. else status is OFFLINE 
		.EXAMPLE
			getNodeStatus -resthost $resthost -credentials $vropscreds
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.3.5
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/deployment/node/status'
		if ($token -ne $null) {
			$getNodeStatusresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getNodeStatusresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getNodeStatusresponse
	}
}

# /api/events -----------------------------------------------------------------------------------------------------------------

# /api/maintenanceschedules ---------------------------------------------------------------------------------------------------

# /api/notifications ----------------------------------------------------------------------------------------------------------

# /api/recommendations --------------------------------------------------------------------------------------------------------

# /api/reportdefinitions ------------------------------------------------------------------------------------------------------

function getReportDefinitions { # No test currently
	<#
		.SYNOPSIS
			TBC
		.DESCRIPTION
			TBC
		.EXAMPLE
			TBC
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER name
			TBC
		.PARAMETER owner
			TBC
		.PARAMTER duration
			TBC
		.NOTES
			Added in version 0.3.7
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][String]$name,
		[parameter(Mandatory=$false)][String]$owner,
		[parameter(Mandatory=$false)][String]$subject
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/reportdefinitions'
		if ($name -ne "") {
			$url += '?name=' + $name
			if ($owner -ne ""){
				$url += '&owner=' + $owner
			}
			if ($subject -ne "") {
				$url += '&subject' + $subject
			}
		}
		elseif ($owner -ne ""){
			$url += '?owner=' + $owner
			if ($subject -ne "") {
				$url += '&subject' + $subject
			}
		}
		elseif ($subject -ne "") {
			$url += '?subject' + $subject
		}
		if ($token -ne $null) {
			$getReportDefinitionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getReportDefinitionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}

		


		
		return $getReportDefinitionsresponse.reportdefinitions
	}
}

# /api/reports ----------------------------------------------------------------------------------------------------------------

function createReport {
	<#
		.SYNOPSIS
			Generate (create) a Report using the specified Report Definition and for the specified Resource.
		.DESCRIPTION
			Generate (create) a Report using the specified Report Definition and for the specified Resource.
		.EXAMPLE
			createReport -token $token -resthost vrops-01a.cloudkindergarten.local -reportdefinitionid 4eaae8d7-c57a-4e0a-a2bc-e103d63d1aaf -objectid f44eae09-b99a-4e85-9b8f-457739789ba1
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the subject that the report will be run against.
		.PARAMETER reportid
			The vROps ID of the report to be generated.
		.NOTES
			Added in version 0.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid,
		[parameter(Mandatory=$true)][String]$reportdefinitionid,
		[parameter(Mandatory=$false)][ValidateSet('vSphere Hosts and Clusters','Custom Groups')][String]$traversalspecname
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/reports'	
		if ($traversalspecname = 'vSphere Hosts and Clusters') {
			$tsname = 'vSphere Hosts and Clusters'
			$rAKK = 'VMWARE'
			$rRKK = 'vSphere World'
		}
		elseif ($traversalspecname = 'Custom Groups') {
			$tsname = 'Custom Groups'
			$rAKK = '?'
			$rRKK = '?'
		}	
		$body = @{
			'id'=$null
			'resourceId'=$objectid
			'reportDefinitionId'=$reportdefinitionid
			'traversalSpec'=@{
				'name'=$tsname
				'rootAdapterKindKey'=$rAKK
				'rootResourceKindKey'=$rRKK
				'adapterInstanceAssociation'=$false
				'others'=@()
				'otherAttributes'=@{}
				}
			'subject'=@()
			'others'=@()
			'otherAttributes'=@{}
		} | convertto-json -depth 5
		if ($token -ne $null) {
			$getCredentialKindsresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body
		}
		else {
			$getCredentialKindsresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -body $body
		}	
		return $getCredentialKindsresponse
	}
}
function downloadReport {
	<#
		.SYNOPSIS
			Download the Report given its identifier.
		.DESCRIPTION
			Download the Report given its identifier. The supported formats for Reports are:
				pdf
				csv
			If the format is not specified the downloaded report will be in PDF format.
		.EXAMPLE
			downloadReport -token $token -resthost $resthost -reportid $reportid -format 'csv' -outputfile 'c:\somedirectory\somefile.csv'
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER reportid
			The vROps ID of the report to be generated.
		.PARAMETER format
			TBC
		.PARAMETER outputfile
			Location to download the report to
		.NOTES
			Added in version 0.3.7
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('pdf','csv')][string]$format = 'pdf',
		[parameter(Mandatory=$false)]$outputfile,
		[parameter(Mandatory=$true)][String]$reportid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/reports/' + $reportid + '/download?format=' + $format
		if ($token -ne $null) {
			$restheaders = @{}
			$restheaders.add('Authorization',('vRealizeOpsToken ' + $token))
			$downloadReportresponse = invoke-webrequest -uri $url -header $restheaders -outfile $outputfile -method 'GET'
		}
		else {
			$downloadReportresponse = invoke-webrequest -uri $url -credential $credentials -outfile $outputfile -method 'GET'

		}	
		return $downloadReportresponse
	}
}
function getReport {
	<#
		.SYNOPSIS
			Gets the detail of a Report given its identifier.
		.DESCRIPTION
			Gets the detail of a Report given its identifier.
		.EXAMPLE
			getReport -token $token -resthost $resthost -reportid $reportid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER reportid
			The vROps ID of the report to be generated.
		.NOTES
			Added in version 0.3.7
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$reportid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/reports/' + $reportid
		if ($token -ne $null) {
			$getReportresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getReportresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getReportresponse
	}
}

# /api/resources -------------------------------------------------------------------------------------------------------------- 

function addProperties {
	<#
		.SYNOPSIS
			Adds Properties to a Resource. 
		.DESCRIPTION
			Adds Properties to a Resource. 
		.EXAMPLE
			addProperties -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object for which the properties are being added.
		.PARAMETER body
			Body content that describes the property/properties being added to the object
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)][String]$body,
		[parameter(Mandatory=$true)][String]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/properties/'
		if ($token -ne $null) {
			$addPropertiesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$addPropertiesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -body $body -contenttype $contenttype
		}
		return $addPropertiesresponse
	}
}
function addRelationship {
	<#
		.SYNOPSIS
			Add relationships of given type to the resource with specified resourceId. 
		.DESCRIPTION
			Add relationships of given type to the resource with specified resourceId.
			NOTE: Adding relationship is not synchronous. As a result, the add operation may not happen immediately.
			It is recommended to query the relationships of the specific Resource back to ensure that the operation was indeed successful. 
		.EXAMPLE
			addRelationship -resthost $resthost -token $token -objectid 6434d795-1bc4-42d5-a264-89f6b47f4d8e -relationship children -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object for which the relationship is being configured
		.PARAMETER body
			Body content that describes the relationship being created
		.PARAMETER relationship
			The relationship that is being defined, valid values are 'parent' or 'children'
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)][String]$objectid,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/relationships/' + $relationship
		if ($token -ne $null) {
			$addRelationshipresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$addRelationshipresponse = invokeRestMethod -method 'POST' -url $url -credentials $credentials -body $body -contenttype $contenttype
		}	
		return $addRelationshipresponse
	}
}
function addStats {
	<#
		.SYNOPSIS
			Adds Stats to a Resource.
		.DESCRIPTION
			It is recommended (though not required) to use this API when the resource was created using the API POST /api/resources/{id}/adapters/{adapterInstanceId}.
			Otherwise an additional adapter instance might be created. 
		.EXAMPLE
			addStats -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to add stats to
		.PARAMETER body
			The body payload that contains the details of the metrics and values to add
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.1
			Updated in version 0.4.2 to support disabling analytics processing
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$false)][switch]$disableanalyticsprocessing,
		[parameter(Mandatory=$true)][String]$objectid
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/stats'
		if ($disableanalyticsprocessing) {
			$url = $url + "?disableAnalyticsProcess=true"
		}
		if ($token -ne $null) {
			$addStatsresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$addStatsresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -body $body -contenttype $contenttype
		}	
		return $addStatsresponse
	}
}
function addStatsforResources {
	<#
		.SYNOPSIS
			Adds Stats to a group of resources.
		.DESCRIPTION
			It is recommended (though not required) to use this API when the resource was created using the API POST /api/resources/{id}/adapters/{adapterInstanceId}.
			Otherwise an additional adapter instance might be created. 
		.EXAMPLE
			addStatstoResources -resthost $resthost -token $token -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER body
			The body payload that contains the details of the IDs, metrics and values to add
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.4
			Updated in version 0.4.2 to support disabling analytics processing
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$false)][switch]$disableanalyticsprocessing,
		[parameter(Mandatory=$true)]$body
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/stats'
		if ($disableanalyticsprocessing) {
			$url = $url + "?disableAnalyticsProcess=true"
		}
		if ($token -ne $null) {
			$addStatsforResourcesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$addStatsforResourcesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -body $body -contenttype $contenttype
		}	
		return $addStatsforResourcesresponse
	}
}
function createResourceUsingAdapterKind {
	<#
		.SYNOPSIS
			Creates a new Resource in the system associated with an existing adapter instance.
		.DESCRIPTION
			The API will create the missing Adapter Kind and Resource Kind contained within the ResourceKey of the Resource if they do not exist.
			The API will return an error if the adapter instance specified does not exist.
		.EXAMPLE
			createResourceUsingAdapterKind -resthost $resthost -token $token -body $body -adapterID $adapterid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER body
			Body content that describes the new resource being created
		.PARAMETER adapterID
			The ID of the adapter instance on which the new resource should be created
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.	
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)]$adapterID
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/adapters/' + $adapterID

		if ($token -ne $null) {
			$createResourceUsingAdapterKindresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -contenttype $contenttype -body $body
		}
		else {
			$createResourceUsingAdapterKindresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -contenttype $contenttype -body $body
		}	
		return $createResourceUsingAdapterKindresponse
	}
}
function deleteRelationship {
	<#
		.SYNOPSIS
			Deletes (removes) a Resource as RelationshipType of a specific Resource.
		.DESCRIPTION
			Deletes (removes) a Resource as RelationshipType of a specific Resource.
			If either of the Resources that are part of the path parameters are invalid/non-existent then the API returns a 404 error.
			NOTE: Removing a relationship is not synchronous. As a result, the delete operation may not happen immediately.
			It is recommended to query the relationships of the specific Resource back to ensure that the operation was indeed successful. 
		.EXAMPLE
			deleteRelationship -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e -relatedid 6434d795-1bc4-42d5-a264-89f6b47f4d8e -relationship children
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to delete the relationship from
		.PARAMETER relatedid
			The vROps ID of the related object
		.PARAMETER relationship
			The vROps relationship between the primary object (objectid) and secondary object (relatedid)
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid,
		[parameter(Mandatory=$true)][String]$relatedid,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/relationships/' + $relationship + '/' + $relatedid	
		if ($token -ne $null) {
			$deleteRelationshipresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -token $token
		}
		else {
			$deleteRelationshipresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -credentials $credentials
		}	
		return $deleteRelationshipresponse
	}
}
function deleteResource {
	<#
		.SYNOPSIS
			Deletes a Resource with the given identifier. 
		.DESCRIPTION
			Deletes a Resource with the given identifier.
			NOTE: Deletion of a Resource is not synchronous. As a result, the delete operation may not happen immediately.
			It is recommended to query back the system with the resource identifier and ensure that the system returns a 404 error. 
		.EXAMPLE
			deleteResource -resthost $resthost -token $token -objectid 80133295-18e4-42d5-a264-8af6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the resource to delete
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)][String]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid
		if ($token -ne $null) {
			$deleteResourceresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -token $token -contenttype $contenttype
		}
		else {
			$deleteResourceresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -credentials $credentials -contenttype $contenttype
		}	
		return $deleteResourceresponse
	}
}
function getLatestStatsofResources {
	<#
		.SYNOPSIS
			Gets Latest stats of resources using the query spec that is specified.
		.DESCRIPTION
			Gets Latest stats of resources using the query spec that is specified.
		.EXAMPLE
			getLatestStatsofResources -resthost $resthost -token $token -objectid 80133295-18e4-42d5-a264-8af6b47f4d8e -statkey 'PowervROPsTesting|TestStat'
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object for which the latest stats should be returned
		.PARAMETER statkey
			If supplied the response will be limited to the vROps statkey supplied
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid,	
		[parameter(Mandatory=$true)]$statkey
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/stats/latest?resourceId=' + $objectid + '&statKey=' + $statkey
		if ($token -ne $null) {
			$getLatestStatsofResourcesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getLatestStatsofResourcesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}
		return $getLatestStatsofResourcesresponse
	}
}
function getRelationship {	
	<#
		.SYNOPSIS
			Gets the related resources of a particular Relationship Type for a Resource.
		.DESCRIPTION
			Gets the related resources of a particular Relationship Type for a Resource.
		.EXAMPLE
			getRelationship -resthost $resthost -token $token -objectid 80133295-18e4-42d5-a264-8af6b47f4d8e -relationship children
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			vROps ID of the object to query
		.PARAMETER relationship
			Relationship type to query, valid values are 'parent' and 'children'.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid,	
		[parameter(Mandatory=$true)][ValidateSet('children','parents')][String]$relationship
	)	
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/relationships/' + $relationship
		if ($token -ne $null) {
			$getRelationshipresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getRelationshipresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getRelationshipresponse
	}
}
function getResource {
	<#
		.SYNOPSIS
			Gets the Resource for the specified identifier.
		.DESCRIPTION
			Gets the Resource for the specified identifier.
		.EXAMPLE
			getResource -resthost $resthost -token $token -objectid 3014d793-18e4-42d5-a264-66f6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to query.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid	
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid
		if ($token -ne $null) {
			$getResourceresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourceresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getResourceresponse
	}
}
function getResourceProperties {
	<#
		.SYNOPSIS
			Gets all the Properties and their current (latest) values for the specified Resources.
		.DESCRIPTION
			Gets all the Properties and their current (latest) values for the specified Resources.
		.EXAMPLE
			getResourceProperties -resthost $resthost -token $token -objectid 80133295-18e4-42d5-a264-8af6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/properties'
		if ($token -ne $null) {
			$getResourcePropertiesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourcePropertiesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getResourcePropertiesresponse
	}
}
function getResourcePropertiesList {
	<#
		.SYNOPSIS
			Get all the properties for the specified Resource.
		.DESCRIPTION
			Get all the properties for the specified Resource.
		.EXAMPLE
			getResourceProperties -resthost $resthost -token $token -resourceIds [array of resource IDs]
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER resourceIds
			vROps ID of the object to query
		.NOTES
			Added in version 0.4.2.
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$resourceids
		)
	Process {	
		$url = 'https://' + $resthost + '/suite-api/api/resources/properties'
		for ($r=0;$r -lt $resourceIds.count;$r++) {
			if ($resourceids[$r] -ne $null) {
				if ($url.indexOf('properties?') -gt -1) {
					$url = ($url + "&resourceId=" + $resourceids[$r])
				}
				else {
					$url = ($url + "?resourceId=" + $resourceids[$r])
				}
			}	
		}
		if ($token -ne $null) {
			$getResourcePropertiesListresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourcePropertiesListresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getResourcePropertiesListresponse.resourcePropertiesList
	}
}
function getResources { # Need additional tests for pagesize and pagenumber
	<#
		.SYNOPSIS
			Gets a listing of resources based on the query spec specified.
		.DESCRIPTION
			Currently the function only permits querying for resources via the following filters:
				Name
				ResourceKind
				ObjectId
		.EXAMPLE
			getResources -resthost $resthost -token $token -name NameofObject
		.EXAMPLE
			getResources -resthost $resthost -token $token -resourceKind 'ClusterComputeResource'
		.EXAMPLE
			getResources -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER name
			The name of the vROps object to query.
		.PARAMETER resourceKind
			The resourceKind of the objects to query. This will return multiple objects. Examples of resourceKind are:
				ClusterComputeResource
				VirtualMachine
		.PARAMETER objectid
			The vROps ID of the object to query.
		.PARAMETER pagesize
			The number of records to return as part of the query
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][String]$name,
		[parameter(Mandatory=$false)][String]$resourceKind,
		[parameter(Mandatory=$false)][Int]$pagesize = 1000,
		[parameter(Mandatory=$false)][Int]$pagetoview = 0,
		[parameter(Mandatory=$false)][string]$objectid	
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources?'
		if ($name -ne "") {
			$url += 'name=' + $name + '&'
		}
		if ($resourceKind -ne "") {
			$url += 'resourceKind=' + $resourceKind + '&'
		}
		if ($objectid -ne "") {
			$url += 'resourceId=' + $objectid + '&'
		}
		$url = $url.Substring(0,$url.Length-1)
		$url += '&pageSize=' + $pagesize + '&page=' + $pagetoview
		
		if ($token -ne $null) {
			$getResourcesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getResourcesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}
		return $getResourcesresponse
	}
}
function getStatsForResources { # No test, and no documentation
	<#
		.SYNOPSIS
			TBC
		.DESCRIPTION
			TBC
		.EXAMPLE
			TBC
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			TBC
		.NOTES
			Added in version 0.4.0
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'	
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/stats/query'
		if ($token -ne $null) {
			$getStatsForResourcesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$getStatsForResourcesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -body $body -contenttype $contenttype
		}
		return $getStatsForResourcesresponse
	}
}
function markResourceAsBeingMaintained { # only single test for manual mode and documentation incomplete. Need tests for duration and end
	<#
		.SYNOPSIS
			Put the specific Resource in Maintenance.
		.DESCRIPTION
			The Resource can end up in two maintenance states - MAINTAINED OR MAINTAINED_MANUAL - depending upon the inputs specified.
				If duration/end time is specified, the resource will be placed in MAINTAINED state and after the duration/end time expires, the resource state is automatically set to the state it was in before entering the maintenance window.
				If duration/end time is not specified, the resource will be placed in MAINTAINED_MANUAL state. Callers have to execute DELETE /suite-api/api/resources/{id}/maintained API to set the Resource back to whatever state it was in.
				If both duration and end time are specified, end time takes preference over duration. 
		.EXAMPLE
			TBC
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to query.
		.PARAMETER duration
			The number of minutes that the object should be put into maintenance mode
		.PARAMTER end
			The date/time in Unix epoch format (number of milliseconds since 01/01/1970 00:00:00)
			Use the getTimeSinceEpoch function and pass a date to the function to retrieve the required value
		.NOTES
			Added in version 0.3.5
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid,
		[parameter(Mandatory=$false)][int]$duration,
		[parameter(Mandatory=$false)][string]$end
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/maintained'
		
		if ($end -ne $null) {
			$url += ('?end=' + $end)
		}
		elseif ($duration -ne $null) {
			$url += ('?duration=' + $duration)
		}
		
		if ($token -ne $null) {
			$markResourceAsBeingMaintainedresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token
		}
		else {
			$markResourceAsBeingMaintainedresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials
		}	
		return $markResourceAsBeingMaintainedresponse
	}
}
function setRelationship {
	<#
		.SYNOPSIS
			Set (Replace) Resources as RelationshipType of a specific Resource.
		.DESCRIPTION
			This API exposes replace semantics. Therefore, all the existing relationships of the specified
			relationshipType will be removed and replaced with the resources specified as part of the request body. 
		.EXAMPLE
			setRelationship -resthost $resthost -token $token -objectid 80133295-18e4-42d5-a264-8af6b47f4d8e -relationship children -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER contenttype
			Analogous to the header parameter 'Content-Type' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER body
			Body payload used to set the relationship
		.PARAMETER objectid
			The vROps ID of the object to set the relationship on
		.PARAMETER relationship
			The relationship type to set between the two objects. Valid values are parent or children.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)][String]$objectid,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/relationships/' + $relationship
		if ($token -ne $null) {
			$setRelationshipresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token -body $body -contenttype $contenttype
		}
		else {
			$setRelationshipresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials -body $body -contenttype $contenttype
		}	
		return $setRelationshipresponse	
	}
}
function startMonitoringResource {
	<#
		.SYNOPSIS
			Inform one or more or all Adapters to start monitoring this Resource.
		.DESCRIPTION
			Inform one or more or all Adapters to start monitoring this Resource.
		.EXAMPLE
			startMonitoringResource -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to start monitoring
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/monitoringstate/start'
		if ($token -ne $null) {
			$startMonitoringResourceresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token
		}
		else {
			$startMonitoringResourceresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials
		}	
		return $startMonitoringResourceresponse
	}
}
function stopMonitoringResource {
	<#
		.SYNOPSIS
			Inform one or more or all Adapters to stop monitoring this Resource.
		.DESCRIPTION
			Inform one or more or all Adapters to stop monitoring this Resource.
		.EXAMPLE
			stopMonitoringResource -resthost $resthost -token $token -objectid 8014d795-18e4-42d5-a264-89f6b47f4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to stop monitoring
		.NOTES
			Added in version 0.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/monitoringstate/stop'	
		if ($token -ne $null) {
			$stopMonitoringResourceresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token
		}
		else {
			$stopMonitoringResourceresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials
		}	
		return $stopMonitoringResourceresponse
	}
}
function unmarkResourceAsBeingMaintained {
	<#
		.SYNOPSIS
			Bring the Resource out of Maintenance manually.
		.DESCRIPTION
			Bring the Resource out of Maintenance manually.
		.EXAMPLE
			unmarkResourceAsBeingMaintained -resthost $resthost -token $token -objectid $resourceid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the object to query.
		.NOTES
			Added in version 0.3.5
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid
		)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/maintained'
		if ($token -ne $null) {
			$unmarkResourceAsBeingMaintainedresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -token $token
		}
		else {
			$unmarkResourceAsBeingMaintainedresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -credentials $credentials
		}	
		return $unmarkResourceAsBeingMaintainedresponse
	}
}		

# /api/solutions --------------------------------------------------------------------------------------------------------------

# /api/supermetrics -----------------------------------------------------------------------------------------------------------

function getSuperMetric {
	<#
		.SYNOPSIS
			Get a SuperMetric with the given id.
		.DESCRIPTION
			Get a SuperMetric with the given id.
		.EXAMPLE
			getSuperMetric -resthost $resthost -token $token -supermetricid 3014d718-18e4-42d5-b264-66f6b4ff4d8e
		.EXAMPLE
			getSuperMetric -resthost $resthost -credentials $credentials -supermetricid 3014d718-18e4-42d5-b264-66f6b4ff4d8e
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER supermetricid
			ID of the supermetric, can be obtained either manually via the UI or via the getSuperMetrics
			cmdlet
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][string]$supermetricid	
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/api/supermetrics/' + $supermetricid
		if ($token -ne $null) {
			$getSuperMetricresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
		}
		else {
			$getSuperMetricresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
		}	
		return $getSuperMetricresponse	
	}
}
function getSuperMetrics {
	<#
		.SYNOPSIS
			Gets a collection of SuperMetrics based on search parameters.
		.DESCRIPTION
			Gets a collection of SuperMetrics based on search parameters. Possible methods for filltering are:
			name
			supermetricid (not yet implemented)
		.EXAMPLE
			getSuperMetrics -resthost $resthost -token $token
		.EXAMPLE
			getSuperMetrics -resthost $resthost -credentials $credentials -name MyFirstSupermetric
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER name
			The name of the supermetric to query
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][switch]$ignoressl,
		[parameter(Mandatory=$false)][string]$name	
		)
	Process {
		if (($name -eq $null) -or ($name -eq "")) {
			$url = 'https://' + $resthost + '/suite-api/api/supermetrics'
		}
		else {
			$url = 'https://' + $resthost + '/suite-api/api/supermetrics?name=' + $name
		}		
		if ($token -ne $null) {
			if ($ignoressl) {
				$getSuperMetricsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token -ignoressl
			}
			else {
				$getSuperMetricsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
			}
		}
		else {
			if ($ignoressl) {
				$getSuperMetricsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials -ignoressl
			}
			else {
				$getSuperMetricsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials
			}	
		}	
		return $getSuperMetricsresponse		
	}
}

# /api/symptomdefinitions -----------------------------------------------------------------------------------------------------

# /api/symptoms ---------------------------------------------------------------------------------------------------------------

# /api/tasks ------------------------------------------------------------------------------------------------------------------

# /api/versions ---------------------------------------------------------------------------------------------------------------

# /internal/resources ---------------------------------------------------------------------------------------------------------

function createStaticGroup {
	<#
		.SYNOPSIS
			Create a new custom static group definition
		.DESCRIPTION
			Create a static group
		.EXAMPLE
			createStaticGroup -resthost $resthost -token $token -resourceIds $resourceIds -resourcekindkey $resourcekindkey -name $name
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER resourceIds
			An array of resource Ids to add to the group

		.NOTES
			Added in version 0.4.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$name,
		[parameter(Mandatory=$true)]$resourceids,
		[parameter(Mandatory=$true)]$resourcekindkey
	)
	Process {

		# Due to the character limits in Powershell for URI, if the number of resource IDs is greater than 30, the remaining items are added to the custom group using the includeMoreResourcesIntoCustomGroup function
		
		if ($resourceids.count -gt 30) {
			$numberofruns = 0
			$numberperrun = 30
			do {
				if ($numberofruns -eq 0) { # The group hasn't been created yet, create the group and add the first 30 resource IDs
					$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/static?name=' + $name + "&resourceKind=" + $resourcekindkey + "&adapterKind=Container"
					for ($r = ($numberperrun * $numberofruns);$r -lt ($numberperrun * ($numberofruns + 1));$r++) {
						if ($resourceids[$r] -ne $null) {
							$url = ($url + "&resourceId=" + $resourceids[$r])
						}	
					}
					if ($token -ne $null) {
						$createStaticGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -useinternalapi $true
					}
					else {
						$createStaticGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -useinternalapi $true
					}
				} # The group already exists, and we have the group ID
				else {
					$newresourceids = New-Object System.Collections.ArrayList
					for ($r = ($numberperrun * $numberofruns);$r -lt ($numberperrun * ($numberofruns + 1));$r++) {
						if ($resourceids[$r] -ne $null) {
							$newresourceids.add($resourceids[$r]) | out-null
						}	
					}
					if ($token -ne $null) {
						includeMoreResourcesIntoCustomGroup -groupid $createStaticGroupresponse.identifier -resthost $resthost -token $token -resourceids $newresourceids
					}
					else {
						includeMoreResourcesIntoCustomGroup -groupid $createStaticGroupresponse.identifier -resthost $resthost -credentials $credentials -resourceids $newresourceids
					}
				}
				$numberofruns++
			}
			Until (($numberofruns*$numberperrun) -ge $resourceids.count)
		}
		else { # There are less than 30 resource IDs, create the group in the standard fashion as an all-in-one call
			$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/static?name=' + $name + "&resourceKind=" + $resourcekindkey + "&adapterKind=Container"
			foreach ($resourceid in $resourceids) {
				if ($resourceid -ne $null) {
					$url = ($url + "&resourceId=" + $resourceid)
				}	
			}
			if ($token -ne $null) {
				$createStaticGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -useinternalapi $true
			}
			else {
				$createStaticGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -useinternalapi $true
			}
			return $createStaticGroupresponse
		}
	}
}
function getCustomGroup {
	<#
		.SYNOPSIS
			Retrieve a custom group definition using its identifier.
		.DESCRIPTION
			Retrieve a custom group definition using its identifier.
		.EXAMPLE
			getCustomGroup -resthost $resthost -token $token -objectid $customgroupid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the custom group to query
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][string]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $objectid	
		if ($token -ne $null) {
			$getcustomgroupresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$getcustomgroupresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $getcustomgroupresponse	
	}
}
function getCustomGroups {
	<#
		.SYNOPSIS
			Query for custom groups based on groupId and whether they are dynamic or static.
		.DESCRIPTION
			Query for custom groups based on groupId and whether they are dynamic or static.
		.EXAMPLE
			getCustomGroups -resthost $resthost -token $token
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)]$pagesize = 1000,
		[parameter(Mandatory=$false)]$pagetoview = 0
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups'
		if ($token -ne $null) {
			$getCustomGroupsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$getCustomGroupsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $getCustomGroupsresponse
	}
}
function createCustomGroup {
	<#
		.SYNOPSIS
			Create a new custom group definition
		.DESCRIPTION
			The new group can be created with one of the following definitions:
				Metric Key
				Property Key
				Relationship Condition
				Resource Name
		.EXAMPLE
			createCustomGroup -resthost $resthost -token $token -body $body
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER body
			Body content to be used when creating the custom group
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)][String]$body
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups'
		if ($token -ne $null) {
			$createCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -useinternalapi $true -contenttype $contenttype -body $body
		}
		else {
			$createCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -useinternalapi $true -contenttype $contenttype -body $body
		}	
		return $createCustomGroupresponse
	}
}
function getMembersOfGroup {
	<#
		.SYNOPSIS
			Get the list of (computed/static) members of the group. 
		.DESCRIPTION
			Get the list of (computed/static) members of the group. 
		.EXAMPLE
			getMembersOfGroup -resthost $resthost -credentials $credentials -objectid $customgroupID
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the group to get the members of
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $objectid + '/members'
		if ($token -ne $null) {
			$getMembersOfGroupresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$getMembersOfGroupresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $getMembersOfGroupresponse
	}
}
function deleteCustomGroup {
	<#
		.SYNOPSIS
			Delete a custom group. 
		.DESCRIPTION
			Delete a custom group. 
		.EXAMPLE
			deleteCustomGroup -resthost $resthost -token $token -objectid $customgroupID
		.EXAMPLE
			deleteCustomGroup -resthost $resthost -credentials $credentials -objectid $customgroupID
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			Analogous to the header parameter 'Accept' used in REST calls, valid values are xml or json.
			However, the module has only been tested against json.
		.PARAMETER objectid
			The vROps ID of the custom group to delete
		.NOTES
			Added in version 0.1
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$objectid
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $objectid

		if ($token -ne $null) {
			$deleteCustomGroupresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$deleteCustomGroupresponse = invokeRestMethod -method 'DELETE' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $deleteCustomGroupresponse
	}
}
function excludeMoreResourcesFromCustomGroup {
	<#
		.SYNOPSIS
			Removes a list of resource IDs from a custom group
		.DESCRIPTION
			Removes a list of resource IDs from a custom group
		.EXAMPLE
			excludeMoreResourcesFromCustomGroup -resthost $resthost -token $token -resourceIds $resourceIds -groupid $groupid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER resourceIds
			An array of resource Ids to remove from the group
		.PARAMETER groupId
			vROps GUID of the custom group
		.NOTES
			Added in version 0.4.3
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$resourceids,
		[parameter(Mandatory=$true)]$groupid

	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $groupid + '/excludedResources'
		foreach ($resourceid in $resourceids) {
			if ($resourceid -ne $null) {
				if ($url.indexOf("resourceId") -eq -1) {	
					$url = ($url + "?resourceId=" + $resourceid)
				}
				else {
					$url = ($url + "&resourceId=" + $resourceid)
				}
			}	
		}		
		if ($token -ne $null) {
			$excludeMoreResourcesFromCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$excludeMoreResourcesFromCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $includeMoreResourcesIntoCustomGroupresponse
	}
}
function includeMoreResourcesIntoCustomGroup {
	<#
		.SYNOPSIS
			Replace the list of resources in the included resources list.
		.DESCRIPTION
			Replace the list of resources in the included resources list.
		.EXAMPLE
			includeMoreResourcesIntoCustomGroup -resthost $resthost -token $token -resourceIds $resourceIds -groupid $groupid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER resourceIds
			An array of resource Ids to add to the group
		.PARAMETER groupId
			vROps GUID of the custom group

		.NOTES
			Added in version 0.4.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$resourceids,
		[parameter(Mandatory=$true)]$groupid

	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $groupid + '/includedResources'
		foreach ($resourceid in $resourceids) {
			if ($resourceid -ne $null) {
				if ($url.indexOf("resourceId") -eq -1) {	
					$url = ($url + "?resourceId=" + $resourceid)
				}
				else {
					$url = ($url + "&resourceId=" + $resourceid)
				}
			}	
		}
		if ($token -ne $null) {
			$includeMoreResourcesIntoCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$includeMoreResourcesIntoCustomGroupresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $includeMoreResourcesIntoCustomGroupresponse
	}
}
function replaceIncludedResourcesOfCustomGroup {
	<#
		.SYNOPSIS
			Replace the list of resources in the included resources list.
		.DESCRIPTION
			Replace the list of resources in the included resources list.
		.EXAMPLE
			replaceIncludedResourcesOfCustomGroup -resthost $resthost -token $token -resourceIds $resourceIds -resourcekindkey $resourcekindkey -name $name -groupid $groupid
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER resourceIds
			An array of resource Ids to add to the group
		.PARAMETER groupId
			The ID of the group that should be updated

		.NOTES
			Added in version 0.4.2
	#>
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$resourceids,
		[parameter(Mandatory=$true)]$groupid

	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $groupid + '/includedResources'
		foreach ($resourceid in $resourceids) {
			if ($resourceid -ne $null) {
				if ($url.indexOf("resourceId") -eq -1) {	
					$url = ($url + "?resourceId=" + $resourceid)
				}
				else {
					$url = ($url + "&resourceId=" + $resourceid)
				}
			}
		}
		if ($token -ne $null) {
			$createStaticGroupresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token -useinternalapi $true
		}
		else {
			$createStaticGroupresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials -useinternalapi $true
		}	
		return $createStaticGroupresponse
	}
}
function modifyCustomGroup {
	<#
		.SYNOPSIS
			Modified a custom group. 
		.DESCRIPTION
			Modified a custom group. 
		.EXAMPLE
			TBC
		.EXAMPLE
			TBC
		.PARAMETER credentials
			A set of PS Credentials used to authenticate against the vROps endpoint.
		.PARAMETER token
			If token based authentication is being used (as opposed to credential based authentication)
			then the token returned from the acquireToken cmdlet should be used.
		.PARAMETER resthost
			FQDN of the vROps instance or cluster to operate against.
		.PARAMETER accept
			TBC
		.PARAMETER objectid
			The vROps ID of the custom group to delete
		.NOTES
			Added in version 0.4.0
	#>
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')]$contenttype = 'json',
		[parameter(Mandatory=$true)][String]$body
	)
	Process {
		$url = 'https://' + $resthost + '/suite-api/internal/resources/groups'
		if ($token -ne $null) {
			$modifyCustomGroupresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -token $token -useinternalapi $true -contenttype $contenttype -body $body
		}
		else {
			$modifyCustomGroupresponse = invokeRestMethod -method 'PUT' -url $url -accept $accept -credentials $credentials -useinternalapi $true -contenttype $contenttype -body $body
		}	
		return $modifyCustomGroupresponse
}
}

# Export the functions from the script

export-modulemember -function 'get*'
export-modulemember -function 'Create*'
export-modulemember -function 'add*'
export-modulemember -function 'set*'
export-modulemember -function 'delete*'
export-modulemember -function 'download*'
export-modulemember -function 'start*'
export-modulemember -function 'stop*'
export-modulemember -function 'acquire*'
export-modulemember -function 'enumerate*'
export-modulemember -function 'update*'
export-modulemember -function 'mark*'
export-modulemember -function 'unmark*'
export-modulemember -function 'modify*'
export-modulemember -function 'connect*'
export-modulemember -function 'process*'
export-modulemember -function 'replace*'
export-modulemember -function 'include*'
export-modulemember -function 'exclude*'

