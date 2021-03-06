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
# docker run --rm -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-essentials-installer install-tmux.sh

# Make script gives up on any error
set -e

COMMAND="tmux"
FULL_COMMAND="/usr/bin/tmux"

mountpoint /mnt/etc; printf "$?\n"
mountpoint /mnt/root; printf "$?\n"
mountpoint /mnt/core; printf "$?\n"
mountpoint /opt/bin; printf "$?\n"

# Create required directories
echo "Creating required directories /opt/bin/$COMMAND-bin/libs"
mkdir -p  /opt/bin/$COMMAND-bin/libs
# Copy the dependencies
cpld $FULL_COMMAND /opt/bin/$COMMAND-bin/libs
# Copy the nano binary
echo "Copying $COMMAND binary to /opt/bin/$COMMAND-bin"
cp  $FULL_COMMAND /opt/bin/$COMMAND-bin

echo "Creating an executable script /opt/bin/$COMMAND"
cat <<EOT >> /opt/bin/$COMMAND
#!/bin/bash 

LD_LIBRARY_PATH="/opt/bin/$COMMAND-bin/libs" /opt/bin/$COMMAND-bin/$COMMAND "\$@"
EOT

chmod +x /opt/bin/$COMMAND

echo "$COMMAND has been succesfully installed ;)"