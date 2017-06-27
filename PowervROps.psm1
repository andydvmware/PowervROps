# |--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
# |                                                                                                               													   |
# | Module Name: PowervROps.psm1                                                           																		  	   |
# | Author: Andy Davies (andyd@vmware.com)                                                                        													   |
# | Date: 27th June 2017                                                                                    														   |
# | Description: PowerShell module that enables the use of the vROPs API via PowerShell cmdlets																		   |
# | Version: 0.3.0                                                                                                  												   |
# |--------------------------------------------------------------------------------------------------------------------------------------------------------------------|

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
		[parameter(Mandatory=$false)][ValidateSet('GET','PUT','POST')][string]$method,
		[parameter(Mandatory=$false)]$body,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',	
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][ValidateSet($true,$false)][string]$useinternalapi = $false,
		[parameter(Mandatory=$false)][int]$timeoutsec = 30
	)
	if (($credentials -eq $null) -and ($token -eq $null)) {
		return "No credentials or bearer token supplied"
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
				return $_.Exception.Message	
			}	
		}
		else {
			Try {
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -body $body -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
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
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -timeoutsec $timeoutsec -ErrorAction Stop
				return $response
			}
			Catch {
				return $_.Exception.Message	
			}	
		}
		else {
			Try {
				$response = Invoke-RestMethod -Method $method -Uri $url -Headers $restheaders -credential $credentials -timeoutsec $timeoutsec -ErrorAction Stop
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

function getAllActions { # Rewritten? Yes, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		)
		$url = 'https://' + $resthost + '/suite-api/api/actiondefinitions'
		if ($token -ne $null) {
		$getAllActionsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAllActionsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getAllActionsresponse
}

#/api/actions

# /api/adapterkinds

# /api/adapters

# /api/alertdefinitions

	
function getAlertDefinitionById { # Rewritten? YES, Added Function Descriptions? No

	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][String]$alertdefinitionid
		)
	$url = 'https://' + $resthost + '/suite-api/api/alertdefinitions/' + $alertdefinitionid		
	#$restheaders = @{}
	#$restheaders.Add('Accept','application/'+$responseformat)
	#$resturl = 'https://' + $resthost + '/suite-api/api/alertdefinitions/' + $alertdefinitionid
	if ($token -ne $null) {
		$getAlertDefinitionByIdresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAlertDefinitionByIdresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getAlertDefinitionByIdresponse
	
	
	
	
	#Try {
	#	$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	#}
	#Catch {
		#$Error[0].Exception.InnerException
		#return $_.Exception.Message	
	#}
	#return $reponse
}	
function getAlertDefinitions { # Rewritten? YES, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][String]$alertdefinitionid,
		[parameter(Mandatory=$false)][String]$adapterkind,
		[parameter(Mandatory=$false)][String]$resourcekind
		)
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
			$getAlertDefinitionsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
		}	
		return $getAlertDefinitionsresponse
	}
}



# /api/alertplugins


	
# /api/alerts	

function getAlert { # Rewritten? YES, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$alertid
	)
	$url = 'https://' + $resthost + '/suite-api/api/alerts/' + $alertid
	if ($token -ne $null) {
		$getAlertresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAlertresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getAlertresponse
}
function getAlerts { # Need to add ID and resourceID parameters and logic,........... Rewritten? YES, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		# ID
		# resourceID
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)

$url = 'https://' + $resthost + '/suite-api/api/alerts'
	if ($token -ne $null) {
		$getAlertsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAlertsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getAlertsresponse
}


# /api/auth

function acquireToken { # Rewritten? Needs tidying up, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$contenttype = 'json',
		[parameter(Mandatory=$false)][string]$username,
		[parameter(Mandatory=$false)][string]$authSource,
		[parameter(Mandatory=$false)][string]$password
	)		
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$accept)
	$restheaders.Add('Content-Type','application/'+$contenttype)
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

function getAdaptersOnCollector { # Rewritten? Yes, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)]$id
	)
	$url = 'https://' + $resthost + '/suite-api/api/collectors/' + $id + '/adapters'
	if ($token -ne $null) {
		$getAdaptersOnCollectorresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getAdaptersOnCollectorresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getAdaptersOnCollectorresponse
}
function getCollectors { # need to add in host as a parameter................... Rewritten? Yes, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		# need to add in host as a parameter
	)
	$url = 'https://' + $resthost + '/suite-api/api/collectors'
	if ($token -ne $null) {
		$getCollectorsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getCollectorsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getCollectorsresponse
}

# /api/credentialkinds

