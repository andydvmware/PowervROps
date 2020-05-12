function Get-VropsToken {
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
		[parameter(Mandatory=$true)][string]$username,
		[parameter(Mandatory=$true)][string]$authSource,
		[parameter(Mandatory=$true)][string]$password
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
		Write-Verbose ("URL: " + $url)
		Try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
            $response = Invoke-RestMethod -Method 'POST' -Uri $url -Headers $restheaders -body $body -ErrorAction Stop
            
            write-verbose $response



            Remove-Variable -Name body
            Remove-Variable -Name url
            Remove-Variable -Name restheaders

			return $response.token
		}
		Catch {
         #   Write-Host ("ERROR: ") -ForegroundColor red -nonewline; Write-Host 'Token not generated' -ForegroundColor White;
            Write-Error 'Token not generated'

            Write-Host ("StatusCode: " + $_.Exception.Response.StatusCode.value__)
               
                    write-Host ("Exception: " + $_.Exception)
              
           
         #   Write-Host $_
            Write-Error $_
			Write-Host $response
			Write-Host $Error[0].Exception

		}		
	}
}
