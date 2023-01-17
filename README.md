# Balderdash [WIP]

Balderdash is a profanity checker tool for your codebase. It was created to that you
won't have to worry about mistakenly commiting curse words or some not-so-appropriate
words to your main branch.

It's a simple shell script and can run on almost any Unix system. It was created in
shell due to how simple it was to write it. I have no plans of moving it to other
languages and adding more graphic features.

## Usage

You can simply copy the script and add it to your /bin dir with the name of your
choice. I'll add a better way of using it locally soon enough, I'm planning to create
a pre-commit hook for this as well.

```bash
Balderdash is a tool to find profanity in files

Usage: balderdash [command] [options]

Commands:
  init|i: Initialize the config file
  help|h: Display this help message
  check|c: Check a file/dir for profanity
  download|dw: Download the profanity list according to language selection

Options:
  -f: Specify a file to check
  -c: Specify a config file
  -d: Specify a directory to check
  -w: Specify a file containing profanity words list
```
