#!/usr/bin/env bash

read -r -d '' html_output <<ENDHTML
<!DOCTYPE HTML>
 <html lang="en">
 <head>
   <meta charset="utf-8">
   <meta http-equiv="x-ua-compatible" content="ie=edge">
   <title></title>
   <meta name="description" content="">
   <meta name="viewport" content="width=device-width, initial-scale=1">
   </head>
   <body>
   
   </body>
</html>
ENDHTML

if [ -f ./index.html ]; then
	if [ $(wc -l <index.html) -gt 0 ] ; then
	  :
  	fi
else
 	echo $html_output > index.html
fi
  
