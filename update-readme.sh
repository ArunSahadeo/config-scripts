#!/usr/bin/env bash

readme_count=$()

if [ -f readme.md ]; then
    readme_count=`git log --oneline readme.md | wc -l`
elif [ -f README.MD]; then
    readme_count=`git log --oneline README.MD | wc -l`
elif [ -f README.md]; then
    readme_count=`git log --oneline README.md | wc -l`
else
    echo "There is not a README in this directory"
    return
fi

if [ $readme_count -gt 1 ]; then
    exit
fi

echo "You need to update your README"

sleep 2

if [ -f readme.md ]; then
    line_count=`wc -l readme.md`
    original_line_count=$line_count
    until [ $line_count != $original_line_count ]; do
        nano readme.md
    done
elif [ -f README.MD]; then
    line_count=`wc -l README`
    nano README.MD
elif [ -f README.md]; then
    line_count=`wc -l README.md`
    nano README.md
fi