function getCredentialKinds { # Rewritten? Yes, Added Function Descriptions? No
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
		
	$url = 'https://' + $resthost + '/suite-api/api/credentialkinds'
	
	if ($token -ne $null) {
		$getCredentialKindsresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getCredentialKindsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getCredentialKindsresponse
}
function createResourceUsingAdapterKind { # Rewritten? NO, Added Function Descriptions? No
	<#
	.SYNOPSIS
		Creates a new Resource in the system associated with an existing adapter instance..
	.DESCRIPTION
		The API will create the missing Adapter Kind and Resource Kind contained within the ResourceKey of the Resource if they do not exist. The API will return an error if the adapter instance specified does not exist.
		Additional implementation notes:

		When creating a Resource, if the Resource Identifiers that are unique and required are not specified, the API would return an error with HTTP status code of 500 and an error message indicating the set of missing Resource Identifiers.
		When creating a Resource, if the Resource Identifiers that are unique but not required are not specified, the Resource is created where the uniquely identifying Resource Identifiers that were not specified will have their value as an empty string. 
	.EXAMPLE
		CreateResourceUsingAdapterKind -credentials [some PS credentials] -resthost 'myvropshost.local' -adapterKindKey 'VMWARE'
	.EXAMPLE
		CreateResourceUsingAdapterKind -credentials [some PS credentials] -resthost 'myvropshost.local' -adapterKindKey 'VMWARE' -responseformat 'json' -restcontettype 'json' -body [some body content xml/json]
	.PARAMETER credentials
		A set of PS credentials that are passed to the rest host for authentication during execution
	.PARAMETER resthost
		Fully qualified domain name of the vROps node/cluster that you are running the REST call against
	.PARAMETER responseformat
		Equivalent to the accept component of the header. The accepted values are xml or json (default)
	.PARAMETER body
		The body content that will be passed to the vROps node/cluster. Format can be xml or json but the format needs to match the restcontentparameter value
	.PARAMETER restcontenttype
		The formate of the body content. Accepted values are xml or json (default)
	.PARAMETER adapterKindKey
		The key value of the adapter kind that the new resource is being created against. Defaults to VMWARE. MAY NEED TO DELETE THIS
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)]$adapterID
		)		

	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$contenttype = 'application/' + $restcontenttype
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/adapters/' + $adapterID
	Try {
		$reponse = Invoke-RestMethod -Method 'POST' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse
}
function enumerateAdapterInstances {# Rewritten? Yes, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'	
		)
	$url = 'https://' + $resthost + '/suite-api/api/adapters'
	if ($token -ne $null) {
		$enumerateAdapterInstancesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$enumerateAdapterInstancesresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $enumerateAdapterInstancesresponse	
}

# /api/credentials

function getCredentials { # Need to do ID and AdapterKind filters....... Rewritten? Yes, Added Function Descriptions? No
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
		$getCredentialsresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getCredentialsresponse
}

# /api/deployment

function getLicenceKeysForProduct { # Rewritten? Yes, Added Function Descriptions? No
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
	)
	$url = 'https://' + $resthost + '/suite-api/api/deployment/licenses'
	if ($token -ne $null) {
		$getLicenceKeysForProductresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getLicenceKeysForProductresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getLicenceKeysForProductresponse





}

# /api/events

# /api/maintenanceschedules

# /api/notifications

# /api/recommendations

# /api/reportdefinitions

# /api/reports

# /api/resources

