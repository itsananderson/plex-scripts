$folders = @( Get-ChildItem | where { $_.PsIsContainer } | select -property Name)

$folders | foreach {
	$folder = $_.Name
	echo "Checking folder $folder"
	$movies = @( Get-ChildItem $folder -Filter *.mkv | select -property Name )
	if ( $movies.count -eq 1 ) {
		$movie = $movies[0].Name
		$sourcePath = "$folder/$movie"
		$destPath = "$folder/$folder.mkv"
		if ( $sourcePath -ne $destPath ) {
			echo "--> Moving $sourcePath to $destPath"
			mv $sourcePath $destPath
		}
	} else {
		$i = 1;
		$movies | foreach {
			$movie = $_.Name
			$sourcePath = "$folder/$movie"
			$destPath = "$folder/$folder-$i.mkv"
			if ( $sourcePath -ne $destpath ) {
				echo "--> Moving $sourcePath to $destPath"
				mv $sourcePath $destPath
			}
			$i += 1
		}
	}
}