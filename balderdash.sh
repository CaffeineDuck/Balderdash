#!/bin/bash

# This is a profanity filter CLI
# It will take the directory as a parameter and filter out the profanity

# This is the directory that will be filtered
DIR=$1
if [ -z $DIR ]; then
  echo "Please provide a directory to filter"
  exit 1
fi

# Defining the list of profanity
PROFS_FILE="/tmp/profanity_list.txt"
if [ -f $PROFS_FILE ]; then
  echo Using exiting $PROFS_FILE
  PROFS=cat $PROFS_FILE
else
  echo Writing the profanity list to $PROFS_FILE
  PARSED_LIST=$(curl -Ls https://raw.githubusercontent.com/chucknorris-io/swear-words/master/en | sed ':a;N;$!ba;s/\n/|/g')
  echo $PARSED_LIST > $PROFS_FILE
fi

# This will find all the profanity in the current directory
#
# Example: 
# ```bash
# find_profanity_in_files() "$DIR" "$PROFS";
# ```
#
# Output:
# ```
# "Profanity found in file.txt"
# 1: This is a line with red[profanity]
# ```
function find_profanity_in_files() {
  echo Running the profanity filter in $1
  for file in $(find $1 -follow); do
    echo Searching for profanity in $file ...
    cat $file | grep -Ewn --color=always "($PROFS)"
  done
}

# This is the main entrypoint for the script
find_profanity_in_files $DIR $PROFS
