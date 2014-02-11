#!/bin/sh
ln -s /mnt/sd/DCIM/linux/bin/* /bin/
ln -s /mnt/sd/DCIM/linux/usr/bin/* /usr/bin/
ln -s /mnt/sd/DCIM/linux/usr/local /usr/local
ln -s /mnt/sd/DCIM/linux/usr/lib /usr/lib
ln -s /mnt/sd/DCIM/linux/usr/include /usr/include
ln -s /mnt/sd/DCIM/linux/usr/libexec /usr/libexec
ln -s /mnt/sd/DCIM/linux/sbin/* /sbin/
rm /lib/libpthread.so.0
ln -s /mnt/sd/DCIM/linux/lib/* /lib/
ln -s /mnt/sd/DCIM/linux/etc/* /etc/
ln -s /mnt/sd/DCIM/linux/www/cgi-bin/connect2hotspot.cgi /www/cgi-bin/
#ln -s /mnt/sd/DCIM/linux/www/* /www/
#ln -s /mnt/sd/DCIM/linux/www/cgi-bin/* /www/cgi-bin/
rm /bin/vi
ln -s /mnt/sd/DCIM/linux/busybox /bin/vi
ln -s /mnt/sd/DCIM/linux/busybox /bin/top
ln -s /mnt/sd/DCIM/linux/busybox /bin/awk
ln -s /mnt/sd/DCIM/linux/busybox /bin/dd
rm /usr/bin/hexdump
ln -s /mnt/sd/DCIM/linux/busybox /usr/bin/hexdump
ln -s /mnt/sd/DCIM/linux/busybox /bin/killall
ln -s /mnt/sd/DCIM/linux/busybox /bin/less
ln -s /mnt/sd/DCIM/linux/busybox /bin/passwd
ln -s /mnt/sd/DCIM/linux/busybox /bin/sed
ln -s /mnt/sd/DCIM/linux/busybox /bin/tar
rm /usr/bin/telnet
ln -s /mnt/sd/DCIM/linux/busybox /usr/bin/telnet
ln -s /mnt/sd/DCIM/linux/busybox /bin/whoami

# ssh
# user: root password: admin
#dropbear -A -N root -C admin -U 0 -G 0
# public key auth
#dropbear -A -N root -C '-' -U 0 -G 0 -R /mnt/sd/DCIM/linux/authorized_keys2 -s

# kill telnetd
#killall telnetd
#ftp

#killall tcpsvd
#tcpsvd 0 21 ftpd -w / &
# connect to Hotspots

if [ -e /mnt/sd/connect2hotspot ]; then
sleep 5
/usr/bin/w2 &
fi
