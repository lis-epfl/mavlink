#!/bin/bash

# Do only build for Python 2.7
# as we only want to deploy for one
# unique generator.
PYTHONVER=`python -c 'import sys; print(".".join(map(str, sys.version_info[:3])))'`

if [[ $PYTHONVER != "2.7"* ]]
then
	echo -e "Skipping header generation for Python $PYTHONVER"
	exit 0
fi

# Do not build pull requests
if [[ $TRAVIS_PULL_REQUEST != "false" ]]
then
	echo -e "Skipping build for pull requests"
	exit 0
fi

# Do only build master branch
if [[ $TRAVIS_BRANCH != "mavric" ]]
then
echo -e "Skipping build for branch different from mavric"
	exit 0
fi

# Config for auto-building
git remote rename origin upstream
git config --global user.email "bot@mavric.org"
git config --global user.name "MavricBot"
git config --global credential.helper "store --file=$HOME/.git-credentials"
echo "https://${GH_TOKEN}:@github.com" > $HOME/.git-credentials

# Build C library
mkdir -p include/mavlink/v1.0
cd include/mavlink/v1.0
git clone https://github.com/lis-epfl/mavlink_headers.git
cd ../../..
./scripts/update_c_library.sh

# XXX add build steps for other libraries as well
