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
# docker run --rm -v /etc:/mnt/etc -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-essentials-installer install-ohmyzsh.sh

# Make script gives up on any error
set -e

mountpoint /mnt/etc; printf "$?\n"
mountpoint /mnt/root; printf "$?\n"
mountpoint /mnt/core; printf "$?\n"
mountpoint /opt/bin; printf "$?\n"

if [ ! -f /opt/bin/zsh ]; then
    echo "Zsh command not foud. Installing zsh..."
    install-zsh.sh
    echo "ZSH has been succesfully installed ;)"
fi

if [ ! -f /opt/bin/git ]; then
    echo "Git command not foud. Installing git..."
    install-git.sh
fi

if [ ! -f /opt/bin/tmux ]; then
    echo "Tmux command not foud. Installing tmux..."
    install-tmux.sh
fi

if [ ! -f /opt/bin/nano ]; then
    echo "Nano command not foud. Installing nano..."
    install-nano.sh
fi

########### Oh-My-Zsh for CORE user ###########

# Copy oh-my-zsh directory and files
echo "Copying /root/.oh-my-zsh -> /mnt/core"
cp -R /root/.oh-my-zsh /mnt/core
echo "Copying /root/.zshrc -> /mnt/core"
cp -R /root/.zshrc /mnt/core

chown -R 500:500 /mnt/core/.oh-my-zsh
chmod +x /mnt/core/.oh-my-zsh/oh-my-zsh.sh
chmod +x /mnt/core/.oh-my-zsh/tools/*.sh
chown 500:500 /mnt/core/.zshrc

sed -i '/^export PATH=/c\export PATH=/opt/bin:$PATH' /mnt/core/.zshrc
sed -i '/export ZSH=/c\export ZSH=/home/core/\.oh-my-zsh' /mnt/core/.zshrc

sed -i '/export EDITOR=/c\    export EDITOR=/opt/bin/nano' /mnt/core/.oh-my-zsh/themes/softpro.zsh-theme

########### Oh-My-Zsh for ROOT user ###########

# Copy oh-my-zsh directory and files
echo "Copying /root/.oh-my-zsh -> /mnt/root"
cp -R /root/.oh-my-zsh /mnt/root
echo "Copying /root/.zshrc -> /mnt/root"
cp -R /root/.zshrc /mnt/root

chown -R root:root /mnt/root/.oh-my-zsh
chmod +x /mnt/root/.oh-my-zsh/oh-my-zsh.sh
chmod +x /mnt/root/.oh-my-zsh/tools/*.sh
chown root:root /mnt/root/.zshrc

sed -i '/^export PATH=/c\export PATH=/opt/bin:$PATH' /mnt/root/.zshrc
sed -i '/export ZSH=/c\export ZSH=/root/\.oh-my-zsh' /mnt/root/.zshrc

sed -i '/export EDITOR=/c\    export EDITOR=/opt/bin/nano' /mnt/root/.oh-my-zsh/themes/softpro.zsh-theme

echo "Oh-My-Zsh has been succesfully installed for both, core and root user;)"
