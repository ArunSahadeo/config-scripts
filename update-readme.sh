#!/usr/bin/env bash

getArray() {
    commands=() # Create array
    while IFS= read -r line # Read a line
    do
        commands+=("$line") # Append line to the array
    done < "$1"
}

commandArray() {
    shell_commands=() # Create array
    while IFS= read -r shell_command # Read a line
    do
        shell_commands+=("$shell_command") # Append line to the array
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

if [ -d wp-admin ] || [ -d wp-includes ]; then
    wordpress_project="True"
elif [ -d storage ] || [ -d public ]; then
    if [ ! -f Vagrantfile ]; then
        echo "This Laravel project does not have a Vagrantfile"
        laravel_project="True"
        has_vagrant="No"
    fi
    laravel_project="True"
    has_vagrant="Yes"
else
    :
fi

if [ ! -z $laravel_project ] && [ ! -z $has_vagrant ] && [ $laravel_project == "True" ] && [ $has_vagrant == "Yes" ]; then
    if [ -f ".env" ]; then
        project_url=`cat .env | grep -i APP_URL | tr 'APP_URL=' ' ' | xargs`
        vagrant_status=`vagrant status`
        if grep -Fxq "poweroff" "$vagrant_status"; then
            vagrant up
        fi
        http_code=$(curl --write-out %{http_code} --silent --output /dev/null "$project_url")
        if $http_code != 200; then
            echo "Your Laravel site isn't working locally"
            while ( $(curl --write-out %{http_code} --silent --output /dev/null "$project_url") != 200 ); do
                read "$command"
                commandArray "$command"
                for command in "${!shell_commands[@]}"; do
                    eval "$command"
                done
            done
        else
            :
        fi
        if [ ! -z "$shell_commands" ]; then
                number=0;
                dot=". "
                for command in "${!shell_commands[@]}"; do
                    $number++
                    echo "$number$dot$command" >> "$the_readme"
                done
        else
            :
        fi
    fi
elif [ ! -z $laravel_project ] &&  [ ! -z $has_vagrant ] &&  [ $laravel_project == "True" ] && [ $has_vagrant == "No" ]; then
    if [ -f ".env" ]; then
        project_url=`cat .env | grep -i APP_URL | tr 'APP_URL=' ' ' | xargs`
        php artisan serve
        http_code=$(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8000)
        if $http_code != 200; then
            echo "Your Laravel site isn't working locally"
            while ( $(curl --write-out %{http_code} --silent --output /dev/null http://localhost:8000) != 200 ); do
                read "$command"
                commandArray "$command"
                for command in "${!shell_commands[@]}"; do
                    eval "$command"
                done
            done
        fi
        if [ ! -z "$shell_commands" ]; then
                number=0;
                dot=". "
                for command in "${!shell_commands[@]}"; do
                    $number++
                    echo "$number$dot$command" >> "$the_readme"
                done
        fi
    fi
elif [ ! -z $wordpress_project ] && [ $wordpress_project == "True" ]; then
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
else
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
fi

git status