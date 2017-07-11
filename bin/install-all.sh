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
# docker run --rm -v /etc:/mnt/etc -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-essentials-installer install-all.sh

# Make script gives up on any error
set -e

if [ ! -f /opt/bin/git ]; then
    echo "Git command not foud. Installing git..."
    install-git.sh
fi

if [ ! -f /opt/bin/tmux ]; then
    echo "Tmux command not foud. Installing tmux..."
    install-tmux.sh
fi

if [ ! -f /opt/bin/docker-compose ]; then
    echo "docker-compose command not foud. Installing docker-compose..."
    install-dockercompose.sh
fi

if [ ! -f /opt/bin/zsh ]; then
    echo "Zsh command not foud. Installing zsh..."
    install-zsh.sh
fi

echo "Reinstalling Oh-My-Zsh..."
install-ohmyzsh.sh

if [ ! -f /opt/bin/mc ]; then
    echo "MC command not foud. Installing mc..."
    install-mc.sh
fi

if [ ! -f /opt/bin/nano ]; then
    echo "Nano command not foud. Installing nano..."
    install-nano.sh
fi









# module_path=(/opt/bin/zsh5-bin/modules); autoload -Uz compdef && compdef
# sudo cp -R /usr/share/zsh/functions/ /mnt/bin/zsh5-bin/functions

# sudo sed -i "1ifpath=(/opt/bin/zsh5-bin/modules)" /mnt/core/.zshrc
# sudo sed -i "2ifpath=(/opt/bin/zsh5-bin/modules)" /mnt/core/.oh-my-zsh/tools/check_for_upgrade.sh

# sudo sed -i "1ifpath=(/opt/bin/zsh5-bin/modules)" /mnt/root/.zshrc
# sudo sed -i "2ifpath=(/opt/bin/zsh5-bin/modules)" /mnt/root/.oh-my-zsh/tools/check_for_upgrade.sh

# /opt/bin/zsh-bin/site-functions
# /opt/bin/zsh-bin/functions
# /opt/bin/zsh-bin/vendor-functions
# /opt/bin/zsh-bin/vendor-completions