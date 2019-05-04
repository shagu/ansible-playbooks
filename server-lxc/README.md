# Network Bridge

## Configure systemd-networkd
**/etc/systemd/network/br0-bind.network:**

    [Match]
    Name=eth0

    [Network]
    Bridge=br0

**/etc/systemd/network/br0.netdev:**

    [NetDev]
    Name=br0
    Kind=bridge
    MACAddress=A0:1E:0B:08:91:24

**/etc/systemd/network/br0.network:**

    [Match]
    Name=br0

    [Network]
    DHCP=ipv4

## Restart Network
    # systemctl enable systemd-networkd
    # systemctl disable dhcpcd@eth0
    # systemctl stop dhcpcd@eth0; systemctl start systemd-networkd

# LXC
    # pacman -S lxc bridge-utls

## Unprivileged Container
    # echo 'lxc.idmap = u 0 100000 65536' >> /etc/lxc/default.conf
    # echo 'lxc.idmap = g 0 100000 65536' >> /etc/lxc/default.conf
    # echo 'root:100000:65536' > /etc/subuid
    # echo 'root:100000:65536' > /etc/subgid

## Network Bridge
    # sed -i 's/lxc.net.0.type = empty/lxc.net.0.type = veth\nlxc.net.0.flags = up\nlxc.net.0.link = br0/' /etc/lxc/default.conf

## Create Containers
    # lxc-create -t download -n cmangos-server
      -> ubuntu
      -> disco
      -> amd64

    # lxc-create -t download -n cmangos-database
      -> ubuntu
      -> disco
      -> amd64

## Configure Containers
    # lxc-start -n cmangos-server
    # lxc-attach -n cmangos-server
    # apt install openssh-server python
    # ln -s /home/ubuntu/.ssh /root/.ssh
    # sed -i "s/^#StrictModes yes/StrictModes no/g" /etc/ssh/sshd_config
    # passwd ubuntu
    # passwd
    # systemctl restart sshd

    # lxc-start -n cmangos-database
    # lxc-attach -n cmangos-database
    # apt install openssh-server python
    # ln -s /home/ubuntu/.ssh /root/.ssh
    # sed -i "s/^#StrictModes yes/StrictModes no/g" /etc/ssh/sshd_config
    # passwd ubuntu
    # passwd
    # systemctl restart sshd

# SSH Pubkey
## Create Keypair
    $ ssh-keygen -t rsa
    -> /home/eric/.ssh/server-lxc

## Install Pubkey
    $ cat .ssh/server-lxc.pub | ssh cmangos-server -l ubuntu "mkdir -p .ssh; cat >> ~/.ssh/authorized_keys;"
    $ cat .ssh/server-lxc.pub | ssh cmangos-database -l ubuntu "mkdir -p .ssh; cat >> ~/.ssh/authorized_keys"

## Configure SSH
**.ssh/config:**

    Host cmangos-server
    IdentityFile ~/.ssh/server-lxc

    Host cmangos-database
    IdentityFile ~/.ssh/server-lxc

# Ansible
    # pacman -S ansible
    $ git clone ssh://git@gitlab.com/shagu/ansible-playbook
