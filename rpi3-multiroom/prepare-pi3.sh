#!/bin/bash -e

echo -n "Enter SD-Card [/dev/sda]: "
read DEVICE
DEVICE=${DEVICE:-/dev/sda}

echo -n "Enter WiFI SSID [myssid]: "
read SSID
SSID=${SSID:-myssid}

echo -n "Enter WiFI Password [wifipw]: "
read WIFIPASS
WIFIPASS=${WIFIPASS:-wifipw}

echo -n "Enter Hostname [rpi]: "
read HOSTNAME
HOSTNAME=${HOSTNAME:-rpi}

echo $DEVICE
umount ${DEVICE}* || true
umount tmp/boot || true
umount tmp/root || true

rm -rf tmp/boot
rm -rf tmp/root

echo ":: Creating partition table"
parted --script $DEVICE \
    mklabel msdos \
    mkpart primary fat32 1MiB 100MiB \
    mkpart primary ext4 100MiB 100% \
    set 1 boot on

sync

echo ":: Reload partition table"
partprobe ${DEVICE}

echo ":: Format partitions"
mkfs.vfat ${DEVICE}1
mkfs.ext4 ${DEVICE}2
sync

mkdir -p tmp/root
mount ${DEVICE}2 tmp/root

mkdir -p tmp/boot
mount ${DEVICE}1 tmp/boot

if ! [ -f ArchLinuxARM-rpi-3-latest.tar.gz ]; then
  (cd tmp && wget "http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz")
fi

echo ":: Extracting rootfs"
bsdtar -xpf tmp/ArchLinuxARM-rpi-3-latest.tar.gz -C tmp/root || true
sync

echo ":: Copying bootfs"
mv tmp/root/boot/* tmp/boot
sync

echo ":: Setup WiFi"
cat > tmp/root/etc/systemd/network/wlan0.network << EOF
[Match]
Name=wlan0

[Network]
Description=On-board WiFi
DHCP=yes
EOF

cat > tmp/root/etc/wpa_supplicant/wpa_supplicant-wlan0.conf << EOF
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=wheel
network={
     ssid="$SSID"
     scan_ssid=1
     key_mgmt=WPA-PSK
     psk="$WIFIPASS"
}
EOF

echo ":: Enable WiFi Service"
ln -s /usr/lib/systemd/system/wpa_supplicant@.service tmp/root/etc/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service

echo $HOSTNAME > tmp/root/etc/hostname

echo ":: Umount"
umount tmp/boot
umount tmp/root
