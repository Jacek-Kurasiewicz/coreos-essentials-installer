# CoreOS Essentials Installer and Toolbox Image

The main goal of this project is to enable DevOps installing essential tools on CoreOS server which originally has no software package manager. Besides this, the Docker image can be used as a toolbox with ZSH shell and Oh-My-Zsh configuration.

Curently available applications supported by **_CoreOS Essentials Installer_** are presented in the table below:

| App Name  | From deb/src | Installation Script | Executable @ CoreOS | Dependencies XX |
| --------- | :----------: | ------------------- | ------------------- | -------------- |
| zsh       | src          | install-zsh.sh      | /opt/bin/zsh        | n/a            |
| Oh-My-Zsh | src          | install-ohmyzsh.sh  | ~/.oh-my-zsh X      | zsh, tmux, git |
| tmux      | deb          | install-tmux.sh     | /opt/bin/tmux       | n/a            |
| git       | deb          | install-git.sh      | /opt/bin/git        | n/a            |
| nano      | deb          | install-nano.sh     | /opt/bin/nano       | n/a            |
| mc        | src          | install-mc.sh       | /opt/bin/mc         | n/a            |

Note that running toolbox image contains all the same applications.

(X) Oh-My-Zsh is automatically installed for root and core users only. \
(XX) Dependencies are installed automatically.

## Installation guides

### Very quick installation guide

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

### Install CoreOS Essentials automatically with cloud-config.yml during CoreOS installation process

In order to install all applications supported by **_CoreOS Essentials Installer_** automatically during CoreOS's first boot, add the following YAML snippet to your cloud-config.yml

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

One will be able to watch the installation process, which requires a significant amount of time to complete, using the following command:
```bash
sudo journalctl -f -u essential-tools-installer.service
```
### Manual installation of selected applications only

In order to install only selected application instead of all, apropriate installation script needs to be called. Look at the _Installation Script_ collumn in the table at the top of this document to find a script name for the application you want to install. The just use it with the following docker command:

```bash
docker run --rm \
 -v /etc:/mnt/etc \
 -v /root:/mnt/root \
 -v /home/core:/mnt/core \
 -v /opt/bin:/opt/bin \
 adelaar/coreos-ubuntu-toolbox install-<app-name>.sh
```
Note that if _install-ohmyzsh.sh_ script will be called, then additionally zsh, tmux and git applications will be installed automatically.
