#!/usr/bin/env bash

readme_count=$()

the_readme=`find . -iname 'readme.md' | sed 's|./||'`

if [ -f $the_readme ]; then
    readme_count=`git log --oneline $the_readme | wc -l`
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

character_count=`wc -m < $the_readme`

if [ -f $the_readme ]; then
    until [ $character_count -ne "" ]; do
    nano $the_readme
    done
fi
