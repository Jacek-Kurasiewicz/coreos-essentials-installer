#!/bin/bash
# Build Zsh from sources on Ubuntu.
# From http://zsh.sourceforge.net/Arc/git.html and sources INSTALL file.
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
# docker run --rm -v /etc:/mnt/etc -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-essentials-installer install-zsh.sh

# Make script gives up on any error
set -e

# This script requires the following apt-get packages:
# git-core gcc make autoconf yodl libncursesw5-dev texinfo checkinstall

COMMAND="zsh"
FULL_COMMAND="/opt/bin/zsh"

mountpoint /mnt/etc; printf "$?\n"
mountpoint /mnt/root; printf "$?\n"
mountpoint /mnt/core; printf "$?\n"
mountpoint /opt/bin; printf "$?\n"

# Clone zsh repo if hasn't been cloned before and change to it
if [ ! -d ./zsh ]; then
    git clone git://git.code.sf.net/p/zsh/code zsh
fi
cd zsh

# Get lastest stable version, but you can change to any valid branch/tag/commit id
BRANCH=$(git describe --abbrev=0 --tags)
# Get version number, and revision/commit id when this is available
ZSH_VERSION=$(echo $BRANCH | cut -d '-' -f2,3,4)
# Go to desired branch
git checkout $BRANCH

# Make configure
./Util/preconfig

# Options from Ubuntu Zsh package rules file (http://launchpad.net/ubuntu/+source/zsh)
# Updated to zsh 5.0.2 on Trusty Tahr (pre-release)
./configure --disable-dynamic \
            --prefix=/opt/bin/zsh-bin/local \
            --mandir=/opt/bin/zsh-bin/man \
            --bindir=/opt/bin/zsh-bin \
            --infodir=/opt/bin/zsh-bin/info \
            --enable-maildir-support \
            --enable-max-jobtable-size=256 \
            --enable-etcdir=/opt/bin/zsh-bin \
            --enable-function-subdirs \
            --enable-site-fndir=/opt/bin/zsh-bin/site-functions \
            --enable-fndir=/opt/bin/zsh-bin/functions \
            --with-tcsetpgrp \
            --with-term-lib="ncursesw tinfo" \
            --enable-cap \
            --enable-pcre \
            --enable-readnullcmd=pager \
            LDFLAGS="-Wl,--as-needed -g -Wl,-Bsymbolic-functions -Wl,-z,relro"

# Compile, test and install
make -j5
make check
checkinstall -y --pkgname=zsh --pkgversion=$ZSH_VERSION --pkglicense=MIT make install install.info 


echo "Creating an executable script /opt/bin/$COMMAND"
cat <<EOT >> /opt/bin/$COMMAND
#!/bin/sh 

LD_LIBRARY_PATH="/opt/bin/$COMMAND-bin/libs" exec /opt/bin/$COMMAND-bin/$COMMAND "\$@"
EOT

# Make the script execurtable
chmod +x /opt/bin/$COMMAND

# Copy the dependencies
cpld /opt/bin/$COMMAND-bin/zsh /opt/bin/$COMMAND-bin/libs

# Make zsh the default shell
rm /mnt/etc/shells
cat <<EOT >> /mnt/etc/shells
/bin/bash
/bin/sh
/sbin/nologin
/usr/bin/bash
/usr/bin/sh
/usr/sbin/nologin
/opt/bin/zsh
EOT

sed -i '/^root/s/\/bin\/bash/\/opt\/bin\/zsh/g' /mnt/etc/passwd
sed -i '/^core/s/\/bin\/bash/\/opt\/bin\/zsh/g' /mnt/etc/passwd

# Clean up the temporary source directory
rm -Rf ./zsh

echo "ZSH has been succesfully installed ;)"






