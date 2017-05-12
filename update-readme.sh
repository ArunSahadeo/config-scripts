#!/usr/bin/env bash

getArray() {
    commands=() # Create array
    while IFS= read -r line # Read a line
    do
        commands+=("$line") # Append line to the array
    done < "$1"
}

has_duplicates()
{
  {
    sort | uniq -d | grep . -qc
  } < "$1"
}

readme_count=$()

the_readme=`find . -iname -maxdepth 1 'readme.md' | sed 's|./||'`

if [ -f "$the_readme" ]; then
    readme_count=`git log --oneline "$the_readme" | wc -l`
else
    echo "There is not a README in this directory"
    exit
fi

if [ "$readme_count" -gt 1 ]; then
    echo "Your README is up to date"
    exit
fi

available_commands=$(compgen -ac)

touch commands.txt

echo "$available_commands" > commands.txt

getArray "commands.txt"

touch results.txt

for command in "${commands[@]}"; do

    if grep -qx ":\|!\|.\|[\|]|\{\|}" "$command" 2>/dev/null; then
        continue
    else
        :
    fi

    if ! grep -Fxq "$command" "$the_readme"; then
        echo "Command not found" >> results.txt
    fi 
done

if ! has_duplicates results.txt; then
  exit
fi

echo "You need to update your README"

rm commands.txt && rm results.txt

sleep 2

which_os=`uname | tr '[A-Z]' '[a-z]'`

if [ "$which_os" == "darwin" ]; then
    character_count=`wc -m < "$the_readme"`
    while (($(wc -m < "$the_readme") == "$character_count" )); do
        open -e "$the_readme"
    done
else
    character_count=$(stat -c '%s' "$the_readme")
     while (($(stat -c '%s' "$the_readme") == "$character_count" )); do
        $EDITOR "$the_readme"
    done
fi

git status