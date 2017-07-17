#!/bin/bash -ex
#
# Copyright 2017 Jacek Kurasiewicz
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

# Requires the following command with specific mount points:
# docker run --rm -v /opt/bin:/opt/bin adelaar/coreos-essentials-installer install-git.sh

# Make script gives up on any error
set -e

COMMAND="git"
FULL_COMMAND="/opt/bin/git"

mountpoint /opt/bin; printf "$?\n"

if [ -f $FULL_COMMAND ]; then
    echo "git seems to be installed. Uninstall first!"
    echo "Nothing to do. Quiting git installer..."
    exit 1
fi

apt-get update
apt-get -y build-dep git
apt-get install -y libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev

# Clone mc repo if hasn't been cloned before and change to it
if [ ! -d ./git ]; then
    git clone https://github.com/git/git.git
fi
cd git

# Get lastest stable or RC version, but you can change to any valid branch/tag/commit id
BRANCH=$(git describe --abbrev=0 --tags)
# Go to desired branch
git checkout $BRANCH

make prefix=${FULL_COMMAND}-bin all
make prefix=${FULL_COMMAND}-bin install

# Copy the dependencies
cpld ${FULL_COMMAND}-bin/bin/${COMMAND} /opt/bin/${COMMAND}-bin/libs
cp /usr/lib/x86_64-linux-gnu/libcurl-gnutls.so.4 /opt/bin/${COMMAND}-bin/libs
chmod +x /opt/bin/${COMMAND}-bin/libs/*

echo "Creating an executable script /opt/bin/$COMMAND"
cat <<EOT >> /opt/bin/${COMMAND}
#!/bin/bash 

LD_LIBRARY_PATH="/opt/bin/${COMMAND}-bin/libs" /opt/bin/${COMMAND}-bin/bin/${COMMAND} "\$@"
EOT

chmod +x /opt/bin/${COMMAND}

rm -Rf ./git

echo "$COMMAND has been succesfully installed ;)"