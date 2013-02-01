#
# Traverse the current directory and parse folders as film names
# Look up the film name on IMDB and hopefully figure out the year it was released
#
# TODOs:
# 1) Find a more reliable query to run on IMDB (or another service)
# 2) Replace the (sluggish) IE api calls with a more direct approach
# 3) Add more error detection etc.
#

function compareTitles($first, $second) {
	$first = [regex]::replace($first, "[\W]", "").toLower()
	$second = [regex]::replace($second, "[\W]", "").toLower()
	
	return $first -eq $second
}

function getElementsByClassName($node, $class) {
	return [System.__ComObject].InvokeMember("getElementsByClassName", [System.Reflection.BindingFlags]::InvokeMethod, $null, $node, $class)
}

function getElementsByTagName($node, $tag) {
	return [System.__ComObject].InvokeMember("getElementsByTagName", [System.Reflection.BindingFlags]::InvokeMethod, $null, $node, $tag)
}

$ie = new-object -com "InternetExplorer.Application"

# For debugging, to watch what's happening
#$ie.Visible = $true

$folders = @( Get-ChildItem | where { $_.PsIsContainer } | select -property Name)

$folders | foreach {
	$folder = $_.Name
	$title = $folder -replace "_", " "
	$title = $title -replace "-", " "
	
	$matches = $title -match '\([0-9]+\)'
	
	if ( $matches -eq $false ) {
	
		echo "Locating a release year for '$title':..."
	
		# TODO: use http://www.imdb.com/find?q=<film-title>&s=titles instead
		$url = "http://www.imdb.com/search/title?title=$title"
		$ie.Navigate($url)
		
		#$url
		
		while( $ie.busy ) {
			Sleep 1
		}
	
		$doc = $ie.Document
	
		$dates = @(getElementsByClassName $doc  "year_type" | foreach {$_.textContent} )
		$titles = @(getElementsByClassName $doc "title" | foreach { @(getElementsByTagName $_ "a")[1].textContent })
		
		#$dates
		#$titles
		
		for ( $i = 0; $i -lt $dates.count -and $i -lt $titles.count; $i++) {
			if ( compareTitles $titles[$i] $title ) {
				$date = $dates[$i]
				$matched = $date -match "[0-9]+"
				$date = $matches[0]
				echo "===> Found matching item '$title ($date)'"
				mv $folder "$title ($date)"
			}
		}
		
		
	} else {
		echo "Title '$title' already has a release year"
	}
}

$ie.Quit()
