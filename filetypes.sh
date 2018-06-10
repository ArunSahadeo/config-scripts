#!/usr/bin/env bash

allFiles=$(find . -type f)
ignoreFolders=(".git" "node_modules" "vendor")
uniqueExtensions=()

inArray()
{
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}

for allFile in $allFiles; do
	for ignoreFolder in "${ignoreFolders[@]}"; do
		if [[ $allFile =~ "$ignoreFolder" ]]; then
			continue 2
		fi
	done

	file=`basename $allFile`
	extension=$(basename $file | cut -f2 -d ".")

	if inArray "$extension" "${uniqueExtensions[@]}"; then
		continue	
	fi

	uniqueExtensions+=("$extension")
done

IFS=$'\n'
uniqueExtensions=($(sort <<<"${uniqueExtensions[*]}"))
unset IFS

for uniqueExtension in "${uniqueExtensions[@]}"; do
    echo $uniqueExtension
done
