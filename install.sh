#!/bin/bash

# This is the installation script for balderdash
curl -sL https://raw.githubusercontent.com/CaffeineDuck/Balderdash/main/balderdash.sh > /tmp/balderdash;
sudo install /tmp/balderdash /bin/balderdash;

echo "Balderdash installed successfully.";
echo "Run 'balderdash -h' for help.";
echo "Run 'balderdash init' to initialize balderdash."

