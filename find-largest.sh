#!/usr/bin/env bash

if [ ! "$1" ]; then
    echo "Pass --help for instructions."
    exit
fi

if [ "$1" == "--help" ]; then
    echo "The first required argument must be the folder you wish to search."
    exit
fi

find "$1" -printf '%s %p\n' | sort -nr | head
