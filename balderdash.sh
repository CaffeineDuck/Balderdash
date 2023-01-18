#!/bin/bash

function PARSE_OPTS() {
  while getopts "f::w::d::c::" opt; do
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
    echo "Words file not valid.";
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

  CUSTOM_WHITELIST=${DEFAULT_WHITELIST[@]}
  CUSTOM_BLACKLIST=${DEFAULT_BLACKLIST[@]}
}

function DOWNLOAD_FILE() {
  local var WORDS_URL="https://raw.githubusercontent.com/CaffeineDuck/Balderdash/main/parsed/"
  local var BDSH_DIR=/tmp/bladerdash-words
  [ -d $BDSH_DIR ] || mkdir $BDSH_DIR
  [ -z $1 ] && echo No file specified && exit 1;
  local var FILE=$1

  for lang in ${LANGUAGES[@]}; do
    curl -sfL $WORDS_URL/$lang > "$BDSH_DIR/$lang"
    echo "Downloaded words list for $lang"
  done

  # Clearing the file which may contain previous words
  rm -f $FILE
  
  # Merging the words files into one
  for lang in ${LANGUAGES[@]}; do
    echo "Parsing $lang"
    cat $BDSH_DIR/$lang >> $FILE
  done

  # Add custom blacklisted words
  for word in ${CUSTOM_BLACKLIST[@]}; do
    echo $word
    echo $word >> $FILE
  done
  echo Added custom blacklisted words to $FILE

  # Remove custom whitelisted words
  for word in ${CUSTOM_WHITELIST[@]}; do
    sed -i "/$word/d" $FILE
  done
  echo Removed custom whitelisted words from $FILE

  sed -i ':a;N;$!ba;s/\n/|/g' $FILE
  echo "Merged all the files into $FILE"
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
    echo "DEFAULT_WHITELIST=()" >> $FILE
    echo "DEFAULT_BLACKLIST=()" >> $FILE

    LANGUAGES=(en)
    CUSTOM_WHITELIST=()
    CUSTOM_BLACKLIST=()
    DOWNLOAD_FILE $DIR/words.txt
    ;;

  download|dw)
    PARSE_OPTS $2 $3 $4 $5 $6 $7 $8 $9
    PARSE_CONFIG
    DOWNLOAD_FILE $WORDS_FILE
    ;;

  check|c)
    PARSE_OPTS $2 $3 $4 $5 $6 $7 $8 $9
    PARSE_CONFIG
    echo "Running the check..."

    PROFS=`cat $WORDS_FILE`

    # For single file
    if [[ ! -z $FILE ]] && [[ -f $FILE ]]; then
      ag -fw "($PROFS)" $FILE
      echo "Done checking $FILE"
      if [[ $? -eq 0 ]]; then
        echo "Found profanity in $FILE"
        exit 1
      else
        echo "No profanity found in $FILE"
        exit 0
      fi
    fi

    # For a dir
    ag -fw "($PROFS)" $DIR

    if [[ $? -eq 0 ]]; then
      echo "Found profanity in $DIR"
      exit 1
    else
      echo "No profanity found in $DIR"
      exit 0
    fi
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
    ;;

esac
