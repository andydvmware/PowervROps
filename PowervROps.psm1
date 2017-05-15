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

function createResourceUsingAdapterKind {
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

function Get-vROpsAdapterTypes {
	<#
	.SYNOPSIS
		Creates a new Resource in the system associated with an existing adapter instance..
	.DESCRIPTION
		The API will create the missing Adapter Kind and Resource Kind contained within the ResourceKey of the Resource if they do not exist. The API will return an error if the adapter instance specified does not exist.
		Additional implementation notes:
		When creating a Resource, if the Resource Identifiers that are unique and required are not specified, the API would return an error with HTTP status code of 500 and an error message indicating the set of missing Resource Identifiers.
		When creating a Resource, if the Resource Identifiers that are unique but not required are not specified, the Resource is created where the uniquely identifying Resource Identifiers that were not specified will have their value as an empty string. 
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
	#> 
	Param	(
		[parameter(Mandatory=$true)]$credentials,
		[parameter(Mandatory=$true)][String]$resthost,
		[parameter(Mandatory=$false)][ValidateSet('xml','json')][string]$responseformat = 'json'
		)		
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/adapters'
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse
}



# /api/resources

function addProperties { # NOT STARTED
# POST /api/resources/{id}/properties
}
function addRelationship {
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
function setRelationship {
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
function getRelationship {
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
		[parameter(Mandatory=$true)][ValidateSet('children','parent')][String]$relationship
		)
	$restheaders = @{}
	$restheaders.Add('Accept','application/'+$responseformat)
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $object + '/relationships/' + $relationship
	Try {
		$reponse = Invoke-RestMethod -Method 'GET' -Uri $resturl -Headers $restheaders -credential $credentials -ErrorAction Stop
	}
	Catch {
		return $_.Exception.Message	
	}
	return $reponse
}

function deleteRelationship {
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

function startMonitoringResource {
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
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/' + $parentcustomdatacenter + '/monitoringstate/start'
	$response = Invoke-WebRequest -Method 'PUT' -Uri $resturl -credential $vropscreds -contenttype $restcontenttype -headers $restheaders	
}

function getResources { # NEED TO ADD ALL QUERY TYPES
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
	$resturl = 'https://' + $resthost + '/suite-api/api/resources/?name=' + $name + '&resourceKind=' + $resourceKind
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




export-modulemember -function 'updateAlertDefinition'
export-modulemember -function 'getAlertDefinitionById'
export-modulemember -function 'get*'
export-modulemember -function 'Create*'
export-modulemember -function 'add*'
export-modulemember -function 'set*'
export-modulemember -function 'delete*'
export-modulemember -function 'start*'