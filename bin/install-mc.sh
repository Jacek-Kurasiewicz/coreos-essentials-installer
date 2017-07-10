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
# docker run --rm -v /opt/bin:/opt/bin adelaar/coreos-ubuntu-toolbox install-mc.sh

# Make script gives up on any error
set -e

echo "Verifying required mountpoints:"
mountpoint /opt/bin

COMMAND="mc"
FULL_COMMAND="/opt/bin/mc"

# 
if [ -f $FULL_COMMAND ]; then
    echo "mc seems to be installed. Uninstall first!"
    echo "Nothing to do. Quiting mc installer..."
    exit 1
fi

apt-get update
apt-get -y build-dep mc
apt-get -y install autopoint autogen autoconf libtool gettext 

# Clone zsh repo if hasn't been cloned before and change to it
if [ ! -d ./mc ]; then
    git clone https://github.com/MidnightCommander/mc.git mc
fi
cd mc

# Get lastest stable version, but you can change to any valid branch/tag/commit id
BRANCH=$(git describe --abbrev=0 --tags)
# Get version number, and revision/commit id when this is available
ZSH_VERSION=$(echo $BRANCH | cut -d '-' -f2,3,4)
# Go to desired branch
git checkout $BRANCH

./autogen.sh
./configure \
	--bindir=${FULL_COMMAND}-bin/ \
	--prefix=${FULL_COMMAND}-bin/ \
	--exec-prefix=${FULL_COMMAND}-bin/ \
	--without-x --disable-shared --enable-static

make
make install

# Copy the dependencies
cpld ${FULL_COMMAND}-bin/${COMMAND} ${FULL_COMMAND}-bin/libs

echo "Creating an executable script /opt/bin/mc"
cat <<EOT >> /opt/bin/mc
#!/bin/sh 

LD_LIBRARY_PATH="/opt/bin/mc-bin/libs" MC_HOME=\$HOME exec /opt/bin/mc-bin/mc "\$@"
EOT

chmod +x /opt/bin/mc

# Clean up the temporary source directory
rm -Rf ./mc

echo "mc has been succesfully installed ;)"