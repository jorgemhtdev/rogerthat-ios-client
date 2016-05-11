#!/bin/bash

set -u
set -e

cp .RogerthatConfig.plist.start MCResources/RogerthatConfig.plist

[ ! -e .git/info/attributes ] && echo "*.strings diff=localizablestrings" > .git/info/attributes;

exit 0
