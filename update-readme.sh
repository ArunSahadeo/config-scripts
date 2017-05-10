#!/usr/bin/env bash

readme_count=$()

the_readme=`find . -iname 'readme.md' | sed 's|./||'`

if [ -f "$the_readme" ]; then
    readme_count=`git log --oneline "$the_readme" | wc -l`
else
    echo "There is not a README in this directory"
    return
fi

if [ "$readme_count" -gt 1 ]; then
    echo "Your README is up to date"
    exit
fi

echo "You need to update your README"

sleep 2


which_os=`uname | tr '[A-Z]' '[a-z]'`

if [ "$which_os" == "darwin" ]; then
    character_count=$(stat -f '%s' "$the_readme")
        while (($(stat -f '%s' "$the_readme") == "$character_count" )); do
            $EDITOR "$the_readme"
        done
else
    character_count=$(stat -c '%s' "$the_readme")
        while (($(stat -c '%s' "$the_readme") == "$character_count" )); do
            $EDITOR "$the_readme"
        done
fi
