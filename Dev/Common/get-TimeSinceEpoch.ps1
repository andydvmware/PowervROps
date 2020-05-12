function get-TimeSinceEpoch {
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
		if (!$date) {
			$referencetime = ((get-date).AddHours($hourstoadd)).ToUniversalTime()
		}
		else {
			$referencetime = $date.ToUniversalTime()
		}
		$timesinceepoch = [math]::floor(($referencetime - $epoch).TotalMilliseconds)
		return $timesinceepoch	
	}
}