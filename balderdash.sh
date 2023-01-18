#!/bin/bash

function PARSE_OPTS() {
  while getopts "f::w::d::c::s" opt; do
    case $opt in
      f)
        FILE=$OPTARG
        ;;
      w) 
        WORDS_FILE=$OPTARG
        ;;
      c)  
        CONFIG_FILE=$OPTARG
      ;;
      d)
        DIR=$OPTARG
        ;;
      s)
        STRICT=true
        ;;
      \?) echo "Invalid option -$OPTARG" && exit 1
      ;;
    esac
  done
}

function PARSE_CONFIG() {
  [ -z $CONFIG_FILE ] && CONFIG_FILE="$HOME/.config/balderdash/balderdash.conf"
  if [[ ! -f $CONFIG_FILE ]]; then
    echo "No config file found.";
    exit 1;
  fi
  source $CONFIG_FILE

  [ -z $WORDS_FILE ] && WORDS_FILE=$DEFAULT_WORDS_FILE
  if [[ ! -f $WORDS_FILE ]]; then
    echo "No words file found.";
    exit 1;
  fi
  
  [ -z $DIR ] && DIR=$DEFAULT_DIR
  if [[ ! -d $DIR ]]; then
    echo "No directory found.";
    exit 1;
  fi

  if [[ ! -z $FILE ]] && [[ ! -f $FILE ]]; then
    echo "No file found.";
    exit 1;
  fi
}

function DOWNLOAD_FILE() {
  local var WORDS_URL="https://raw.githubusercontent.com/CaffeineDuck/Balderdash/main/parsed/"
  local var BDSH_DIR=/tmp/bladerdash-words
  [ -d $BDSH_DIR ] || mkdir $BDSH_DIR

  [ -z $1 ] && echo No file specified && exit 1;
  [ -z $2 ] && echo No languages specified && expt 1;
  local var FILE=$1
  local var LANGS=$2

  for lang in $LANGS; do
    curl -sL $WORDS_URL/$lang > "$BDSH_DIR/$lang"
    echo "Downloaded words list for $lang"
  done

  # Clearing the file which may contain previous words
  rm -f $FILE
  
  # Merging the words files into one
  for lang in $LANGS; do
    echo "Parsing $lang"
    cat $BDSH_DIR/$lang >> $FILE
  done

  # TODO: Custom user words
  # Adding user's custom words to the list
  # []
  # [ -f $3 ] && echo "Adding custom words to the list" && cat $3 >> $FILE;

  sed -i ':a;N;$!ba;s/\n/|/g' $1
  echo "Merged all the files into $1"
}

# Actual CLI
case $1 in
  init|i)
    DIR=$HOME/.config/balderdash
    [ -d $DIR ] && echo "Config directory already exists" && exit 1;
    mkdir -p $DIR

    FILE=$DIR/balderdash.conf
    [ -f $FILE ] && echo "Config file already exists" && exit 1;
    touch $FILE

    echo "Creating config file..."
    echo "DEFAULT_DIR=./" >> $FILE
    echo "DEFAULT_WORDS_FILE=$DIR/words.txt" >> $FILE
    echo "LANGUAGES=(en)" >> $FILE

    DEFAULT_LANGS=(en)
    DOWNLOAD_FILE $DIR/words.txt $DEFAULT_LANGS
    ;;

  download|dw)
    PARSE_CONFIG
    source $CONFIG_FILE
    DOWNLOAD_FILE $WORDS_FILE $LANGUAGES
    ;;

  check|c)
    PARSE_OPTS $2 $3 $4 $5 $6 $7 $8 $9
    PARSE_CONFIG
    echo "Running the check..."

    PROFS=`cat $WORDS_FILE`

    # For single file
    if [[ ! -z $FILE ]] && [[ -f $FILE ]]; then
      echo -e "\nChecking $FILE for profanity:"
      grep -Ewin --color=always "($PROFS)" $FILE
      echo "Check Completed."
      exit 1
    fi

    # For a dir
    for file in $(find $DIR -follow); do
      [ -d $file ] && continue
      grep -Eqw "($PROFS)" $file || continue

      echo -e "\nFound profanity in $file:"
      cat $file | grep -Ewin --color=always "($PROFS)"
      [ $STRICT ] && exit 1
    done

    echo "Check Completed."
    ;;

  *|help|h)
    echo "Balderdash is a tool to find profanity in files"
    echo "Usage: balderdash [options] [command]"
    echo "Commands:"
    echo "  init|i: Initialize the config file"
    echo "  help|h: Display this help message"
    echo "  check|c: Check a file/dir for profanity"
    echo "  download|dw: Download the profanity list according to language selection"
    echo "Options:"
    echo "  -f [FILE]: Specify a file to check"
    echo "  -c [FILE]: Specify a config file"
    echo "  -d [DIR]: Specify a directory to check"
    echo "  -w [FILE]: Specify a file containing profanity words list"
    echo "  -s: Strict mode. Exit with error code 1 if profanity is found"
    ;;

esac
