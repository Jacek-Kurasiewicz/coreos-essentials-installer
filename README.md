# CoreOS Essentials Installer and Toolbox Image

The main goal of this project is to enable devops installing essential tools on CoreOS server which orginally has no software package manager. Beside this the docker image can be used as a toolbox with ZSH shell and Oh-My-Zsh configuration.

Curently available applications supported by **_CoreOS Essentials Installer_** are presented in the table below:

| App Name | From deb/src | Executable |
| -------- | :----------: | ---------- |
| zsh      | src          | /opt/bin/zsh |
| Oh-My-Zsh | src         | ~/.oh-my-zsh * | 
| tmux     | deb          | /opt/bin/tmux |
| git      | deb          | /opt/bin/git |
| nano     | deb          | /opt/bin/nano |
| mc       | src          | /opt/bin/mc |

Note that running toolbox image contains all the same applications.

(*) Oh-My-Zsh is automatically installed for root nad core users only.

## Very quick installation guide

Once CoreOS has been succesfully installed and internet connection has been established, all has to be done in order to install all supported applications is to run the following docker command as _root_ or _core_ user:

```bash
docker run --rm \
 -v /etc:/mnt/etc \
 -v /root:/mnt/root \
 -v /home/core:/mnt/core \
 -v /opt/bin:/opt/bin \
 adelaar/coreos-ubuntu-toolbox install-all.sh
```
Note that all mount poits (-v options) are required and cannot be modified. It's required to keep them as they are.

## Install CoreOS Essentials automatically with cloud-config.yml during CoreOS installation process

In order to install all applications supported by **_CoreOS Essentials Installer_** automatically during CoreOS's first boot, add the following yml snippet to your cloud-config.yml

```yml
coreos:
  units:
    # Runs only once and installs all essential tools coming with the installer
    - name: essential-tools-installer.service
      command: start
      content: |
        [Unit]
        Description=Essential Tools Installer
        After=docker.service
        Requires=docker.service
        ConditionFileExists=!/opt/systemd/essential-tools-installer

        [Service]
        ExecStartPre=/usr/bin/docker pull adelaar/coreos-ubuntu-toolbox
        ExecStart=/usr/bin/docker run --rm -v /etc:/mnt/etc -v /root:/mnt/root -v /home/core:/mnt/core -v /opt/bin:/opt/bin adelaar/coreos-ubuntu-toolbox install-all.sh
        ExecStartPost=/usr/bin/mkdir -p /opt/systemd
        ExecStartPost=/usr/bin/touch /opt/systemd/essential-tools-installer
        RemainAfterExit=yes
        Type=oneshot
```

One will be able to watch the installation process, which requires significant amount of time to complete, using the following command:
```bash
sudo journalctl -f -u essential-tools-installer.service
```
