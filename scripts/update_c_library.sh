#!/bin/bash

# c_library repository update script
# Author: Thomas Gubler <thomasgubler@gmail.com>
#
# This script can be used together with a github webhook to automatically
# generate new c header files and push to the c_library repository whenever
# the message specifications are updated.
# The script assumes that the git repositories in MAVLINK_GIT_PATH and
# CLIBRARY_GIT_PATH are set up prior to invoking the script.
#
# Usage, for example:
# cd ~/src
# git clone git@github.com:mavlink/mavlink.git
# cd mavlink
# git remote rename origin upstream
# mkdir -p include/mavlink/v1.0
# cd include/mavlink/v1.0
# git clone git@github.com:mavlink/c_library.git
# cd ~/src/mavlink
# ./scripts/update_c_library.sh
#
# A one-liner for the TMP directory (e.g. for crontab)
# cd /tmp; git clone git@github.com:mavlink/mavlink.git &> /dev/null; \
# cd /tmp/mavlink && git remote rename origin upstream &> /dev/null; \
# mkdir -p include/mavlink/v1.0 && cd include/mavlink/v1.0 && git clone git@github.com:mavlink/c_library.git &> /dev/null; \
# cd /tmp/mavlink && ./scripts/update_c_library.sh &> /dev/null

function generate_headers() {
python pymavlink/tools/mavgen.py \
    --output $CLIBRARY_PATH \
    --lang C \
    message_definitions/v1.0/$1.xml
}

# settings
MAVLINK_PATH=$PWD
CLIBRARY_PATH=$MAVLINK_PATH/include/mavlink/v1.0/mavlink_headers
CLIBRARY_GIT_REMOTENAME=origin
CLIBRARY_GIT_BRANCHNAME=master

# save git hash
MAVLINK_GITHASH=$(git rev-parse HEAD)

# delete old c headers
rm -rf $CLIBRARY_PATH/*

# generate new c headers
echo -e "\0033[34mStarting to generate c headers\0033[0m\n"
generate_headers mavric
generate_headers common
mkdir -p $CLIBRARY_PATH/message_definitions
cp message_definitions/v1.0/* $CLIBRARY_PATH/message_definitions/.
echo -e "\0033[34mFinished generating c headers\0033[0m\n"

# git add and git commit in local c_library repository
cd $CLIBRARY_PATH
git add --all :/ || exit 1
COMMIT_MESSAGE="autogenerated headers for rev https://github.com/lis-epfl/mavlink/tree/"$MAVLINK_GITHASH
git commit -m "$COMMIT_MESSAGE" || exit 1

# push to c_library repository
git push $CLIBRARY_GIT_REMOTENAME $CLIBRARY_GIT_BRANCHNAME || exit 1
echo -e "\0033[34mHeaders updated and pushed successfully\0033[0m"
