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

which_os=`uname | tr 'A-Z' 'a-z'`

the_readme=`find . -maxdepth 1 -iname 'readme.md' | sed 's|./||'`

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
        project_url=`cat .env | grep APP_URL | tr 'APP_URL=' ' ' | xargs`
        vagrant_status='vagrant status'
        $vagrant_status > vagrant-status.txt
        vagrant_up='vagrant up'
        if grep -Fqi "poweroff" vagrant-status.txt; then
            rm vagrant-status.txt
            $vagrant_up
        else
            :
        fi
        http_code=$(HEAD "$project_url" | head -1 | cut -d ' ' -f 1)
        if [ $http_code -eq 500 ] ; then
            echo "Your Laravel site isn't working locally"
            if [ "$which_os" == "darwin" ]; then
                read $laravel_site
                osascript -e 'tell application "Terminal" to do script "bash -c 'cd "$laravel_site" && vagrant ssh > /dev/null 2>&1 &'"'
            else             
                gnome-terminal -e "bash -c 'vagrant ssh; exec bash'"
            fi
            homestead_address=`echo $project_url | cut -f3 -d '/'`
            while [ $(HEAD "$project_url" | head -1 | cut -d ' ' -f 1) -eq 500 ]; do
            	case $http_code in
            		200)
						read -p "Press [Enter] once you've run history > history.txt in the Vagrant machine" < /dev/tty
						$(scp -P 22 vagrant@"$homestead_address":~/history.txt) ;;
					500)
						: ;;
				esac
			done
        else
            :
	fi
		
		until [ -f "history.txt" ]; do
			echo "File history.txt has not been downloaded yet"
		done

        if [ -f "history.txt" ] && [ $http_code -eq 200 ]; then
                recent_commands="awk '{$1=""; print $0}' history.txt | tail -n5 > vagrant_history.txt"
                $recent_commands
                commandArray "vagrant_history.txt"
                number=0;
                dot=". "
                for command in "${shell_commands[@]}"; do
                    $number++
                    echo "$number$dot$command" >> "$the_readme"
                done
        else
            :
        fi
    fi
elif [ ! -z $laravel_project ] &&  [ ! -z $has_vagrant ] &&  [ $laravel_project == "True" ] && [ $has_vagrant == "No" ]; then
    if [ -f ".env" ]; then
        php artisan serve
        http_code=$(HEAD http://localhost:8000 | head -1 | cut -d ' ' -f 1)
        if [ $http_code -eq 500 ]; then
            echo "Your Laravel site isn't working locally"
            while [ $(HEAD "$project_url" | head -1 | cut -d ' ' -f 1) -eq 500 ]; do
                read command
                shell_commands=("${shell_commands[@]}" $command)
                for command in "${shell_commands[@]}"; do
                    $command
                done
            done
        fi
        if [ "$shell_commands" ]; then
                number=0
                dot=". "
                for command in "${shell_commands[@]}"; do
                    $number++
                    echo "$number$dot$command" >> "$the_readme"
                done
        fi
    fi
elif [ ! -z $wordpress_project ] && [ $wordpress_project == "True" ]; then

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
rm history.txt
rm vagrant_history.txt
git status
