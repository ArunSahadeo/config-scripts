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

available_commands=$(compgen -ac)

touch commands.txt

echo "$available_commands" > commands.txt

getArray() {
    commands=() # Create array
    while IFS= read -r line # Read a line
    do
        commands+=("$line") # Append line to the array
    done < "$1"
}

getArray "commands.txt"

for command in "${commands[@]}"; do

    if grep -qx ":" "$command" 2>/dev/null; then
        continue
    elif grep -qx "!" "$command" 2>/dev/null; then
        continue
    elif grep -qx "." "$command" 2>/dev/null; then
        continue
    elif grep -qx "[" "$command" 2>/dev/null; then
        continue
    elif grep -qx "]" "$command" 2>/dev/null; then
        continue
    elif grep -qx "{" "$command" 2>/dev/null; then
        continue
    elif grep -qx "}" "$command" 2>/dev/null; then
        continue
    else
        :
    fi

    if ! grep -Fxq "$command" "$the_readme"; then
        touch results.txt
        echo "Command not found" >> results.txt
    fi 
done

has_duplicates()
{
  {
    sort | uniq -d | grep . -qc
  } < "$1"
}

if ! has_duplicates results.txt; then
  exit
fi

echo "You need to update your README"

rm commands.txt && rm results.txt

sleep 2

if [ -d wp-admin ] || [ -d wp-includes ]; then
    wordpress_project="True"
elif [ -d storage ] || [ -d public ]; then
    if [ ! -f Vagrantfile ]; then
        echo "This Laravel project does not have a Vagrantfile"
    fi
    laravel_project="True"
fi

if [ $laravel_project ]; then
    if [ -f ".env" ]; then
        project_url=`cat .env | grep -i APP_URL | tr 'APP_URL=' ' ' | xargs`
        http_code=`curl -o /dev/null --silent -m 20 --head --write-out '%{http_code}\n' "$project_url"`
    fi
fi  

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