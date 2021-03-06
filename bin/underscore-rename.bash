#!/bin/bash

SEDEXP='s/ /_/g'

while test $# -gt 0
do
    case "$1" in
        -r) echo -n "recursive;"
	    RECURSIVE=true
            ;;
        -e) echo -n "execute;"
            EXECUTE=true
	    ;;
        -h) echo -n "help;"
	    HELP=true
            ;;
        -s) echo -n "dash;"
            SEDEXP='s/ /-/g'
            ;;
        -d) echo -n "dirs;"
            DIRS=true
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo -n "ignoring $1;"
            ;;
    esac
    shift
done

echo ""

if [ "$HELP" == true ]; then
    echo -e "\nUsage: "`basename $0` "<options>"
    echo "Options:"
    echo "   -r recursive"
    echo "   -e execute, not only show"
    echo "   -s use dash '-' instead of underscore"
    echo "   -d rename also directories"
    echo -e "   -h help\n"
    echo "If no options are provided, it shows the directories and files that would be renamed."
    exit 0
fi

# Pretty ugly if/else block
if [ "$EXECUTE" == true ]
then
    if [ "$RECURSIVE" == true ]; then
        if [ "$DIRS" == true ]; then
            find -depth -name "* *" -type d | rename "$SEDEXP"
            echo "Recursively executed on directories:" $SEDEXP
        fi
        echo "Recursively executed on files:" $SEDEXP
	find -depth -name "* *" -type f | rename "$SEDEXP"
    else
        if [ "$DIRS" == true ]; then
            find -maxdepth 1 -name "* *" -type d | rename "$SEDEXP"
            echo "Executed on directories:" $SEDEXP
        fi
        echo "Execute on files:" $SEDEXP
	find -maxdepth 1 -name "* *" -type f | rename "$SEDEXP"
    fi
else
    if [ "$RECURSIVE" == true ]; then
	find -depth -name "* *" -type f
        if [ "$DIRS" == true ]; then
            find -depth -name "* *" -type d
        fi
    else
	find -maxdepth 1 -name "* *" -type f
        if [ "$DIRS" == true ]; then
            find -maxdepth 1 -name "* *" -type d
        fi
    fi
fi
