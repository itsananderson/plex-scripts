#
# Traverses the current directory, assuming child directories are movie folders.
# Files with the .mkv extension inside those folders are renamed be the same as their parent folder
# Multiple mkv files are named "Blabla-1.mkv" "Blabla-2.mkv" etc.
#
# TODOs:
# 1) Verify that multiple vidoes in a folder are given the right order, perhaps ask for user input
# 2) Handle the existance of more than 9 movies more gracefully (include leading zeros in title numbers when needed)
#

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