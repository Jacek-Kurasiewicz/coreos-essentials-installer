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
# docker run --rm -v /usr:/mnt/usr -v /etc:/mnt/etc -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-ubuntu-toolbox uninstall-all.sh

# Make script gives up on any error
set -e

mountpoint /mnt/etc; printf "$?\n"
mountpoint /mnt/root; printf "$?\n"
mountpoint /mnt/core; printf "$?\n"
mountpoint /opt/bin; printf "$?\n"

# Remove docker-compose
rm -Rf /opt/bin/docker-compose

# Remove git
rm -Rf /opt/bin/git-bin /opt/bin/git

# Remove mc
rm -Rf /opt/bin/mc-bin /opt/bin/mc \
	/mnt/core/.config/mc \
	/mnt/root/.config/mc \
	/mnt/core/.local/share/mc \
	/mnt/root/.local/share/mc \
	/mnt/core/.cache/mc \
	/mnt/root/.cache/mc

# Remove nano
rm -Rf /opt/bin/nano-bin /opt/bin/nano

# Remove tmux
rm -Rf /opt/bin/tmux-bin /opt/bin/tmux

# Remove zsh & Oh-My-Zsh
rm -Rf /opt/bin/zsh-bin /opt/bin/zsh \
	/mnt/core/.oh-my-zsh /mnt/core/.zsh* \
	/mnt/root/.oh-my-zsh /mnt/root/.zsh*
sed -i '/^root/s/\/opt\/bin\/zsh/\/bin\/bash/g' /mnt/etc/passwd
sed -i '/^core/s/\/opt\/bin\/zsh/\/bin\/bash/g' /mnt/etc/passwd
rm /mnt/etc/shells
cat <<EOT >> /mnt/etc/shells
/bin/bash
/bin/sh
/sbin/nologin
/usr/bin/bash
/usr/bin/sh
/usr/sbin/nologin
EOT
