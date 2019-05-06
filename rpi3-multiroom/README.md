# Bootstrap Archlinux ARM
Insert SD Card and run

    # ./prepare-pi3.sh

Connect via SSH (alarm/alarm) and run

    # su # root/root
    # pacman-key --init
    # pacman-key --populate archlinuxarm
    # pacman -Syu
    # pacman -Sy python
    # passwd alarm
    # passwd
    # ln -s /home/alarm/.ssh /root/.ssh
    # sed -i "s/^#StrictModes yes/StrictModes no/g" /etc/ssh/sshd_config
    # systemctl restart sshd

# Create Keypair

    $ ssh-keygen -t rsa
    -> /home/eric/.ssh/shairport-sync

# Install Pubkey

    $ cat .ssh/shairport-sync.pub | ssh audio-badezimmer -l alarm "mkdir -p .ssh; cat >> ~/.ssh/authorized_keys;"

# Configure SSH

**.ssh/config:**
    Host audio-badezimmer
    IdentityFile ~/.ssh/shairport-sync