function addProperties { # Rewritten? Yes, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$body,
		[parameter(Mandatory=$true)][String]$id
		)
	$url = 'https://' + $resthost + '/suite-api/api/resources/' + $id + '/properties/'
	if ($token -ne $null) {
		$addPropertiesresponse = invokeRestMethod -method 'POST' -url $url -accept $accept -token $token -body $body -contenttype $restcontenttype
	}
	else {
		$addPropertiesresponse = invokeRestMethod -method 'POST' -url $url -credentials $credentials -body $body -contenttype $restcontenttype
	}	
	return $addPropertiesresponse
}
function addRelationship { # Rewritten? No, Added Function Descriptions? No
	<#
	.SYNOPSIS
		Add relationships of given type to the resource with specified resourceId. 
	.DESCRIPTION
		Add relationships of given type to the resource with specified resourceId:
		- If all of the Resources that are part of the relatedIds list are invalid/non-existent then the API returns a 404 error. 
		- If at least a few of the Resources that are part of relatedIds list are valid resources then the operation is performed. 
		- If there are few Resources that are part of relatedIds list that will result in a cyclical relationship, then those resources will be skipped.
		NOTE: Adding relationship is not synchronous. As a result, the add operation may not happen immediately. It is recommended to query the relationships of the specific Resource back to ensure that the operation was indeed successful. 	
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		A set of PS credentials that are passed to the rest host for authentication during execution
	.PARAMETER resthost
		Fully qualified domain name of the vROps node/cluster that you are running the REST call against
	.PARAMETER responseformat
		Equivalent to the accept component of the header. The accepted values are xml or json (default)
	.PAREMETER object
		TBC
	.PARAMETER relationship
		TBC
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$object,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
		)
		$restheaders = @{}
		$restheaders.Add('Accept','application/'+$responseformat)
		$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $object + '/relationships/' + $relationship
		$contenttype = 'application/' + $restcontenttype
		Try {
			$reponse = Invoke-WebRequest -Method 'POST' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
		}
		Catch {
			return $_.Exception.Message	
		}
		return $reponse
}
function addStats { # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$objectid
		)
		$restheaders = @{}
		$restheaders.Add('Accept','application/'+$responseformat)
		$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $objectid + '/stats'
		$contenttype = 'application/' + $restcontenttype
		Try {
			$reponse = Invoke-WebRequest -Method 'POST' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
		}
		Catch {
			return $_.Exception.Message	
		}
		return $reponse

}
function setRelationship { # Rewritten? No, Added Function Descriptions? No
	<#
	.SYNOPSIS
		TBC
	.DESCRIPTION
		TBC
	.EXAMPLE
		TBC
	.EXAMPLE
		TBC
	.PARAMETER credentials
		A set of PS credentials that are passed to the rest host for authentication during execution
	.PARAMETER resthost
		Fully qualified domain name of the vROps node/cluster that you are running the REST call against
	.PARAMETER responseformat
		Equivalent to the accept component of the header. The accepted values are xml or json (default)
	.PAREMETER object
		TBC
	.PARAMETER relationship
		TBC
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)]$body,
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$object,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
		)
		$restheaders = @{}
		$restheaders.Add('Accept','application/'+$responseformat)
		$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $object + '/relationships/' + $relationship
		$contenttype = 'application/' + $restcontenttype
		Try {
			$reponse = Invoke-WebRequest -Method 'PUT' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
		}
		Catch {
			return $_.Exception.Message	
		}
		return $reponse
}
function getRelationship { # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)][String]$object,
		[parameter(Mandatory=$true)][ValidateSet('children','parents')][String]$relationship
		)
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $object + '/relationships/' + $relationship
	$resturl
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse
}
function getResourceProperties { # Rewritten? Yes, Added Function Descriptions? No
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$id	
		)
	$url = 'https://' + $resthost + '/suite-api/api/resources/' + $id + '/properties'
	if ($token -ne $null) {
		$getResourcePropertiesresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token
	}
	else {
		$getResourcePropertiesresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials
	}	
	return $getResourcePropertiesresponse
}
function deleteRelationship { # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)][String]$parent,
		[parameter(Mandatory=$true)][String]$child,
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
		)
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $parent + '/relationships/' + $relationship + '/' + $child
	Try {
		$reponse = Invoke-WebRequest -Method 'DELETE' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse
}
function startMonitoringResource { # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)][String]$object
		)
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $object + '/monitoringstate/start'
	$response = Invoke-WebRequest -Method 'PUT' -Uri $resturl -credential $credentials -contenttype $restcontenttype -headers $restheaders
	return $response
}
function getResources { # NEED TO ADD ALL QUERY TYPES # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$false)][String]$name,
		[parameter(Mandatory=$false)][String]$resourceKind
		)
	$resturl = 'https://' + $resthost + '/suite-api/api/resources?name=' + $name + '&resourceKind=' + $resourceKind
	$resturl
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop 
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse




}

# /api/solutions



# /api/supermetrics


function getSuperMetric { # Rewritten? No, Added Function Descriptions? No
Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$id	
		)
	if (($credentials -eq $null) -and ($token -eq $null)) {
		return "No credentials or bearer token supplied"
	}
	else {
		$restheaders = setRestHeaders -accept $accept -token $token
		$resturl = 'https://' + $resthost + '/suite-api/api/supermetrics/' + $id
		Try {
			$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -body $body -ErrorAction Stop
		}
		Catch {
			return $_.Exception.Message	
		}
		return $reponse
	}
}
function getSuperMetrics { # Rewritten? No, Added Function Descriptions? No
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
			$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -body $body -ErrorAction Stop
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

function getCustomGroup { # Rewritten? Yes, Added Function Descriptions? No
	Param	(
		[parameter(Mandatory=$false)]$credentials,
		[parameter(Mandatory=$false)]$token,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json',
		[parameter(Mandatory=$false)][string]$id	
		)
	$url = 'https://' + $resthost + '/suite-api/internal/resources/groups/' + $id	
	if ($token -ne $null) {
		$getcustomgroupresponse = invokeRestMethod -method 'GET' -url $url -accept $accept -token $token -useinternalapi $true
	}
	else {
		$getcustomgroupresponse = invokeRestMethod -method 'GET' -url $url -credentials $credentials -useinternalapi $true
	}	
	return $getcustomgroupresponse	
}
function getCustomGroups { # Rewritten? No, Added Function Descriptions? No
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
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$accept = 'json'
		)
	$resturl = 'https://' + $resthost + '/suite-api/internal/resources/groups'
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
function createCustomGroup { # Rewritten? No, Added Function Descriptions? No
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
function getMembersOfGroup { # Rewritten? No, Added Function Descriptions? No




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
function deleteCustomGroup { # Rewritten? No, Added Function Descriptions? No
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



export-modulemember -function 'updateAlertDefinition'
export-modulemember -function 'getAlertDefinitionById'
export-modulemember -function 'get*'
export-modulemember -function 'Create*'
export-modulemember -function 'add*'
export-modulemember -function 'set*'
export-modulemember -function 'delete*'
export-modulemember -function 'start*'
export-modulemember -function 'acquire*'
export-modulemember -function 'enumerate*'




