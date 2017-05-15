# PowervROps
function getAlertDefinitionById {
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
	.PARAMETER restcontenttype
		The format of the body content. Accepted values are xml or json (default)
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)][String]$alertdefinitionid
		)		
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/alertdefinitions/' + $alertdefinitionid
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse
}

function updateAlertDefinition {
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
	.PARAMETER restcontenttype
		The format of the body content. Accepted values are xml or json (default)
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json',
		[parameter(Mandatory=$true)][ValidateSet('xml','json')]$restcontenttype = 'json',
		[parameter(Mandatory=$true)][String]$body
		)		
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$contenttype = 'application/' + $restcontenttype
	$resturl = 'https://' + $resthost + '/suite-api/api/alertdefinitions'
	Try {
		$reponse = Invoke-RestMethod -Method 'PUT' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
	return $reponse
}


# /api/collectors
# ---------------

function getAdaptersonCollector {
# GET /api/collectors/{id}/adapters
}

function getCollectors {

Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json'
		)
$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)		
	$resturl = 'https://' + $resthost + '/suite-api/api/collectors'
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
}

# /api/credentialkinds

function getCredentialKinds {
Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json'
		)
$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)		
	$resturl = 'https://' + $resthost + '/suite-api/api/credentialkinds'
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -body $body -contenttype $contenttype -ErrorAction Stop
	}
	Catch {
		$Error[0].Exception.InnerException
		return $_.Exception.Message	
	}
}



export-modulemember -function 'updateAlertDefinition'
export-modulemember -function 'getAlertDefinitionById'
export-modulemember -function 'get*'