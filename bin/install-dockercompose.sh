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
# docker run --rm -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-ubuntu-toolbox /opt/bin/install-ohmyzsh.sh

# Make script gives up on any error
set -e

mountpoint /mnt/etc; printf "$?\n"
mountpoint /mnt/root; printf "$?\n"
mountpoint /mnt/core; printf "$?\n"
mountpoint /opt/bin; printf "$?\n"

DOCKERCOMPOSE_VERSION=1.14.0

echo "Copying docker-compose binary to /opt/bin/docker-compose"

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/$DOCKERCOMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose
chmod +x /opt/bin/docker-compose

echo "docker-compose has been succesfully installed ;)"