#!/usr/bin/env bash

if [ ! "$1" ]; then
    echo "Pass --help for instructions."
    exit
fi

excludePaths=${@:2}

for excludePath in $excludePaths; do
    echo $excludePath
done

if [ "$1" == "--help" ]; then
cat << EOL
The first required argument must be the folder you wish to search.

If you want to exclude any files or directories from your search,
please pass them as additional parameters with the following syntax:

Directory:
    -d=*DIRNAME*
File:
    -f=*FILENAME*
EOL
    exit
fi

find "$1" -printf '%s %p\n' | sort -nr | head
