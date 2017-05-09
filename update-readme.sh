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
    echo "Your README is up to date"
    exit
fi

echo "You need to update your README"

sleep 2

the_readme=`find . -iname 'readme.md' | sed 's|./||'`

character_count=`wc -m < $the_readme`

if [ -f $the_readme ]; then
    until [ $character_count -ne "" ]; do
    nano $the_readme
    done
fi
