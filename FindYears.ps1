
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

$folders = @( Get-ChildItem | where { $_.PsIsContainer } | select -property Name)

$ie = new-object -com "InternetExplorer.Application"

#$ie.Visible = $true

$folders | foreach {
	$originalFolder = $_.Name
	$folder = $_.Name -replace "_", " "
	
	#$folder
	
	$matches = $folder -match '\([0-9]+\)'
	
	if ( $matches -eq $false ) {
	
		echo "Locating a release year for '$folder':..."
	
		$url = "http://www.imdb.com/search/title?title=$folder"
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
			if ( compareTitles $titles[$i] $folder ) {
				$title = $titles[$i]
				$date = $dates[$i]
				$matched = $date -match "[0-9]+"
				$date = $matches[0]
				echo "===> Found matching item '$title ($date)'"
				mv $originalFolder "$title ($date)"
			}
		}
		
		
	} else {
		echo "Title '$folder' already has a release year"
	}
}

$ie.Quit()
