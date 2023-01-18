#!/bin/bash

# This is the installation script for balderdash
curl -L https://raw.githubusercontent.com/CaffeineDuck/Balderdash/main/balderdash.sh > /tmp/balderdash;
sudo chmod +x /tmp/balderdash;
sudo mv /tmp/balderdash /bin/balderdash;

