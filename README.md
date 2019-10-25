# Prepare Ansible Host
## Create Keypair

    $ ssh-keygen -t rsa -b 4096
    -> /home/eric/.ssh/ansible

## Ansible

    # pacman -S ansible
    $ git clone https://github.com/shagu/ansible-playbooks
    $ ansible-playbook playbook.yml -i inventory/hosts

## Copy Keypairs

    # ./scripts/copy-pubkey.sh [hostname]

# Bootstrap Raspberry-Pi (Archlinux ARM)
Insert SD Card and run

    # ./scripts/rpi3-sdcard.sh

Connect via SSH (alarm/alarm) and run

    $ export host=kitchen
    $ ssh -t alarm@$host 'su -c "pacman-key --init;
      pacman-key --populate archlinuxarm;
      pacman -Syu;
      pacman -S python;
      passwd alarm;
      passwd;
      ln -s /home/alarm/.ssh /root/.ssh;
      sed -i \"s/^#StrictModes yes/StrictModes no/g\" /etc/ssh/sshd_config;
      systemctl restart sshd;
    "'


# Bootstrap LXC Host
## Network Bridge
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

## Setup LXC
    # pacman -S lxc bridge-utls

### Unprivileged Container
    # echo 'lxc.idmap = u 0 100000 65536' >> /etc/lxc/default.conf
    # echo 'lxc.idmap = g 0 100000 65536' >> /etc/lxc/default.conf
    # echo 'root:100000:65536' > /etc/subuid
    # echo 'root:100000:65536' > /etc/subgid

### Use Network Bridge
    # sed -i 's/lxc.net.0.type = empty/lxc.net.0.type = veth\nlxc.net.0.flags = up\nlxc.net.0.link = br0/' /etc/lxc/default.conf

# Bootstrap LXC Container
## Create Ubuntu Container
    # lxc-create -t download -n cmangos-server
      -> ubuntu
      -> disco
      -> amd64

## Start And Prepare for Ansible
    # lxc-start -n cmangos-server
    # lxc-attach -n cmangos-server
    # apt install openssh-server python
    # ln -s /home/ubuntu/.ssh /root/.ssh
    # sed -i "s/^#StrictModes yes/StrictModes no/g" /etc/ssh/sshd_config
    # passwd ubuntu
    # passwd
    # systemctl restart sshd
