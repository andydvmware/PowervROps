Function LoadCredentials {
Try {
	$pwdTxt = Get-Content 'c:\ExportedPassword.txt'
}
Catch {

}
Try {
	$AESKey = Get-Content 'c:\temp\aes.key'
}
Catch {
}
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey # Convert the password to a secure string using the password file and the keyfile
Try {
	$vropscreds = New-Object System.Management.Automation.PSCredential -ArgumentList 'admin', $securePwd
}
Catch {}
return $vropscreds
}